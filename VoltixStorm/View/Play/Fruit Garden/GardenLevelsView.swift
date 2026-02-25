//
//  GardenLevelsView.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 23.02.2026.
//

import SwiftUI

struct GardenLevelsView: View {
    
    private var levelRows: [[Int]] {
        [[1], [2, 3], [4], [5, 6], [7], [8, 9], [10]]
    }
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("SELECT LEVEL:")
                    .foregroundStyle(.white)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(Array(levelRows.enumerated()), id: \.offset) { _, row in
                            HStack(spacing: 120) {
                                ForEach(row, id: \.self) { levelNum in
                                    NavigationLink {
                                        if let levelData = GardenLevelData.data(for: levelNum) {
                                            GardenGameView(levelData: levelData)
                                        }
                                    } label: {
                                        LevelCell(levelNumber: levelNum)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        GardenLevelsView()
    }
}
