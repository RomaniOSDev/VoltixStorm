//
//  LevelCell.swift
//  VoltixStorm
//
//  Created by Doras Choenholz on 24.02.2026.
//

import SwiftUI

struct LevelCell: View {
    var levelNumber: Int
    var hight: CGFloat = 90
    var body: some View {
        ZStack {
            Image(.levelBack)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text("\(levelNumber)")
                .foregroundStyle(.white)
                .font(.system(size: hight/2.5, weight: .bold, design: .serif))
                .minimumScaleFactor(0.5)
                .padding(.bottom, hight/10)
        }
        .frame(width: hight, height: hight)
    }
}

#Preview {
    LevelCell(levelNumber: 2)
}
