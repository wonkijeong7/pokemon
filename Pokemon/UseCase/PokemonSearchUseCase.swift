//
//  PokemonSearchUseCase.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/07.
//

import Foundation
import RxSwift

struct SearchedPokemon {
    let id: PokemonId
    let matchedName: String
}

protocol PokemonSearchUseCase {
    func search(keyword: String) -> Single<[SearchedPokemon]>
}
