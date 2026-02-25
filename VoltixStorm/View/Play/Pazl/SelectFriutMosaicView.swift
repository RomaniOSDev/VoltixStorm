//
//  SelectFriutMosaicView.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 24.02.2026.
//

import SwiftUI

struct SelectFriutMosaicView: View {
    @State private var currentIndex: Int = 0
    
    private var currentImage: MosaicImage {
        let all = MosaicImage.allCases
        let clampedIndex = min(max(currentIndex, 0), all.count - 1)
        return all[clampedIndex]
    }
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("SELECT MOSAIC:")
                    .foregroundStyle(.white)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                
                // большая картинка выбранного пазла
                ZStack {
                    Image(.backQuestion)
                        .resizable()
                    VStack {
                        Image(currentImage.assetName)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding()
                            
                        NavigationLink {
                            FruitMosaicGameView(image: currentImage)
                        } label: {
                            MainPinkBTNView(label: "start", height: 70)
                        }.padding(.horizontal, 30)
                    }.padding()
                }
               
                
                // кнопки переключения пазлов
                HStack(spacing: 40) {
                    Button {
                        withAnimation(.easeInOut) {
                            let all = MosaicImage.allCases
                            currentIndex = (currentIndex - 1 + all.count) % all.count
                        }
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(.white)
                    }
                    
                    
                    
                    Button {
                        withAnimation(.easeInOut) {
                            let all = MosaicImage.allCases
                            currentIndex = (currentIndex + 1) % all.count
                        }
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding()
        }
    }
}

enum MosaicImage: String, CaseIterable, Identifiable {
    case pazl1
    case pazl2
    case pazl3
    
    var id: String { rawValue }
    
    var assetName: String { rawValue }
}

#Preview {
    NavigationStack {
        SelectFriutMosaicView()
    }
}
