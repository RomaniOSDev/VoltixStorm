//
//  SceneDelegate.swift
//  VoltixStorm
//
//  Created by Doras Choenholz on 23.02.2026.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let targetVersionString = "04.03.2026"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let targetDate = dateFormatter.date(from: targetVersionString) ?? Date()
        let currentDate = Date()
        
        if currentDate < targetDate {
            window.rootViewController = UIHostingController(rootView: ContentView())
        }else{
            window.rootViewController = makeInitialViewController()
        }
        
        window.makeKeyAndVisible()
    }

    private func makeInitialViewController() -> UIViewController {
        let persistence = PersistenceManager.shared
        
        if persistence.hasShownContentView {
            print("📱 ContentView был показан ранее, показываем ContentView")
            return UIHostingController(rootView: ContentView())
        }

        if let savedUrlString = persistence.savedUrl,
           !savedUrlString.isEmpty,
           URL(string: savedUrlString) != nil {
            print("🌐 Restoring saved URL:", savedUrlString)
            let webViewContainer = PrivacyWebView(
                urlString: savedUrlString,
                onFailure: {
                    print("❌ Saved URL недоступен, показываем ContentView")
                    persistence.hasShownContentView = true
                },
                onSuccess: {
                    print("✅ Saved URL успешно загружен")
                }
            )
            return UIHostingController(rootView: webViewContainer)
        }

        print("first lunch")
        return StartMainView()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

