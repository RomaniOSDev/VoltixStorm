//
//  SelectLevelQuizView.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 23.02.2026.
//

import SwiftUI

struct SelectLevelQuizView: View {
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Text("SELECT QUIZ LEVEL:")
                    .foregroundStyle(.white)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                
                VStack(spacing: 15) {
                    ForEach(QuizLevel.allCases, id: \.self) { level in
                        NavigationLink {
                            QuizView(level: level)
                        } label: {
                            MainPinkBTNView(label: level.title)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        SelectLevelQuizView()
    }
}
