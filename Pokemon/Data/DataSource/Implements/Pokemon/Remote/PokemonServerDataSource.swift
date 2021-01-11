//
//  PokemonServerDataSource.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

class PokemonServerDataSource: PokemonRemoteDataSource, ModelRequestable {
    let jsonRequester: JsonRequestable
    let downloadRequester: DownloadRequestable
    
    init(jsonRequester: JsonRequestable,
         downloadRequester: DownloadRequestable) {
        self.jsonRequester = jsonRequester
        self.downloadRequester = downloadRequester
    }
    
    func pokemon(id: PokemonId) -> Single<Pokemon> {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)")!
        
        return request(url: url, responseType: PokemonModel.self)
            .map {
                return Pokemon(id: id,
                               height: Double($0.height),
                               weight: Double($0.weight),
                               thumbnailUrl: $0.thumbnailUrl)
            }
    }
    
    func thumbnail(url: URL) -> Single<Data> {
        return downloadRequester.download(url: url)
    }
}
