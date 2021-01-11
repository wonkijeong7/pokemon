//
//  Pokemon.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/07.
//

import Foundation

typealias PokemonId = Int

struct Pokemon {
    let id: PokemonId
    
    let height: Double
    let weight: Double
    
    let thumbnailUrl: URL?
}
