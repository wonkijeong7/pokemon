//
//  PokemonLocationDefaultRepository.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

class PokemonLocationDefaultRepository: PokemonLocationRepository {
    let localDataSource: PokemonLocationLocalDataSource
    let remoteDataSource: PokemonLocationRemoteDataSource
    
    init(localDataSource: PokemonLocationLocalDataSource,
         remoteDataSource: PokemonLocationRemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
    
    func update() -> Completable {
        return remoteDataSource.fetchKnownLocations()
            .flatMapCompletable { [localDataSource] in
                localDataSource.setLocations($0)
            }
    }
    
    func knownLocations(id: PokemonId) -> Single<[Location]> {
        return localDataSource.location(id: id)
    }
}
