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
    
    struct ViewModel {
        let highlightedText: String?
        let text: String
    }
    
    fileprivate let viewModelPublisher = BehaviorRelay<ViewModel?>(value: nil)
    private lazy var viewModelObservable = viewModelPublisher.asDriver()
    var viewModel: ViewModel? {
        didSet {
            viewModelPublisher.accept(viewModel)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModelObservable
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
        
        if let highlightedText = viewModel.highlightedText {
            let range = (viewModel.text.lowercased() as NSString).range(of: highlightedText.lowercased())
            
            attributed.addAttributes(Constants.heightLightAttributes, range: range)
        }
        
        return attributed
    }
}
