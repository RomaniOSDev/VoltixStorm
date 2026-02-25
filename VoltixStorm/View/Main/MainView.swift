//
//  MainView.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 23.02.2026.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image(.mainBack)
                    .resizable()
                    .ignoresSafeArea()
                VStack {
                    Image(.mainlabel)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    VStack(spacing: 15){
                        NavigationLink {
                            PlayView()
                        } label: {
                            MainPinkBTNView(label: "play")
                        }
                        NavigationLink {
                            GameRatingView()
                        } label: {
                            MainPinkBTNView(label: "rating")
                        }
                        NavigationLink {
                            SettingsView()
                        } label: {
                            MainPinkBTNView(label: "settings")
                        }

                    }
                }.padding()
            }
        }
    }
}

#Preview {
    MainView()
}
