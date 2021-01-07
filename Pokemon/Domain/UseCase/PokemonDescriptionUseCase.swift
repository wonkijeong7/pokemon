//
//  PokemonDescriptionUseCase.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/07.
//

import Foundation
import RxSwift

struct PokemonDescription {
    let pokemon: Pokemon
    let thumbnail: Data?
}

protocol PokemonDescriptionUseCase {
    func description(id: PokemonId) -> Single<PokemonDescription>
}

struct PokemonDescriptionDefaultUseCase: PokemonDescriptionUseCase {
    let descriptionRepository: PokemonDescriptionRepository
    
    func description(id: PokemonId) -> Single<PokemonDescription> {
        return descriptionRepository.description(id: id)
    }
}
