//
//  PokemonSearchViewReactor.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift
import ReactorKit

class PokemonSearchViewReactor: Reactor {
    enum Action {
        case search(keyword: String)
        case showPokemon(id: PokemonId)
    }
    
    enum Mutation {
        case updateKeyword(keyword: String)
        case updateSearchResult([SearchedPokemon])
        
        case event(Event)
    }
    
    struct State {
        var searchKeyword: String?
        var searchResult: [SearchedPokemon] = []
        
        var event: Event?
    }
    
    enum Event {
        case showPokemon(id: PokemonId)
    }
    
    var initialState = State()
    let searchUseCase: PokemonSearchUseCase
    
    init(searchUseCase: PokemonSearchUseCase) {
        self.searchUseCase = searchUseCase
    }
}

extension PokemonSearchViewReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .search(let keyword):
            return searchMutation(keyword: keyword)
        case .showPokemon(let id):
            return .just(.event(.showPokemon(id: id)))
        }
    }
    
    private func searchMutation(keyword: String) -> Observable<Mutation> {
        let updateKeyword: Observable<Mutation> = .just(.updateKeyword(keyword: keyword))
        let search: Observable<Mutation> = searchUseCase.search(keyword: keyword)
            .asObservable()
            .map { .updateSearchResult($0) }
        
        return .concat(updateKeyword, search)
    }
}
