//
//  MainPinkBTNView.swift
//  VoltixStorm
//
//  Created by Doras Choenholz on 23.02.2026.
//

import SwiftUI

struct MainPinkBTNView: View {
    var label: String
    var height: CGFloat = 100
    var body: some View {
        ZStack{
            Image(.backForBTNMain)
                .resizable()
            Text(label)
                .foregroundStyle(.white)
                .font(.system(size: height/3, weight: .bold, design: .serif))
                .textCase(.uppercase)
        }.frame(height: height)
    }
}

#Preview {
    MainPinkBTNView(label: "play")
}
