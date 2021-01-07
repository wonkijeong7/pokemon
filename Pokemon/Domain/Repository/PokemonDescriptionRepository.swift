//
//  PokemonDescriptionRepository.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/08.
//

import Foundation
import RxSwift

protocol PokemonDescriptionRepository {
    func description(id: PokemonId) -> Single<PokemonDescription>
}
