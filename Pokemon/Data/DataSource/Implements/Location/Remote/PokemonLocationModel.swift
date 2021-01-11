//
//  PokemonLocationModel.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation

struct PokemonLocationModel: Decodable {
    let pokemons: FailableDecodableArray<LocationModel>
}

struct LocationModel: Decodable {
    let id: PokemonId
    let lat: Double
    let lng: Double
}
