//
//  ViewController.swift
//  PetSample
//
//  Created by Ionut Lucaci on 24.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt

// MARK: - ViewController

class PetsViewController: UITableViewController, NavigationNode {
    // some sort of dependency resolver would be nice but this will have to do for now
    lazy var networkService = AFNetworkService()
    lazy var petService = PetfinderService(networkService: networkService)
    lazy var locationService = MockLocationService()
    lazy var cacheService = MemoryImageCacheService()
    lazy var mediaService = CachedMediaService(networkService: networkService,
                                               imageCacheService: cacheService)
    lazy var viewModel = PetsViewModel(petService: petService,
                                       locationService: locationService,
                                       mediaService: mediaService,
                                       navigator: navigator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingView = LoadingView.loadFlomNib()
        tableView.backgroundView = loadingView
        tableView.dataSource = nil

        let ds = RxTableViewSectionedReloadDataSource<PetSection>(configureCell: { ds, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "PetCell", for: indexPath) 
            (cell as? PetCell)?.setup(item: item)
            
            return cell
        })
        
        ds.titleForHeaderInSection = { $0.sectionModels[$1].model }
              
        viewModel
            .sections
            .bind(to: tableView.rx.items(dataSource: ds))
            .disposed(by: viewModel.disposeBag)
        
        tableView
            .rx
            .modelSelected(PetItem.self)
            .bind(to: viewModel.itemSelected)
            .disposed(by: viewModel.disposeBag)
        
        if let navView = navigationController?.view {
            viewModel
                .toast
                .bind(to: navView.rx.toast)
                .disposed(by: viewModel.disposeBag)
        }
        
        if let loadingView = loadingView {
            viewModel
                .loadingState
                .bind(to: loadingView.rx.loadingState)
                .disposed(by: viewModel.disposeBag)
        }
    }
}

// MARK: - Cell

class PetCell: UITableViewCell, PetThumbnailDisplaying {
    @IBOutlet weak var photoView: CircularThumbnailView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var recycleBin = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetThumbnailState()
    }
    
    func setup(item: PetItem) {
        bind(photo: item.photo,
             emoji: item.emoji)
        nameLabel.text = item.pet.name
        detailLabel.text = item.detailText
        distanceLabel.text = item.distanceText()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        separatorInset.left = nameLabel.frame.minX
    }
}


