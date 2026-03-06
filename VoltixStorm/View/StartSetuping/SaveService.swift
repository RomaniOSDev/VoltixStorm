//
//  SaveService.swift
//  4KeyMaster
//
//  Created by Damon Earley on 14.02.2026.
//

import Foundation

struct SaveService {
    
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: "LastUrl") }
        set { UserDefaults.standard.set(newValue, forKey: "LastUrl") }
    }
}
