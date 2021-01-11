//
//  PokemonLocationLocalDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

protocol PokemonLocationLocalDataSource {
    func location(id: PokemonId) -> Maybe<Location>
    func setLocations(_ locations: [PokemonLocation]) -> Completable
}
