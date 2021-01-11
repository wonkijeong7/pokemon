//
//  AppDelegate.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/07.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    lazy var mainContainer = MainContainer()
    
    var disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        updateData()
        initializeView()
        
        return true
    }
    
    private func updateData() {
        mainContainer.descriptionUseCase().updateMetadata()
            .subscribe()
            .disposed(by: disposeBag)
        
        mainContainer.locationUseCase().updateKnownLocations()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func initializeView() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        
        let searchViewController = mainContainer.searchViewController()
        let navigationController = UINavigationController(rootViewController: searchViewController)
        
        window.rootViewController = navigationController
        
        self.window = window
    }
}

