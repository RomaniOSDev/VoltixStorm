//
//  FruitMosaicGameView.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 24.02.2026.
//

import SwiftUI

struct FruitMosaicGameView: View {
    let image: MosaicImage
    
    // 3 столбца × 4 строки = 12 ячеек, одна пустая
    private let columns = 3
    private let rows = 4
    private var tileCount: Int { columns * rows }
    private var emptyTileIndex: Int { tileCount - 1 }
    
    /// Текущий порядок кусочков на поле (перестановка 0...11, последний — пустой)
    @State private var tiles: [Int] = []
    @State private var isCompleted: Bool = false
    
    // Таймер 3 минуты
    @State private var remainingTime: Int = 180
    @State private var timer: Timer? = nil
    @State private var isPaused: Bool = false
    @State private var showPauseOverlay: Bool = false
    
    // Завершение уровня (успех / провал по таймеру)
    @State private var showEndOverlay: Bool = false
    @State private var isWin: Bool = false
    @State private var didAddToRating: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                GeometryReader { geo in
                    let tileSize = min(geo.size.width / CGFloat(columns),
                                       geo.size.height * 0.55 / CGFloat(rows))
                    let puzzleWidth = tileSize * CGFloat(columns)
                    let puzzleHeight = tileSize * CGFloat(rows)
                    let puzzleSize = CGSize(width: puzzleWidth, height: puzzleHeight)
                    
                    ZStack {
                        Image(.backQuestion)
                            .resizable()
                        // одно поле 3x4 с перемешанными кусочками поверх рамки
                        puzzleBoard(tileSize: tileSize, puzzleSize: puzzleSize)
                            .frame(width: puzzleWidth, height: puzzleHeight)
                    }
                    .padding(-20)
                    .frame(width: puzzleWidth, height: puzzleHeight)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                
                // таймер под пазлом
                Text(formattedTime)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
                
            }
            .padding()
            
            if showEndOverlay {
                completedOverlay
            }
            
            if showPauseOverlay {
                pauseOverlay
            }
        }
        .onAppear {
            setupPuzzle()
            startTimer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPaused = true
                    showPauseOverlay = true
                } label: {
                    Image(.pauseBN)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // MARK: - Board & tray
    
    private func puzzleBoard(tileSize: CGFloat, puzzleSize: CGSize) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<columns, id: \.self) { col in
                        let index = row * columns + col
                        boardCell(index: index,
                                  tileSize: tileSize,
                                  puzzleSize: puzzleSize)
                    }
                }
            }
        }
    }
    
    private func boardCell(index: Int,
                           tileSize: CGFloat,
                           puzzleSize: CGSize) -> some View {
        let tileId = tiles.indices.contains(index) ? tiles[index] : index
        
        return Button {
            handleBoardTap(at: index)
        } label: {
            ZStack {
                pieceImage(tileId: tileId,
                           tileSize: tileSize,
                           puzzleSize: puzzleSize)
            }
            .overlay(
                Rectangle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .frame(width: tileSize, height: tileSize)
    }
    
    // MARK: - Piece image
    
    @ViewBuilder
    private func pieceImage(tileId: Int,
                            tileSize: CGFloat,
                            puzzleSize: CGSize) -> some View {
        // пустая ячейка
        if tileId == emptyTileIndex {
            Color.clear
                .frame(width: tileSize, height: tileSize)
        } else if image == .pazl1 {
            // Для первой картинки — кусочки p1...p11
            let name = "p\(tileId + 1)"
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: tileSize, height: tileSize)
                .clipped()
        } else if image == .pazl2 {
            // Для второй картинки — кусочки q1...q11
            let name = "q\(tileId + 1)"
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: tileSize, height: tileSize)
                .clipped()
        } else if image == .pazl3 {
            // Для третьей картинки — кусочки w1...w11
            let name = "w\(tileId + 1)"
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: tileSize, height: tileSize)
                .clipped()
        } else {
            // Для остальных — нарезаем исходное изображение
            let originalRow = tileId / columns
            let originalCol = tileId % columns
            let fullTileWidth = puzzleSize.width / CGFloat(columns)
            let fullTileHeight = puzzleSize.height / CGFloat(rows)
            
            Image(image.assetName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: puzzleSize.width, height: puzzleSize.height)
                .offset(x: -CGFloat(originalCol) * fullTileWidth,
                        y: -CGFloat(originalRow) * fullTileHeight)
                .frame(width: fullTileWidth, height: fullTileHeight)
                .clipped()
                .frame(width: tileSize, height: tileSize)
        }
    }
    
    // MARK: - Logic
    
    private func setupPuzzle() {
        // стартовое состояние: собранный пазл, последний индекс — пустой
        tiles = Array(0..<tileCount)
        
        // перемешиваем через последовательность валидных ходов, чтобы пазл оставался решаемым
        var emptyPos = emptyTileIndex
        for _ in 0..<80 {
            let neighbors = neighborsOf(index: emptyPos)
            if let moveTo = neighbors.randomElement() {
                tiles.swapAt(emptyPos, moveTo)
                emptyPos = moveTo
            }
        }
        
        // если вдруг вернулись в исходное состояние — перемешаем ещё раз
        if tiles == Array(0..<tileCount) {
            tiles.swapAt(0, 1)
        }
        isCompleted = false
        remainingTime = 180
        didAddToRating = false
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if remainingTime > 0 && !isCompleted && !isPaused {
                remainingTime -= 1
            } else {
                // время вышло или игра завершена
                if remainingTime <= 0 && !isCompleted {
                    isWin = false
                    showEndOverlay = true
                }
                t.invalidate()
            }
        }
    }
    
    private var formattedTime: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func handleBoardTap(at index: Int) {
        guard !isCompleted, remainingTime > 0 else { return }
        guard let emptyPos = tiles.firstIndex(of: emptyTileIndex) else { return }
        
        // двигать можно только соседний по вертикали/горизонтали кусок, рядом с пустой ячейкой
        if neighborsOf(index: emptyPos).contains(index) {
            withAnimation(.easeInOut(duration: 0.15)) {
                tiles.swapAt(emptyPos, index)
            }
            checkCompleted()
        }
    }
    
    /// Соседи по сетке (вверх/вниз/влево/вправо)
    private func neighborsOf(index: Int) -> [Int] {
        let row = index / columns
        let col = index % columns
        var result: [Int] = []
        
        if row > 0 { result.append((row - 1) * columns + col) }
        if row < rows - 1 { result.append((row + 1) * columns + col) }
        if col > 0 { result.append(row * columns + (col - 1)) }
        if col < columns - 1 { result.append(row * columns + (col + 1)) }
        
        return result
    }
    
    private func checkCompleted() {
        let correct = (0..<tileCount).allSatisfy { tiles.indices.contains($0) && tiles[$0] == $0 }
        if correct {
            isCompleted = true
            timer?.invalidate()
            isWin = true
            showEndOverlay = true
            if !didAddToRating {
                let name = RatingManager.shared.currentPlayerName
                if !name.isEmpty {
                    RatingManager.shared.addPoints(10, forPlayer: name)
                    didAddToRating = true
                }
            }
        }
    }
    
    // MARK: - Completed overlay
    
    private var completedOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            ZStack {
                Image(.backQuestion)
                    .resizable()
                VStack(spacing: 24) {
                    Text(isWin ? "Level Completed!" : "Level Failed!")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text(isWin
                         ? "The Mosaic is complete — ready for the next one?"
                         : "The Mosaic is not complete — try again.")
                        .font(.system(size: 20, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 15) {
                        Button {
                            setupPuzzle()
                            startTimer()
                            isWin = false
                            showEndOverlay = false
                        } label: {
                            MainPinkBTNView(label: "restart", height: 70)
                        }
                        Button {
                            dismiss()
                        } label: {
                            MainPinkBTNView(label: "back", height: 70)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .frame(height: 500)
        }
    }

    // MARK: - Pause overlay
    
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            ZStack {
                Image(.backQuestion)
                    .resizable()
                VStack(spacing: 24) {
                    Text("Paused")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 15) {
                        Button {
                            isPaused = false
                            showPauseOverlay = false
                        } label: {
                            MainPinkBTNView(label: "continue", height: 70)
                        }
                        Button {
                            timer?.invalidate()
                            setupPuzzle()
                            isPaused = false
                            showPauseOverlay = false
                            startTimer()
                        } label: {
                            MainPinkBTNView(label: "restart", height: 70)
                        }
                        Button {
                            NotificationCenter.default.post(name: .dismissToMainPage, object: nil)
                        } label: {
                            MainPinkBTNView(label: "main page", height: 70)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .frame(height: 500)
        }
    }
}

#Preview {
    NavigationStack {
        FruitMosaicGameView(image: .pazl1)
    }
}

