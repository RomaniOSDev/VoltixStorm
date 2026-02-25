//
//  SettingsView.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 25.02.2026.
//

import SwiftUI

struct SettingsView: View {
    @State private var playerName: String = RatingManager.shared.currentPlayerName
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("SETTINGS")
                    .foregroundStyle(.white)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("PLAYER NAME")
                        .foregroundStyle(.goldCol)
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .textCase(.uppercase)
                    
                    TextField("Enter name", text: $playerName)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                        .font(.system(size: 18, weight: .medium, design: .serif))
                }
                .padding(.horizontal, 24)
                
                Button {
                    let trimmed = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
                    RatingManager.shared.currentPlayerName = trimmed
                    playerName = trimmed
                } label: {
                    MainPinkBTNView(label: "save", height: 70)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView()
}

