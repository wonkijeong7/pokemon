//
//  PokemonLocationRemoteDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

protocol PokemonLocationRemoteDataSource {
    func fetchKnownLocations() -> Single<[PokemonLocation]>
}
