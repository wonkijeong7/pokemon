//
//  PokemonLocationCacheDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

class PokemonLocationCacheDataSource: PokemonLocationLocalDataSource {
    var dictionary: [PokemonId: [Location]] = [:]
    let scheduler = SerialDispatchQueueScheduler(qos: .default)
    
    func location(id: PokemonId) -> Single<[Location]> {
        return Single.create { [dictionary] single -> Disposable in
            single(.success(dictionary[id] ?? []))
            
            return Disposables.create()
        }
        .subscribeOn(scheduler)
    }
    
    func setLocations(_ locations: [PokemonId: [Location]]) -> Completable {
        return Completable.create { [weak self] completable -> Disposable in
            self?.dictionary = locations
            
            return Disposables.create()
        }
        .subscribeOn(scheduler)
    }
}
