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
    
    init(userDefaults: UserDefaults, dataKey: String) {
        self.userDefaults = userDefaults
        self.dataKey = dataKey
    }
    
    var names: Single<[PokemonName]> {
        guard let encodedData = userDefaults.data(forKey: dataKey) else {
            return .just([])
        }
        
        do {
            return .just(try PropertyListDecoder().decode([PokemonName].self, from: encodedData))
        } catch {
            userDefaults.removeObject(forKey: dataKey)
            return .just([])
        }
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
    }
    
    func clear() -> Completable {
        userDefaults.removeObject(forKey: dataKey)
        userDefaults.synchronize()
        
        return .empty()
    }
}
