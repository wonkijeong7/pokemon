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
