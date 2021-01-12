//
//  PokemonName.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/07.
//

import Foundation

struct PokemonName {
    let id: PokemonId
    
    let representativeName: String
    let otherNames: [String]
    
    var allNames: [String] {
        return [representativeName] + otherNames
    }
}
