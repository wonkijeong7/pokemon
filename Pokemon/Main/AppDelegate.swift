//
//  AppDelegate.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/07.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    lazy var mainContainer = MainContainer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initWindow()
        
        let searchViewController = mainContainer.searchViewController()
        let navigationController = UINavigationController(rootViewController: searchViewController)
        
        window?.rootViewController = navigationController
        
        return true
    }
    
    private func initWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        
        self.window = window
    }
}

