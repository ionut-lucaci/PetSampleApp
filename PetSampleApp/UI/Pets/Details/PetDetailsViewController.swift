//
//  PetDetailsViewController.swift
//  PetSample
//
//  Created by Ionut Lucaci on 28.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt

class PetDetailsViewController: UITableViewController, NavigationNode {

    lazy var viewModel = PetDetailsViewModel(navigator: navigator)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel
            .title
            .bind(to: rx.title)
            .disposed(by: viewModel.disposeBag)
        
        tableView.dataSource = nil
        
        let ds = RxTableViewSectionedReloadDataSource<PetDetailSection>(configureCell: { ds, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseId.rawValue,
                                                     for: indexPath)
            
            switch item {
            case .header(let pet):
                (cell as? PetDetailHeaderCell)?.setup(item: pet)
            case .key(let key, let value):
                (cell as? PetDetailKeyValueCell)?.setup(key: key, value: value)
            }
            
            return cell
        })
        
        ds.titleForHeaderInSection = { $0.sectionModels[$1].model }
              
        viewModel
            .sections
            .bind(to: tableView.rx.items(dataSource: ds))
            .disposed(by: viewModel.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }

}

class PetDetailHeaderCell: UITableViewCell, PetThumbnailDisplaying {
    @IBOutlet weak var photoView: CircularThumbnailView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var recycleBin = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetThumbnailState()
    }
    
    func setup(item: PetItem) {
        bind(photo: item.photo,
             emoji: item.emoji)

        emojiLabel.text = item.emoji
        breedLabel.text = item.detailText
        distanceLabel.text = item.distanceText(format: .long)
    }
}

class PetDetailKeyValueCell: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    func setup(key: String?, value: String?) {
        keyLabel.text = key
        valueLabel.text = value
    }
}
