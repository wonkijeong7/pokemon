//
//  PokemonMetadataServerDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

class PokemonMetadataServerDataSource: PokemonMetadataRemoteDataSource, ModelRequestable {
    let jsonRequester: JsonRequestable
    
    init(jsonRequester: JsonRequestable) {
        self.jsonRequester = jsonRequester
    }
    
    func fetchNames() -> Single<[PokemonName]> {
        let url = URL(string: "https://demo0928971.mockable.io/pokemon_name")!
        
        return request(url: url, responseType: PokemonMetadataJsonModel.self)
            .map {
                return $0.pokemons.elements.compactMap {
                    guard let firstName = $0.names.first else { return nil }
                    
                    return PokemonName(id: $0.id,
                                       representativeName: firstName,
                                       otherNames: Array($0.names.dropFirst()))
                }
            }
    }
}
