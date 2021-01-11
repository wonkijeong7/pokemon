//
//  PokemonRemoteDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

protocol PokemonRemoteDataSource {
    func pokemon(id: PokemonId) -> Single<Pokemon>
    
    func thumbnail(url: URL) -> Single<Data>
}
