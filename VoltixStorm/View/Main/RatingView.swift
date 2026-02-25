//
//  RatingView.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 25.02.2026.
//

import SwiftUI

struct GameRatingView: View {
    @State private var entries: [RatingEntry] = []
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("RATING")
                    .foregroundStyle(.white)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                            ratingRow(position: index + 1, entry: entry)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding()
        }
        .onAppear {
            load()
        }
    }
    
    private func load() {
        let all = RatingManager.shared.loadEntries()
        // сортировка по очкам (убывание)
        entries = all.sorted { $0.points > $1.points }
    }
    
    private func ratingRow(position: Int, entry: RatingEntry) -> some View {
        ZStack {
            Image(.backQuestion)
                .resizable()
            HStack {
                Text("\(position)")
                    .foregroundStyle(.goldCol)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .frame(width: 40, alignment: .leading)
                
                Text(entry.name)
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(entry.points)")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .frame(width: 80, alignment: .trailing)
            }
            .padding()
        }
        .frame(height: 65)
    }
}

#Preview {
    GameRatingView()
}

