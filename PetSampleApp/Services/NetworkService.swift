//
//  NetworkService.swift
//  PetSample
//
//  Created by Ionut Lucaci on 25.10.2022.
//

import Foundation
import Alamofire
import RxSwift

// MARK: - Interface

protocol NetworkService {
    func performRequest<Parameters: Encodable,
                        Result: Decodable>(endpoint: Endpoint,
                                           method: Method,
                                           headers: [Header: Header.Value],
                                           parameters: Parameters?) -> Observable<Result>
    
    func performDataRequest<Parameters: Encodable>(endpoint: Endpoint,
                                                   method: Method,
                                                   headers: [Header: Header.Value],
                                                   parameters: Parameters?) -> Observable<Data>
}

extension NetworkService {
    func performRequest<Result: Decodable>(endpoint: Endpoint,
                                           method: Method = .get,
                                           headers: [Header: Header.Value] = [:]) -> Observable<Result> {
        return performRequest(endpoint: endpoint,
                              method: method,
                              headers: headers,
                              parameters: Optional<String>.none) // just provide an encodable to stop the compiler from complaining, since it won't actually be used
                                   
    }
    
    func performRequest<Parameters: Encodable,
                        Result: Decodable>(endpoint: Endpoint,
                                           method: Method = .get,
                                           parameters: Parameters?) -> Observable<Result> {
        return performRequest(endpoint: endpoint,
                              method: method,
                              headers: [:],
                              parameters: parameters)
    }
    
    func performDataRequest(endpoint: Endpoint,
                            method: Method = .get,
                            headers: [Header: Header.Value] = [:]) -> Observable<Data> {
        return performDataRequest(endpoint: endpoint,
                                  method: method,
                                  headers: headers,
                                  parameters: Optional<String>.none) // just provide an encodable to stop the compiler from complaining, since it won't actually be used
        
    }
    
    func performDataRequest<Parameters: Encodable>(endpoint: Endpoint,
                                                   method: Method = .get,
                                                   parameters: Parameters?) -> Observable<Data> {
        return performDataRequest(endpoint: endpoint,
                                  method: method,
                                  headers: [:],
                                  parameters: parameters)
    }
}

// MARK: - Implementation

class AFNetworkService: NetworkService {
    func performRequest<Parameters: Encodable,
                        Result: Decodable>(endpoint: Endpoint,
                                           method: Method = .get,
                                           headers: [Header: Header.Value] = [:],
                                           parameters: Parameters? = nil) -> Observable<Result>
    {
        return AF
            .request(endpoint.url,
                     method: method.asAlamofireMethod(),
                     parameters: parameters,
                     headers: headers.asAlamofireHeaders())
            .rx
            .responseDecodable(of: Result.self)
    }
    
    func performDataRequest<Parameters: Encodable>(endpoint: Endpoint,
                                                   method: Method = .get,
                                                   headers: [Header: Header.Value] = [:],
                                                   parameters: Parameters? = nil) -> Observable<Data>
    {
        return AF
            .request(endpoint.url,
                     method: method.asAlamofireMethod(),
                     parameters: parameters,
                     headers: headers.asAlamofireHeaders())
            .rx
            .responseData()
            .do(onNext: { print("Data request completed: \($0)") })
    }
}

// MARK: - Public Extensions

extension DataRequest: ReactiveCompatible {}
extension Reactive where Base == DataRequest {
    func responseDecodable<T: Decodable>(of type: T.Type = T.self,
                                         queue: DispatchQueue = .main,
                                         dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
                                         decoder: Alamofire.DataDecoder = JSONDecoder(),
                                         emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
                                         emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods) -> Observable<T> {
        return Observable.create { obs in
            base.responseDecodable(of: type,
                                   queue: queue,
                                   dataPreprocessor: dataPreprocessor,
                                   decoder: decoder,
                                   emptyResponseCodes: emptyResponseCodes,
                                   emptyRequestMethods: emptyRequestMethods) { resp in
                
                let status = resp.response.map { StatusCode(intValue: $0.statusCode) }
                
                switch status {
                case .success, .none:
                    switch resp.result {
                    case .failure(let err):
                        obs.onError(err)
                    case .success(let bod):
                        obs.onNext(bod)
                    }
                case .failure(let err):
                    obs.onError(err)
                }
                
            }
            
            return Disposables.create()
        }
    }
    
    func responseData(queue: DispatchQueue = .main,
                      dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
                      emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
                      emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods) -> Observable<Data> {
        return Observable.create { obs in
            base.responseData(queue: queue,
                              dataPreprocessor: dataPreprocessor,
                              emptyResponseCodes: emptyResponseCodes,
                              emptyRequestMethods: emptyRequestMethods) { resp in
                
                let status = resp.response.map { StatusCode(intValue: $0.statusCode) }
                
                switch status {
                case .success, .none:
                    switch resp.result {
                    case .failure(let err):
                        obs.onError(err)
                    case .success(let bod):
                        obs.onNext(bod)
                    }
                case .failure(let err):
                    obs.onError(err)
                }
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - Private Extensions

fileprivate extension Method {
    func asAlamofireMethod() -> HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .patch:
            return .patch
        case .delete:
            return .delete
        }
    }
}

fileprivate extension Dictionary where Key == Header, Value == Header.Value {
    func asAlamofireHeaders() -> HTTPHeaders {
        return HTTPHeaders(map { HTTPHeader(name: $0.rawValue,
                                            value: $1.value) })
    }
}
