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
    func pokemonSearchView() -> UIViewController
}

class PokemonSearchViewController: UIViewController, StoryboardView {
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
    typealias Reactor = PokemonSearchViewReactor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
    }
    
    func bind(reactor: PokemonSearchViewReactor) {
        bindAction(reactor: reactor)
        bindSearchResult(reactor: reactor)
        bindEvent(reactor: reactor)
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
                reactor.action.onNext(.showPokemon(index: $0.row))
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
            .bind(to: tableView.rx.items) { (tableView, index, item) -> UITableViewCell in
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
            .drive(onNext: {
                guard let event = $0 else { return }
                switch event {
                case .showPokemon(let id):
                    print(id)
                }
            })
            .disposed(by: disposeBag)
    }
}
