//
//  OneSignalIDChecker.swift
//  4KeyMaster
//
//  Created by Damon Earley on 14.02.2026.
//

import Foundation
import OneSignalFramework

class OneSignalIDChecker {
    
    private var timer: Timer?
    func startCheckingOneSignalID() {
        stopCheckingOneSignalID()
        timer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(printOneSignalID),
            userInfo: nil,
            repeats: true
        )
    }
    func stopCheckingOneSignalID() {
        timer?.invalidate()
        timer = nil
    }
    
    // Функция, которая будет вызываться таймером
    @objc private func printOneSignalID() {
        _ = OneSignal.User.onesignalId ?? "OneSignal ID не найден"
    }
}
