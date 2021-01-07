//
//  PokemonMetadataUseCase.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/07.
//

import Foundation
import RxSwift

protocol PokemonMetadataUseCase {
    func updateNames() -> Completable
    func updateLocations() -> Completable
}

struct PokemonMetadataDefaultUseCase: PokemonMetadataUseCase {
    let metadataRepository: PokemonMetadataRepository
    
    func updateNames() -> Completable {
        return metadataRepository.updateNames()
    }
    
    func updateLocations() -> Completable {
        return metadataRepository.updateLocations()
    }
}
