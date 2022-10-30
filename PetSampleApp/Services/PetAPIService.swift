//
//  APIService.swift
//  PetSample
//
//  Created by Ionut Lucaci on 25.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt


// MARK: - Interface

protocol PetAPIService {
    func getPets(location: Location?) -> Observable<[Pet]>
}

extension PetAPIService {
    func getPets() -> Observable<[Pet]> {
        return getPets(location: nil)
    }
}

// MARK: - Implementation

class PetfinderService: PetAPIService {
    // MARK: - Dependencies
    private let net: NetworkService
    
    // MARK: - Boilerplate
    private let disposeBag = DisposeBag()
    
    // MARK: - State
    private var environment: Endpoint.Environment = .prod
    private var token: OAuth.Token? = nil
    
    // MARK: - Public methods
    init(networkService: NetworkService) {
        net = networkService
    }
    
    func getPets(location: Location?) -> Observable<[Pet]> {
        let response: Observable<PetResponse> = performAuthenticatedRequest(endpoint: .pets, parameters: location)

        return response.map { $0.animals }
    }
    
    // MARK: - Private methods
    private func performRequest<Parameters: Encodable,
                                Result: Decodable>(endpoint: Endpoint.Petfinder,
                                                   method: Method = .get,
                                                   headers: [Header: Header.Value] = [:],
                                                   parameters: Parameters?) -> Observable<Result>
    {
        return net.performRequest(endpoint: .petfinder(endpoint, environment: environment),
                                  method: method,
                                  headers: headers,
                                  parameters: parameters)
    }
    
    
    private func performRequest<Result: Decodable>(endpoint: Endpoint.Petfinder,
                                                   method: Method = .get,
                                                   headers: [Header: Header.Value] = [:]) -> Observable<Result>
    {
        return performRequest(endpoint: endpoint,
                              method: method,
                              headers: headers,
                              parameters: Optional<String>.none) // just provide an encodable to stop the compiler from complaining, since it won't actually be used
    }
    
    private func fetchToken() -> Observable<OAuth.Token> {
        return performRequest(endpoint: .auth,
                              method: .post,
                              parameters: OAuth.Credentials.Petfinder)
        .do(onNext: { [weak self] token in
            self?.token = token
        })
    }
    
    private func performAuthenticatedRequest<Parameters: Encodable,
                                             Result: Decodable>(endpoint: Endpoint.Petfinder,
                                                                method: Method = .get,
                                                                parameters: Parameters?) -> Observable<Result>
    {
        let token: Observable<OAuth.Token>
        if let localToken = self.token {
            token = .just(localToken)
        } else {
            token = fetchToken()
        }
        
        return token
            .flatMap { [weak self] token -> Observable<Result> in
                
                guard let welf = self else { return .never() }
                
                return welf
                    .performRequest(endpoint: endpoint,
                                    method: method,
                                    headers: [.auth: .token(token)],
                                    parameters: parameters)
                    .catch { [weak self] err in
                        
                        guard let welf = self,
                              (err as? StatusCodeError)?.reason == .unauthorized
                        else {
                            return .error(err)
                        }
                        
                        welf.token = nil
                        
                        return welf.performAuthenticatedRequest(endpoint: endpoint,
                                                                method: method,
                                                                parameters: parameters)
                    }
            }
            .observe(on: MainScheduler.asyncInstance)
            
    }
    
    private func performAuthenticatedRequest<Result: Decodable>(endpoint: Endpoint.Petfinder,
                                                                method: Method = .get) -> Observable<Result>
    {
        return performAuthenticatedRequest(endpoint: endpoint,
                                           method: method,
                                           parameters: Optional<String>.none) // just provide an encodable to stop the compiler from complaining, since it won't actually be used
    }
}

// MARK: - Private Extensions

fileprivate struct PetResponse: Decodable, Equatable {
    let animals: [Pet]
}

fileprivate extension OAuth.Credentials {
    static var Petfinder: Self {
        return .init(clientId: "8FvB92COL3loJkRHBozGPLOVKZTG4CgXal6Dou6EjsH5lj2SXB",
                     clientSecret: "zcYSA3CrhG6yW1dc539o8rAVgj7ecwLUaYHTSe3s")
    }
}
