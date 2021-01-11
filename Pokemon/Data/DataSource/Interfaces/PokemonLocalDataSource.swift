//
//  PokemonLocalDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

protocol PokemonLocalDataSource {
    func pokemon(id: PokemonId) -> Single<Pokemon>
    func setPokemon(_ pokemon: Pokemon) -> Completable
}

enum PokemonLocalDataSourceError: Error {
    case notExists(id: PokemonId)
}
