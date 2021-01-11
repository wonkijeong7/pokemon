//
//  PokemonCacheDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

class PokemonCacheDataSource: PokemonLocalDataSource {
    var dictionary: [PokemonId: Pokemon] = [:]
    let schedular = SerialDispatchQueueScheduler(qos: .default)
    
    func pokemon(id: PokemonId) -> Single<Pokemon> {
        return Single.create { [dictionary] single -> Disposable in
            if let pokemon = dictionary[id] {
                single(.success(pokemon))
            } else {
                single(.error(PokemonLocalDataSourceError.notExists(id: id)))
            }
            
            return Disposables.create()
        }
        .subscribeOn(schedular)
    }
    
    func setPokemon(_ pokemon: Pokemon) -> Completable {
        return Completable.create { [weak self] completable -> Disposable in
            self?.dictionary[pokemon.id] = pokemon
            
            completable(.completed)
            
            return Disposables.create()
        }
        .subscribeOn(schedular)
    }
}
