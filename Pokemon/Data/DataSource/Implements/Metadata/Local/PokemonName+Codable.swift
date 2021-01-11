//
//  PokemonName+Codable.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation

extension PokemonName: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case representativeName
        case otherNames
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(PokemonId.self, forKey: .id)
        representativeName = try container.decode(String.self, forKey: .representativeName)
        otherNames = try container.decode([String].self, forKey: .otherNames)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(representativeName, forKey: .representativeName)
        try container.encode(otherNames, forKey: .otherNames)
    }
}
