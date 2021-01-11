//
//  PokemonModel.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation

struct PokemonModel: Decodable {
    let id: PokemonId
    let height: Int
    let weight: Int
    let thumbnailUrl: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case height
        case weight
        case sprites
    }
    
    enum SpriteCoidngKeys: String, CodingKey {
        case front_default
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(PokemonId.self, forKey: .id)
        height = try container.decode(Int.self, forKey: .height)
        weight = try container.decode(Int.self, forKey: .weight)
        
        let spritesContainer = try container.nestedContainer(keyedBy: SpriteCoidngKeys.self, forKey: .sprites)
        
        var thumbnailUrl: URL? = nil
        if let url = try spritesContainer.decodeUrlIfPresent(forKey: .front_default) {
            thumbnailUrl = url
        } else if let dictionary = try? container.decode([String: String].self, forKey: .sprites) {
            if let urlString = dictionary.first(where: { URL(string: $1) != nil })?.value {
                thumbnailUrl = URL(string: urlString)
            }
        }
        
        self.thumbnailUrl = thumbnailUrl
    }
}
