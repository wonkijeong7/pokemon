//
//  PokemonLocationUseCase.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/08.
//

import Foundation
import RxSwift

protocol PokemonLocationUseCase {
    func updateKnownLocations() -> Completable
    func knownLocations(id: PokemonId) -> Single<[Location]>
}

struct PokemonLocationDefaultUseCase: PokemonLocationUseCase {
    let locationRepository: PokemonLocationRepository
    
    func updateKnownLocations() -> Completable {
        return locationRepository.update()
    }
    
    func knownLocations(id: PokemonId) -> Single<[Location]> {
        return locationRepository.knownLocations(id: id)
    }
}
