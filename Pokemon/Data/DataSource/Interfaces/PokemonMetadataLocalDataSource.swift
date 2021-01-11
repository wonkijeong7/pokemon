//
//  PokemonMetadataLocalDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

protocol PokemonMetadataLocalDataSource {
    var names: Single<[PokemonName]> { get }
    
    func setNames(_ names: [PokemonName]) -> Completable
}
