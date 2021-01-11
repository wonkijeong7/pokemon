//
//  PokemonLocationServerDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

class PokemonLocationServerDataSource: PokemonLocationRemoteDataSource, ModelRequestable {
    var jsonRequester: JsonRequestable
    
    init(jsonRequester: JsonRequestable) {
        self.jsonRequester = jsonRequester
    }
    
    func fetchKnownLocations() -> Single<[PokemonId: [Location]]> {
        let url = URL(string: "https://demo0928971.mockable.io/pokemon_locations")!
        
        return request(url: url, responseType: PokemonLocationModel.self)
            .map {
                var locations: [PokemonId: [Location]] = [:]
                
                $0.pokemons.elements.forEach {
                    var elements: [Location] = locations[$0.id] ?? []
                    
                    elements.append(Location(latitude: $0.lat, longitude: $0.lng))
                    
                    locations[$0.id] = elements
                }
                
                return locations
            }
    }
}
