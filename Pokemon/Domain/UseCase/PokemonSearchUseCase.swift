//
//  PokemonSearchUseCase.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/07.
//

import Foundation
import RxSwift

struct SearchedPokemon {
    let id: PokemonId
    let matchedName: String
}

protocol PokemonSearchUseCase {
    func search(keyword: String) -> Single<[SearchedPokemon]>
}

struct PokemonSearchDefaultUseCase: PokemonSearchUseCase {
    let nameRepository: PokemonNameRepository
    
    func search(keyword: String) -> Single<[SearchedPokemon]> {
        return nameRepository.allNames()
            .map { self.matchNames(keyword: keyword, names: $0) }
    }
    
    private func matchNames(keyword: String, names: [PokemonName]) -> [SearchedPokemon] {
        return names.compactMap {
            if let matchingName = $0.matchingName(keyword: keyword) {
                return SearchedPokemon(id: $0.id, matchedName: matchingName)
            }
            
            return nil
        }
    }
}

private extension PokemonName {
    func matchingName(keyword: String) -> String? {
        let lowercasedKeyword = keyword.lowercased()
        
        return allNames.first { $0.lowercased().contains(lowercasedKeyword) }
    }
}
