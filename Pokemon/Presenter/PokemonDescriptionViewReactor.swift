//
//  PokemonDescriptionViewReactor.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/12.
//

import Foundation
import RxSwift
import ReactorKit

class PokemonDescriptionViewReactor: Reactor {
    enum Action {
        case initialize
        case showLocation
        case close
    }
    
    enum Mutation {
        case updateDescription(PokemonDescription)
        case updateThumbnail(Data)
        case updateHasKnownLocations(Bool)
        case event(Event)
    }
    
    struct State {
        var description: PokemonDescription?
        var thumbnail: Data?
        var hasKnownLocations: Bool = false
        
        var event: Event?
    }
    
    enum Event {
        case close
    }
    
    var initialState = State()
    private let pokemonId: PokemonId
    private var showLocationObserver: AnyObserver<PokemonId>
    private var descriptionUseCase: PokemonDescriptionUseCase
    private var locationUseCase: PokemonLocationUseCase
    
    init(pokemonId: PokemonId,
         showLocationObserver: AnyObserver<PokemonId>,
         descriptionUseCase: PokemonDescriptionUseCase,
         locationUseCase: PokemonLocationUseCase) {
        self.pokemonId = pokemonId
        self.showLocationObserver = showLocationObserver
        self.descriptionUseCase = descriptionUseCase
        self.locationUseCase = locationUseCase
        
        action.onNext(.initialize)
    }
}

extension PokemonDescriptionViewReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initialize:
            return initializeMutation()
        case .showLocation:
            return showLocationMutation()
        case .close:
            return closeMutation()
        }
    }
    
    private func initializeMutation() -> Observable<Mutation> {
        descriptionUseCase.description(id: pokemonId)
            .asObservable()
            .flatMap { [weak self] description -> Observable<Mutation> in
                guard let `self` = self else { return .empty() }
                
                return .concat(.just(.updateDescription(description)),
                               self.fetchThumbnailMutation(),
                               self.hasKnownLocationsMutation())
            }
    }
    
    private func fetchThumbnailMutation() -> Observable<Mutation> {
        return descriptionUseCase.thumbnail(id: pokemonId)
            .asObservable()
            .map { .updateThumbnail($0) }
    }
    
    private func hasKnownLocationsMutation() -> Observable<Mutation> {
        return locationUseCase.updateKnownLocations()
            .andThen(locationUseCase.knownLocations(id: pokemonId))
            .asObservable()
            .map { .updateHasKnownLocations(!$0.isEmpty) }
    }
    
    private func showLocationMutation() -> Observable<Mutation> {
        showLocationObserver.onNext(pokemonId)
        
        return closeMutation()
    }
    
    private func closeMutation() -> Observable<Mutation> {
        showLocationObserver.onCompleted()
        
        return .just(.event(.close))
    }
}

extension PokemonDescriptionViewReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var nextState = state
        nextState.event = nil
        
        switch mutation {
        case .updateDescription(let description):
            nextState.description = description
        case .updateThumbnail(let thumbnail):
            nextState.thumbnail = thumbnail
        case .updateHasKnownLocations(let hasKnownLocations):
            nextState.hasKnownLocations = hasKnownLocations
        case .event(let event):
            nextState.event = event
        }
        
        return nextState
    }
}
