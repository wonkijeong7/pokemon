//
//  PokemonDescriptionUseCase.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/07.
//

import Foundation
import RxSwift

struct PokemonDescription {
    let id: PokemonId
    let representativeName: String
    let otherNames: [String]
    
    let size: Double
    let weight: Double
    
    let hasThumbnail: Bool
}

protocol PokemonDescriptionUseCase {
    func updateMetadata() -> Completable
    
    func description(id: PokemonId) -> Single<PokemonDescription>
    func thumbnail(id: PokemonId) -> Maybe<Data>
}

struct PokemonDescriptionDefaultUseCase: PokemonDescriptionUseCase {
    let repository: PokemonRepository
    
    func updateMetadata() -> Completable {
        return repository.updateMetadata()
    }
    
    func description(id: PokemonId) -> Single<PokemonDescription> {
        return Single.zip(repository.names(id: id), repository.pokemon(id: id))
            .map { names, pokemon in
                PokemonDescription(id: id,
                                   representativeName: names.representativeName,
                                   otherNames: names.otherNames,
                                   size: pokemon.size,
                                   weight: pokemon.weight,
                                   hasThumbnail: pokemon.thumbnailUrl != nil)
            }
    }
    
    func thumbnail(id: PokemonId) -> Maybe<Data> {
        return repository.thumbnail(id: id)
    }
}
