//
//  PokemonRepository.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/08.
//

import Foundation
import RxSwift

protocol PokemonRepository {
    func updateMetadata() -> Completable
    
    func allNames() -> Single<[PokemonName]>
    func names(id: PokemonId) -> Single<PokemonName>
    
    func pokemon(id: PokemonId) -> Single<Pokemon>
    
    func thumbnail(id: PokemonId) -> Maybe<Data>
}

enum PokemonRepositoryError: Error {
    case notExists(id: PokemonId)
}
