//
//  PokemonNameUseCase.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/07.
//

import Foundation
import RxSwift

protocol PokemonNameUseCase {
    func update() -> Completable
}

struct PokemonNameDefaultUseCase: PokemonNameUseCase {
    let nameRepository: PokemonNameRepository
    
    func update() -> Completable {
        return nameRepository.update()
    }
}
