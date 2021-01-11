//
//  PokemonNameModel.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation

struct PokemonMetadataJsonModel: Decodable {
    var pokemons: FailableDecodableArray<PokemonNameModel>
}

struct PokemonNameModel: Decodable {
    let id: Int
    let names: [String]
}
