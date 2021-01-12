//
//  PokemonSearchViewController.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

protocol PokemonSearchViewProvider {
    func searchViewController() -> UIViewController
}

class PokemonSearchViewController: UIViewController, StoryboardView {
    typealias Reactor = PokemonSearchViewReactor
    
    var disposeBag = DisposeBag()
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    var descriptionViewProvider: PokemonDescriptionViewProvider?
    var locationViewProvider: PokemonLocationViewProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
    }
    
    func bind(reactor: PokemonSearchViewReactor) {
        bindAction(reactor: reactor)
        bindSearchResult(reactor: reactor)
        bindEvent(reactor: reactor)
        bindKeyboard()
    }
    
    func bindAction(reactor: PokemonSearchViewReactor) {
        searchTextField.rx.text
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                reactor.action.onNext(.search(keyword: $0 ?? ""))
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [tableView] in
                tableView?.deselectRow(at: $0, animated: true)
                reactor.action.onNext(.showDescription(index: $0.row))
            })
            .disposed(by: disposeBag)
    }
    
    func bindSearchResult(reactor: PokemonSearchViewReactor) {
        let searchResult = Observable.combineLatest(
            reactor.state.map { $0.searchKeyword }.distinctUntilChanged(),
            reactor.state.map { $0.searchResult }.distinctUntilChanged()
        )
        
        searchResult
            .map { keyword, result in
                result.map { SearchedPokemonTableViewCell.ViewModel(highlightedText: keyword, text: $0.matchedName) }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, index, item) -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchedPokemonTableViewCell") as? SearchedPokemonTableViewCell else {
                    return UITableViewCell()
                }
                
                cell.viewModel = item
                
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    func bindEvent(reactor: PokemonSearchViewReactor) {
        reactor.state.map { $0.event }
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] in
                guard let event = $0 else { return }
                
                switch event {
                case .showSearchError(let keyword):
                    self?.showErrorAlert(searchKeyword: keyword)
                case .showDescription(let id):
                    self?.openDescriptionView(id: id)
                case .showLocation(let id):
                    self?.openLocationView(id: id)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindKeyboard() {
        NotificationCenter.default.rx.notification(UIApplication.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] in
                if let keyboardFrame = $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    self?.setTableViewInsets(bottomInset: keyboardFrame.cgRectValue.height)
                }
            })
            .disposed(by: disposeBag)
        
         NotificationCenter.default.rx.notification(UIApplication.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] _ in
                self?.setTableViewInsets(bottomInset: 0)
            })
            .disposed(by: disposeBag)
    }
}

extension PokemonSearchViewController {
    private func setTableViewInsets(bottomInset: CGFloat) {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
    
    private func showErrorAlert(searchKeyword: String) {
        let alert = UIAlertController(title: "정보를 가져오는 데 실패했습니다.", message: "다시 시도해 주세요.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "재시도", style: .default, handler: { [reactor] _ in
            reactor?.action.onNext(.search(keyword: searchKeyword))
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func openDescriptionView(id: PokemonId) {
        guard let viewProvider = descriptionViewProvider else { return }
        
        let openLocationPublisher = PublishSubject<PokemonId>()
        
        openLocationPublisher
            .subscribe(onNext: { [weak self] in
                self?.reactor?.action.onNext(.showLocation(id: $0))
            })
            .disposed(by: disposeBag)
        
        let viewController = viewProvider.descriptionViewController(id: id, showLocationObserver: openLocationPublisher.asObserver())
        
        present(viewController, animated: true, completion: nil)
    }
    
    private func openLocationView(id: PokemonId) {
        guard let viewProvider = locationViewProvider else { return }
        
        let viewController = viewProvider.locationViewController(id: id)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
