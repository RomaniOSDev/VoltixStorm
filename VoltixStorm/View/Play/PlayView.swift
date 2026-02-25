//
//  PlayView.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 23.02.2026.
//

import SwiftUI

struct PlayView: View {
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            VStack(spacing: 30) {
                Text("SELECT GAME:")
                    .foregroundStyle(.white)
                    .font(.system(size: 30, weight: .bold, design: .serif))
                VStack(spacing: 15){
                    NavigationLink {
                        SelectLevelQuizView()
                    } label: {
                        MainPinkBTNView(label: "mind quiz")
                    }
                    NavigationLink {
                        GardenLevelsView()
                    } label: {
                        MainPinkBTNView(label: "fruit garden")
                    }
                    NavigationLink {
                        SelectFriutMosaicView()
                    } label: {
                        MainPinkBTNView(label: "fruit mosaic")
                    }
                    
                }
            }.padding()
        }
    }
}

#Preview {
    PlayView()
}
