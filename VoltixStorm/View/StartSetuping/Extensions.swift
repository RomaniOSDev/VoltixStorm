//
//  Extensions.swift
//  VoltixStorm
//
//  Created by Doras Choenholz on 23.02.2026.
//

import Foundation
import AppsFlyerLib

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        let finalURL = buildUniversalAppsflyerURL(from: data)
        print("✅ Final AppsFlyer URL: \(finalURL)")
        UserDefaults.standard.set(finalURL, forKey: "finalAppsflyerURL")
        NotificationCenter.default.post(name: Notification.Name("AppsFlyerDataReceived"), object: nil)
    }

    func onConversionDataFail(_ error: Error) {
        print("❌ Conversion data error: \(error.localizedDescription)")
        let fallbackURL = buildFallbackURL()
        UserDefaults.standard.set(fallbackURL, forKey: "finalAppsflyerURL")
        NotificationCenter.default.post(name: Notification.Name("AppsFlyerDataReceived"), object: nil)
    }
}

// MARK: - Universal Parser & URL Builder

extension AppDelegate {
    /// Builds universal URL from all AppsFlyer data + campaign as full value with sub1..sub5 parsed by "_"
    func buildUniversalAppsflyerURL(from data: [AnyHashable: Any]) -> String {
        let appsflyerID = AppsFlyerLib.shared().getAppsFlyerUID()
        var flatData = flattenDictionary(data)
        flatData["appsflyer_id"] = appsflyerID

        if isOrganicInstall(data) {
            flatData["source"] = "organic"
        }

        // Campaign: keep full raw value and add sub1..sub5 from splitting by "_" (sub1=first segment, sub2=second, ...)
        if let rawCampaign = (flatData["campaign"] as? String) ?? (data["campaign"] as? String), !rawCampaign.isEmpty {
            flatData["campaign"] = rawCampaign
            let parts = rawCampaign.components(separatedBy: "_")
            flatData["sub1"] = parts.indices.contains(0) ? parts[0] : "___"
            flatData["sub2"] = parts.indices.contains(1) ? parts[1] : "___"
            flatData["sub3"] = parts.indices.contains(2) ? parts[2] : "___"
            flatData["sub4"] = parts.indices.contains(3) ? parts[3] : "___"
            flatData["sub5"] = parts.indices.contains(4) ? parts[4] : "___"
        }

        return flatData
            .sorted { $0.key < $1.key }
            .map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "\(value)"
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")
    }

    /// Рекурсивно "сплющивает" любые словари / массивы в плоский [String: Any]
    private func flattenDictionary(_ dictionary: [AnyHashable: Any], prefix: String? = nil) -> [String: Any] {
        var result: [String: Any] = [:]

        for (key, value) in dictionary {
            guard let keyString = key as? String else { continue }
            let newKey = prefix != nil ? "\(prefix!).\(keyString)" : keyString

            switch value {
            case let dict as [String: Any]:
                result.merge(flattenDictionary(dict, prefix: newKey)) { current, _ in current }
            case let dict as [AnyHashable: Any]:
                result.merge(flattenDictionary(dict, prefix: newKey)) { current, _ in current }
            case let array as [Any]:
                for (index, element) in array.enumerated() {
                    let arrayKey = "\(newKey)[\(index)]"
                    if let elementDict = element as? [String: Any] {
                        result.merge(flattenDictionary(elementDict, prefix: arrayKey)) { current, _ in current }
                    } else {
                        result[arrayKey] = element
                    }
                }
            case let num as NSNumber:
                // Обрабатываем Bool/Int/Double
                if CFGetTypeID(num) == CFBooleanGetTypeID() {
                    result[newKey] = num.boolValue ? "true" : "false"
                } else {
                    result[newKey] = num
                }
            case let string as String:
                result[newKey] = string
            default:
                result[newKey] = "\(value)"
            }
        }
        return result
    }

    /// Проверяет органическую установку
    private func isOrganicInstall(_ data: [AnyHashable: Any]) -> Bool {
        guard let dict = data as? [String: Any] else { return true }
        if let afStatus = dict["af_status"] as? String {
            return afStatus.caseInsensitiveCompare("Organic") == .orderedSame
        }
        return false
    }

    /// URL при ошибке получения данных
    private func buildFallbackURL() -> String {
        let appsflyerID = AppsFlyerLib.shared().getAppsFlyerUID()
        return "appsflyer_id=\(appsflyerID)&source=organic&error=conversion_data_failed"
    }
}
