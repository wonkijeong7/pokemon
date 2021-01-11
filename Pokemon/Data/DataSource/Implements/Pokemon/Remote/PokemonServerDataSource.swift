//
//  PokemonServerDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

class PokemonServerDataSource: PokemonRemoteDataSource, ModelRequestable {
    var jsonRequester: JsonRequestable
    
    init(jsonRequester: JsonRequestable) {
        self.jsonRequester = jsonRequester
    }
    
    func pokemon(id: PokemonId) -> Single<Pokemon> {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)")!
        
        return request(url: url, responseType: PokemonModel.self)
            .map {
                return Pokemon(id: id,
                               height: Double($0.height),
                               weight: Double($0.weight),
                               thumbnailUrl: $0.thumbnailUrl)
            }
    }
}
