//
//  OneSignalManager.swift
//  4KeyMaster
//
//  Created by Damon Earley on 14.02.2026.
//

import UIKit
import OneSignalFramework
import AppsFlyerLib

final class OneSignalManager {
    static let shared = OneSignalManager()

    private let appId = "a747b5d7-83e2-4d6c-ad01-6faa99679eec"
    private var storedLaunchOptions: [UIApplication.LaunchOptionsKey: Any]?
    private var hasInitialized = false
    private var pendingAppsFlyerId: String?

    private init() {}

    func storeLaunchOptions(_ options: [UIApplication.LaunchOptionsKey: Any]?) {
        storedLaunchOptions = options
    }

    func configure() {
        guard !hasInitialized else { return }
        hasInitialized = true

        OneSignal.initialize(appId, withLaunchOptions: storedLaunchOptions)
        OneSignal.Notifications.requestPermission(
            { accepted in
                print("OneSignal push permission: \(accepted)")
            },
            fallbackToSettings: true
        )

        performLogin()
    }

    func login(appsFlyerId: String?) {
        if let id = appsFlyerId, !id.isEmpty {
            pendingAppsFlyerId = id
            if hasInitialized {
                performLogin()
            }
        }
    }

    private func performLogin() {
        let id = pendingAppsFlyerId ?? AppsFlyerLib.shared().getAppsFlyerUID()
        guard !id.isEmpty else { return }
        OneSignal.login(id)
        pendingAppsFlyerId = nil
    }
}
