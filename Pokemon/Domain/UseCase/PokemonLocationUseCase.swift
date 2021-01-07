//
//  PokemonLocationUseCase.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/08.
//

import Foundation
import RxSwift

protocol PokemonLocationUseCase {
    func knownLocation(id: PokemonId) -> Maybe<Location>
}

struct PokemonLocationDefaultUseCase: PokemonLocationUseCase {
    let locationRepository: PokemonLocationRepository
    
    func knownLocation(id: PokemonId) -> Maybe<Location> {
        return locationRepository.knownLocation(id: id)
    }
}
