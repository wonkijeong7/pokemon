//
//  PokemonMetadataUserDefaultsDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

class PokemonMetadataUserDefaultsDataSource: PokemonMetadataLocalDataSource {
    let userDefaults: UserDefaults
    let dataKey: String
    let scheduler = SerialDispatchQueueScheduler(qos: .default)
    
    init(userDefaults: UserDefaults, dataKey: String) {
        self.userDefaults = userDefaults
        self.dataKey = dataKey
    }
    
    var names: Single<[PokemonName]> {
        return Single.create { [userDefaults, dataKey] single -> Disposable in
            let disposable = Disposables.create()
            
            guard let encodedData = userDefaults.data(forKey: dataKey) else {
                single(.success([]))
                return disposable
            }
            
            do {
                let names = try PropertyListDecoder().decode([PokemonName].self, from: encodedData)
                
                single(.success(names))
            } catch {
                userDefaults.removeObject(forKey: dataKey)
                userDefaults.synchronize()
                
                single(.error(error))
            }

            return disposable
        }
        .subscribeOn(scheduler)
    }
    
    func setNames(_ names: [PokemonName]) -> Completable {
        return Completable.create { [userDefaults, dataKey] completable -> Disposable in
            do {
                let encoded = try PropertyListEncoder().encode(names)
                userDefaults.set(encoded, forKey: dataKey)
                userDefaults.synchronize()
                
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
        .subscribeOn(scheduler)
    }
    
    func clear() -> Completable {
        return Completable.create { [userDefaults, dataKey] completable -> Disposable in
            userDefaults.removeObject(forKey: dataKey)
            userDefaults.synchronize()
            
            completable(.completed)
            
            return Disposables.create()
        }
        .subscribeOn(scheduler)
    }
}
