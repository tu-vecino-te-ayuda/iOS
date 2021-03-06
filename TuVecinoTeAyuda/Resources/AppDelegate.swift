//
//  AppDelegate.swift
//  
//
//  Created by Kiszaner on 20/03/2020.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?
    var navigationController = UINavigationController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = makeCoordinator()
        window?.makeKeyAndVisible()
        
        coordinator?.start()
    }
    
    private func makeCoordinator() -> UINavigationController {
        navigationController.navigationBar.barTintColor = Constants.Colors.main
        let service = Service(baseUrl: API.baseURL)
        coordinator = Coordinator(navigationController: navigationController, service: service)
        return navigationController
    }
}

