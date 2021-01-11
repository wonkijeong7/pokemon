//
//  PokemonDefaultRepository.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/08.
//

import Foundation
import RxSwift

class PokemonDefaultRepository: PokemonRepository {
    let metadataLocalDataSource: PokemonMetadataLocalDataSource
    let metadataRemoteDataSource: PokemonMetadataRemoteDataSource
    let pokemonLocalDataSource: PokemonLocalDataSource
    let pokemonRemoteDataSource: PokemonRemoteDataSource
    
    init(metadataLocalDataSource: PokemonMetadataLocalDataSource,
         metadataRemoteDataSource: PokemonMetadataRemoteDataSource,
         pokemonLocalDataSource: PokemonLocalDataSource,
         pokemonRemoteDataSource: PokemonRemoteDataSource) {
        self.metadataLocalDataSource = metadataLocalDataSource
        self.metadataRemoteDataSource = metadataRemoteDataSource
        self.pokemonLocalDataSource = pokemonLocalDataSource
        self.pokemonRemoteDataSource = pokemonRemoteDataSource
    }
    
    func updateMetadata() -> Completable {
        return metadataRemoteDataSource.fetchNames()
            .flatMapCompletable { [metadataLocalDataSource] in
                metadataLocalDataSource.setNames($0)
            }
    }
    
    func allNames() -> Single<[PokemonName]> {
        return metadataLocalDataSource.names
    }
    
    func names(id: PokemonId) -> Single<PokemonName> {
        return metadataLocalDataSource.names
            .map {
                guard let names = $0.first(where: { $0.id == id }) else {
                    throw PokemonRepositoryError.notExists(id: id)
                }
                
                return names
            }
    }
    
    func pokemon(id: PokemonId) -> Single<Pokemon> {
        return .never()
    }
    
    func thumbnail(id: PokemonId) -> Maybe<Data> {
        return .empty()
    }
}
