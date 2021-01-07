//
//  PokemonLocationRepository.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/08.
//

import Foundation
import RxSwift

protocol PokemonLocationRepository {
    func update() -> Completable
    
    func knownLocation(id: PokemonId) -> Maybe<Location>
}
