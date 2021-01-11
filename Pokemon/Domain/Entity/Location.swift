//
//  Location.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/08.
//

import Foundation

struct Location {
    let latitude: Double
    let longitude: Double
}

struct PokemonLocation {
    let id: PokemonId
    let location: Location
}
