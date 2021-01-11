//
//  PokemonLocationViewReactor.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/12.
//

import Foundation
import RxSwift
import ReactorKit

class PokemonLocationViewReactor: Reactor {
    enum Action {
        case initialize
        case close
    }
    
    enum Mutation {
        case updateName(String)
        case updateKnownLocations([Location])
        
        case event(Event)
    }
    
    struct State {
        var name: String?
        var knownLocations: [Location] = []
        
        var event: Event?
    }
    
    enum Event {
        case close
    }
    
    var initialState = State()
    private let pokemonId: PokemonId
    private let descriptionUseCase: PokemonDescriptionUseCase
    private let locationUseCase: PokemonLocationUseCase
    
    init(pokemonId: PokemonId,
         descriptionUseCase: PokemonDescriptionUseCase,
         locationUseCase: PokemonLocationUseCase) {
        self.pokemonId = pokemonId
        self.descriptionUseCase = descriptionUseCase
        self.locationUseCase = locationUseCase
        
        action.onNext(.initialize)
    }
}

extension PokemonLocationViewReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initialize:
            return initializeMutation()
        case .close:
            return .just(.event(.close))
        }
    }
    
    private func initializeMutation() -> Observable<Mutation> {
        let name = descriptionUseCase.name(id: pokemonId)
            .asObservable()
            .map { Mutation.updateName($0) }
        
        let locations = locationUseCase.knownLocations(id: pokemonId)
            .asObservable()
            .map { Mutation.updateKnownLocations($0) }
        
        return .merge(name, locations)
    }
}

extension PokemonLocationViewReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var nextState = state
        nextState.event = nil
        
        switch mutation {
        case .updateName(let name):
            nextState.name = name
        case .updateKnownLocations(let locations):
            nextState.knownLocations = locations
        case .event(let event):
            nextState.event = event
        }
        
        return nextState
    }
}
