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
        case showDescription(index: Int)
        case showLocation(id: PokemonId)
    }
    
    enum Mutation {
        case updateKeyword(keyword: String)
        case updateSearchResult([SearchedPokemon])
        case resetSearchResult
        
        case event(Event)
    }
    
    struct State {
        var searchKeyword: String?
        var searchResult: [SearchedPokemon] = []
        
        var event: Event?
    }
    
    enum Event {
        case showDescription(id: PokemonId)
        case showLocation(id: PokemonId)
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
        case .showDescription(let index):
            return selectMutation(index: index)
        case .showLocation(let id):
            return .just(.event(.showLocation(id: id)))
        }
    }
    
    private func searchMutation(keyword: String) -> Observable<Mutation> {
        let updateKeyword: Observable<Mutation> = .just(.updateKeyword(keyword: keyword))
        
        guard !keyword.isEmpty else {
            return .concat(updateKeyword, .just(.resetSearchResult))
        }
        
        let search: Observable<Mutation> = searchUseCase.search(keyword: keyword)
            .asObservable()
            .map { .updateSearchResult($0) }
        
        return .concat(updateKeyword, search)
    }
    
    private func selectMutation(index: Int) -> Observable<Mutation> {
        guard index < currentState.searchResult.count else { return .empty() }
        
        let id = currentState.searchResult[index].id
        
        return .just(.event(.showDescription(id: id)))
    }
}

extension PokemonSearchViewReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var nextState = state
        
        nextState.event = nil
        switch mutation {
        case .updateKeyword(let keyword):
            nextState.searchKeyword = keyword
        case .updateSearchResult(let result):
            nextState.searchResult = result
        case .resetSearchResult:
            nextState.searchResult = []
        case .event(let event):
            nextState.event = event
        }
        
        return nextState
    }
}
