//
//  MainContainer.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import UIKit
import RxSwift

class MainContainer {
    private let pokemonRepository: PokemonRepository
    private let locationRepository: PokemonLocationRepository
    
    init() {
        let queue = DispatchQueue.global(qos: .default)
        let jsonRequester = AlamofireJsonRequester(queue: queue)
        let downloadRequester = AlamofireDownloadRequester(queue: queue)
        
        let metadataLocalDataSource = PokemonMetadataUserDefaultsDataSource(userDefaults: .standard, dataKey: "metadata")
        let metadataRemoteDataSource = PokemonMetadataServerDataSource(jsonRequester: jsonRequester)
        
        let pokemonLocalDataSource = PokemonCacheDataSource()
        let pokemonRemoteDataSource = PokemonServerDataSource(jsonRequester: jsonRequester, downloadRequester: downloadRequester)
        
        let locationLocalDataSource = PokemonLocationCacheDataSource()
        let locationRemoteDataSource = PokemonLocationServerDataSource(jsonRequester: jsonRequester)
        
        pokemonRepository = PokemonDefaultRepository(metadataLocalDataSource: metadataLocalDataSource,
                                                     metadataRemoteDataSource: metadataRemoteDataSource,
                                                     pokemonLocalDataSource: pokemonLocalDataSource,
                                                     pokemonRemoteDataSource: pokemonRemoteDataSource)
        
        locationRepository = PokemonLocationDefaultRepository(localDataSource: locationLocalDataSource,
                                                              remoteDataSource: locationRemoteDataSource)
    }
    
    func searchUseCase() -> PokemonSearchUseCase {
        return PokemonSearchDefaultUseCase(repository: pokemonRepository)
    }
    
    func descriptionUseCase() -> PokemonDescriptionUseCase {
        return PokemonDescriptionDefaultUseCase(repository: pokemonRepository)
    }
    
    func locationUseCase() -> PokemonLocationUseCase {
        return PokemonLocationDefaultUseCase(locationRepository: locationRepository)
    }
    
    func searchViewController() -> PokemonSearchViewController {
        let viewController = UIStoryboard.initialViewController(name: "PokemonSearch", type: PokemonSearchViewController.self)
        let reactor = PokemonSearchViewReactor(searchUseCase: searchUseCase())
        
        viewController.reactor = reactor
        viewController.descriptionViewProvider = self
        viewController.locationViewProvider = self
        
        return viewController
    }
}

extension MainContainer: PokemonDescriptionViewProvider {
    func descriptionViewController(id: PokemonId, openLocationObserver: AnyObserver<PokemonId>) -> UIViewController {
        let viewController = UIStoryboard.initialViewController(name: "PokemonDescription", type: PokemonDescriptionViewController.self)
        let reactor = PokemonDescriptionViewReactor(pokemonId: id,
                                                    showLocationObserver: openLocationObserver,
                                                    descriptionUseCase: descriptionUseCase(),
                                                    locationUseCase: locationUseCase())
        
        viewController.reactor = reactor
        
        return viewController
    }
}

extension MainContainer: PokemonLocationViewProvider {
    func locationViewController(id: PokemonId) -> UIViewController {
        let viewController = UIStoryboard.initialViewController(name: "PokemonLocation", type: PokemonLocationViewController.self)
        
        let reactor = PokemonLocationViewReactor(pokemonId: id,
                                                 descriptionUseCase: descriptionUseCase(),
                                                 locationUseCase: locationUseCase())
        
        viewController.reactor = reactor
        
        return viewController
    }
}

extension UIStoryboard {
    static func initialViewController<ViewController: UIViewController>(name: String, type: ViewController.Type) -> ViewController {
        let storyboard = UIStoryboard(name: name, bundle: .main)
        
        guard let viewController = storyboard.instantiateInitialViewController() as? ViewController else {
            fatalError("Initial view controller type mismatched: \(name)")
        }
        
        return viewController
    }
}
