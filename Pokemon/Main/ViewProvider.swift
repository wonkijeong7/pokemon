//
//  ViewProvider.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/12.
//

import Foundation
import RxSwift

class ViewProvider {
    let mainContainer: MainContainer
    
    init(mainContainer: MainContainer) {
        self.mainContainer = mainContainer
    }
}

extension ViewProvider: PokemonSearchViewProvider {
    func searchViewController() -> UIViewController {
        let viewController = UIStoryboard.initialViewController(name: "PokemonSearch", type: PokemonSearchViewController.self)
        
        viewController.reactor = mainContainer.searchViewReactor()
        viewController.descriptionViewProvider = self
        viewController.locationViewProvider = self
        
        return viewController
    }
}

extension ViewProvider: PokemonDescriptionViewProvider {
    func descriptionViewController(id: PokemonId, showLocationObserver: AnyObserver<PokemonId>) -> UIViewController {
        let viewController = UIStoryboard.initialViewController(name: "PokemonDescription", type: PokemonDescriptionViewController.self)
        
        viewController.reactor = mainContainer.descriptionViewReactor(id: id, showLocationObserver: showLocationObserver)
        
        return viewController
    }
}

extension ViewProvider: PokemonLocationViewProvider {
    func locationViewController(id: PokemonId) -> UIViewController {
        let viewController = UIStoryboard.initialViewController(name: "PokemonLocation", type: PokemonLocationViewController.self)
        
        viewController.reactor = mainContainer.locationViewReactor(id: id)
        
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
