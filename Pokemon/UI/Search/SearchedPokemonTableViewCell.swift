//
//  SearchedPokemonTableViewCell.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import UIKit
import RxSwift
import RxCocoa

class SearchedPokemonTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var disposeBag = DisposeBag()
    
    fileprivate let viewModelPublisher = BehaviorRelay<ViewModel?>(value: nil)
    private lazy var viewModel = viewModelPublisher.asDriver()
    
    struct ViewModel {
        let highlightedText: String
        let text: String
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel
            .map { [weak self] viewModel -> NSAttributedString? in
                self?.attributedText(viewModel: viewModel)
            }
            .drive(titleLabel.rx.attributedText)
            .disposed(by: disposeBag)
    }
}

extension SearchedPokemonTableViewCell {
    struct Constants {
        static var defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        ]
        
        static var heightLightAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0.07, green: 0.36, blue: 0.90, alpha: 1)
        ]
    }
    
    private func attributedText(viewModel: ViewModel?) -> NSAttributedString? {
        guard let viewModel = viewModel else { return nil }
        
        let attributed = NSMutableAttributedString(string: viewModel.text, attributes: Constants.defaultAttributes)
        
        let range = (viewModel.text as NSString).range(of: viewModel.highlightedText)
        
        attributed.addAttributes(Constants.heightLightAttributes, range: range)
        
        return attributed
    }
}

extension Reactive where Base: SearchedPokemonTableViewCell {
    var viewModel: Binder<SearchedPokemonTableViewCell.ViewModel> {
        return Binder(self.base) { view, viewModel in
            view.viewModelPublisher.accept(viewModel)
        }
    }
}
