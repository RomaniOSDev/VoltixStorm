//
//  ContentView.swift
//  VoltixStorm
//
//  Created by Doras Choenholz on 23.02.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isPresented: Bool = false
    @State private var isActive: Bool = false
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            VStack {
                Image(.mainlabel)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Button {
                    isPresented = true
                } label: {
                    Image(.playutton)
                        .resizable()
                        .frame(width: 180, height: 180)
                        .scaleEffect(isActive ? 1.1 : 1)
                }

            }
            .animation(.bouncy, value: isActive)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { _ in
                    isActive.toggle()
                })
            }
            .padding()
            .fullScreenCover(isPresented: $isPresented) {
                MainView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .dismissToMainPage)) { _ in
                isPresented = false
            }
        }
    }
}

#Preview {
    ContentView()
}
