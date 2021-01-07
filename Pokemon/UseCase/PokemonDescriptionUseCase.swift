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

protocol PokemonUseCase {
    func description(id: PokemonId) -> Single<PokemonDescription>
    func knownLocation(id: PokemonId) -> Maybe<Location>
}
