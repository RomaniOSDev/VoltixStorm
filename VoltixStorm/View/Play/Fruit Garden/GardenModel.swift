//
//  GardenModel.swift
//  VoltixStorm
//
//  Created by Doras Choenholz on 23.02.2026.
//

import SwiftUI

/// Fruit types matching asset names in Assets.xcassets/garden/
enum GardenFruit: String, CaseIterable, Identifiable {
    case banan
    case blueburry
    case chery
    case grape
    case lemon
    case plum
    case watermelon
    
    var id: String { rawValue }
    
    var imageName: String { rawValue }
    
    var displayName: String {
        switch self {
        case .banan: return "Banana"
        case .blueburry: return "Blueberry"
        case .chery: return "Cherry"
        case .grape: return "Grape"
        case .lemon: return "Lemon"
        case .plum: return "Plum"
        case .watermelon: return "Watermelon"
        }
    }
}

struct GardenLevelGoal: Identifiable {
    let id = UUID()
    let fruit: GardenFruit
    let target: Int
}

struct GardenLevelData: Identifiable {
    let id: Int
    let goals: [GardenLevelGoal]
    
    static let levels: [GardenLevelData] = (1...10).map { levelNum in
        let allFruits = GardenFruit.allCases
        let idx1 = (levelNum - 1) % allFruits.count
        var idx2 = (levelNum) % allFruits.count
        if idx2 == idx1 { idx2 = (idx2 + 1) % allFruits.count }
        let fruit1 = allFruits[idx1]
        let fruit2 = allFruits[idx2]
        let target = min(8 + levelNum, 15)
        return GardenLevelData(
            id: levelNum,
            goals: [
                GardenLevelGoal(fruit: fruit1, target: target),
                GardenLevelGoal(fruit: fruit2, target: target)
            ]
        )
    }
    
    static func data(for levelNumber: Int) -> GardenLevelData? {
        levels.first { $0.id == levelNumber }
    }
}
