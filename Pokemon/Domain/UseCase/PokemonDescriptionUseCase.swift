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
    
    let height: Double
    let weight: Double
    
    let hasThumbnail: Bool
}

protocol PokemonDescriptionUseCase {
    func updateMetadata() -> Completable
    
    func name(id: PokemonId) -> Single<String>
    func description(id: PokemonId) -> Single<PokemonDescription>
    func thumbnail(id: PokemonId) -> Maybe<Data>
}

struct PokemonDescriptionDefaultUseCase: PokemonDescriptionUseCase {
    let repository: PokemonRepository
    
    func updateMetadata() -> Completable {
        return repository.updateMetadata()
    }
    
    func name(id: PokemonId) -> Single<String> {
        return repository.names(id: id)
            .map { $0.representativeName }
    }
    
    func description(id: PokemonId) -> Single<PokemonDescription> {
        return Single.zip(repository.names(id: id), repository.pokemon(id: id))
            .map { names, pokemon in
                PokemonDescription(id: id,
                                   representativeName: names.representativeName,
                                   otherNames: names.otherNames,
                                   height: pokemon.height,
                                   weight: pokemon.weight,
                                   hasThumbnail: pokemon.thumbnailUrl != nil)
            }
    }
    
    func thumbnail(id: PokemonId) -> Maybe<Data> {
        return repository.thumbnail(id: id)
    }
}
