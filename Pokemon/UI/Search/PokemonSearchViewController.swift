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

protocol PokemonSearchViewProvider {
    func pokemonSearchView() -> UIViewController
}

class PokemonSearchViewController: UIViewController, StoryboardView {
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
    typealias Reactor = PokemonSearchViewReactor
    
    func bind(reactor: PokemonSearchViewReactor) {
        
    }
}
