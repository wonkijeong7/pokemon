//
//  PokemonMetadataRepository.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/08.
//

import Foundation
import RxSwift

protocol PokemonMetadataRepository {
    func updateNames() -> Completable
    func updateLocations() -> Completable
    
    func allNames() -> Single<[PokemonName]>
    func names(id: PokemonId) -> Single<[String]>
}
