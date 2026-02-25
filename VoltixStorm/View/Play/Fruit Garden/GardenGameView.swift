//
//  GardenGameView.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 23.02.2026.
//

import SwiftUI

struct GardenGameView: View {
    let levelData: GardenLevelData
    @Environment(\.dismiss) private var dismiss
    @State private var grid: [GardenFruit] = []
    @State private var collected: [GardenFruit: Int] = [:]
    @State private var selectedIndex: Int? = nil
    @State private var levelComplete: Bool = false
    @State private var isProcessing: Bool = false
    @State private var showPauseOverlay: Bool = false
    @State private var goToNextLevel: Bool = false
    @State private var didAddToRating: Bool = false
    
    private let columns = 4
    private let rows = 5
    private var gridSize: Int { columns * rows }
    
    private var goal1: GardenLevelGoal? { levelData.goals.first }
    private var goal2: GardenLevelGoal? { levelData.goals.dropFirst().first }
    private var goalFruits: [GardenFruit] { levelData.goals.map { $0.fruit } }
    private var nextLevelData: GardenLevelData? {
        GardenLevelData.data(for: levelData.id + 1)
    }
    
    /// Набор фруктов, который может появляться на уровне (на ранних уровнях меньше ассортимента)
    private var spawnFruits: [GardenFruit] {
        let all = GardenFruit.allCases
        let extras = all.filter { !goalFruits.contains($0) }
        
        switch levelData.id {
        case 1:
            // только фрукты из задания
            return goalFruits
        case 2:
            return goalFruits + extras.prefix(1)
        case 3:
            return goalFruits + extras.prefix(2)
        case 4:
            return goalFruits + extras.prefix(3)
        default:
            return all
        }
    }
    
    /// Случайный фрукт с повышенным шансом для тех, что в задании
    private func randomFruit() -> GardenFruit {
        var weighted: [GardenFruit] = []
        for fruit in spawnFruits {
            let weight = goalFruits.contains(fruit) ? 4 : 1  // фрукты из задания встречаются чаще
            for _ in 0..<weight {
                weighted.append(fruit)
            }
        }
        return weighted.randomElement() ?? spawnFruits.randomElement() ?? GardenFruit.allCases.first!
    }
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            if levelComplete {
                levelCompleteView
            } else {
                VStack(spacing: 16) {

                    ZStack {
                        Image(.backQuestion)
                            .resizable()
                        gridView
                            .disabled(isProcessing)
                    }
                    ZStack {
                        Image(.backQuestion)
                            .resizable()
                        goalsView
                    }
                    .frame(height: 80)
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            
            if showPauseOverlay {
                pauseOverlayView
            }
            
            // скрытый NavigationLink для перехода на следующий уровень
            if let nextLevelData {
                NavigationLink(
                    destination: GardenGameView(levelData: nextLevelData),
                    isActive: $goToNextLevel
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showPauseOverlay = true
                } label: {
                    Image(.pauseBN)
                        .resizable()
                        .frame(width: 30, height: 30)
                }

            }
            ToolbarItem(placement: .principal) {
                Text("Level \(levelData.id)")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold, design: .serif))
            }
        }
        
        .onAppear {
            setupNewGame()
        }
    }
    
    private var levelCompleteView: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            ZStack {
                Image(.backQuestion)
                    .resizable()
                VStack(spacing: 24) {
                    Text("Level completed!")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text("Get ready for the next challenge.")
                        .font(.system(size: 20, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 15) {
                        Button {
                            if nextLevelData != nil {
                                goToNextLevel = true
                            } else {
                                dismiss()
                            }
                        } label: {
                            MainPinkBTNView(label: "next level", height: 70)
                        }
                        Button {
                            restartGame()
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
    
    private func restartGame() {
        setupNewGame()
        showPauseOverlay = false
        didAddToRating = false
    }
    
    private var pauseOverlayView: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            ZStack {
                Image(.backQuestion)
                    .resizable()
                VStack(spacing: 24) {
                    Text("Paused")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    VStack(spacing: 15) {
                        Button {
                            showPauseOverlay = false
                        } label: {
                            MainPinkBTNView(label: "continue", height: 70)
                        }
                        Button {
                            restartGame()
                        } label: {
                            MainPinkBTNView(label: "restart", height: 70)
                        }
                        Button {
                            NotificationCenter.default.post(name: .dismissToMainPage, object: nil)
                        } label: {
                            MainPinkBTNView(label: "main page", height: 70)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding()
                }
                .padding()
            }
            .frame(height: 500)
        }
    }
    
    private var goalsView: some View {
        HStack(spacing: 24) {
            Text("level goal:")
                .foregroundStyle(.goldCol)
                .font(.system(size: 15, weight: .medium, design: .serif))
                .textCase(.uppercase)
                .minimumScaleFactor(0.5)
            if let g1 = goal1 {
                goalRow(fruit: g1.fruit, current: collected[g1.fruit] ?? 0, target: g1.target)
            }
            if let g2 = goal2 {
                goalRow(fruit: g2.fruit, current: collected[g2.fruit] ?? 0, target: g2.target)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func goalRow(fruit: GardenFruit, current: Int, target: Int) -> some View {
        HStack(spacing: 8) {
            Image(fruit.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
            Text("\(min(current, target))/\(target)")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(current >= target ? .green : .white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var gridView: some View {
        let cellSize: CGFloat = 72
        return VStack(spacing: 6) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<columns, id: \.self) { col in
                        let idx = row * columns + col
                        if idx < grid.count {
                            cellView(fruit: grid[idx], index: idx, size: cellSize)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func cellView(fruit: GardenFruit, index: Int, size: CGFloat) -> some View {
        let isSelected = selectedIndex == index
        return Button {
            handleTap(index: index)
        } label: {
            Image(fruit.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size - 8, height: size - 8)
                .padding(4)
                .background(isSelected ? Color.yellow.opacity(0.6) : Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func setupNewGame() {
        var goalsDict: [GardenFruit: Int] = [:]
        for g in levelData.goals {
            goalsDict[g.fruit] = 0
        }
        collected = goalsDict
        grid = (0..<gridSize).map { _ in randomFruit() }
        selectedIndex = nil
        levelComplete = false
        didAddToRating = false
        ensureNoInitialMatches()
    }
    
    private func ensureNoInitialMatches() {
        while true {
            let matches = findMatches()
            if matches.isEmpty { break }
            for idx in matches {
                grid[idx] = randomFruit()
            }
        }
    }
    
    private func handleTap(index: Int) {
        guard !isProcessing else { return }
        if let prev = selectedIndex {
            if prev == index {
                selectedIndex = nil
                return
            }
            if isAdjacent(prev, index) {
                selectedIndex = nil
                swapAndResolve(a: prev, b: index)
                return
            }
        }
        selectedIndex = index
    }
    
    private func isAdjacent(_ a: Int, _ b: Int) -> Bool {
        let rowA = a / columns, colA = a % columns
        let rowB = b / columns, colB = b % columns
        return abs(rowA - rowB) + abs(colA - colB) == 1
    }
    
    private func swapAndResolve(a: Int, b: Int) {
        grid.swapAt(a, b)
        let createsMatch = !findMatches().isEmpty
        if !createsMatch {
            grid.swapAt(a, b)
            return
        }
        isProcessing = true
        resolveMatchesLoop()
    }
    
    private func resolveMatchesLoop() {
        func step() {
            let matches = findMatches()
            if matches.isEmpty {
                isProcessing = false
                checkLevelComplete()
                return
            }
            
            // засчитываем собранные фрукты
            for idx in matches {
                let fruit = grid[idx]
                collected[fruit, default: 0] += 1
            }
            
            // небольшая задержка перед исчезновением и падением
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    applyGravityAndFill(for: matches)
                }
                // после анимации проверяем следующие каскады
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    step()
                }
            }
        }
        
        step()
    }
    
    /// Перемещает фрукты вниз в каждом столбце и добавляет новые сверху
    private func applyGravityAndFill(for removedIndices: Set<Int>) {
        for col in 0..<columns {
            // собираем все фрукты в этом столбце, которые не были удалены
            var columnFruits: [GardenFruit] = []
            for row in 0..<rows {
                let idx = row * columns + col
                if !removedIndices.contains(idx) {
                    columnFruits.append(grid[idx])
                }
            }
            
            let emptyCount = rows - columnFruits.count
            var newColumn: [GardenFruit] = []
            
            // сначала новые случайные фрукты для пустых ячеек сверху
            for _ in 0..<emptyCount {
                newColumn.append(randomFruit())
            }
            // затем оставшиеся «упавшие» фрукты
            newColumn.append(contentsOf: columnFruits)
            
            // записываем столбец обратно в сетку (сверху вниз)
            for row in 0..<rows {
                let idx = row * columns + col
                grid[idx] = newColumn[row]
            }
        }
    }
    
    private func findMatches() -> Set<Int> {
        var set: Set<Int> = []
        for row in 0..<rows {
            var run: [(Int, GardenFruit)] = []
            for col in 0..<columns {
                let idx = row * columns + col
                let f = grid[idx]
                if let last = run.last, last.1 == f {
                    run.append((idx, f))
                } else {
                    if run.count >= 3 {
                        for (i, _) in run { set.insert(i) }
                    }
                    run = [(idx, f)]
                }
            }
            if run.count >= 3 {
                for (i, _) in run { set.insert(i) }
            }
        }
        for col in 0..<columns {
            var run: [(Int, GardenFruit)] = []
            for row in 0..<rows {
                let idx = row * columns + col
                let f = grid[idx]
                if let last = run.last, last.1 == f {
                    run.append((idx, f))
                } else {
                    if run.count >= 3 {
                        for (i, _) in run { set.insert(i) }
                    }
                    run = [(idx, f)]
                }
            }
            if run.count >= 3 {
                for (i, _) in run { set.insert(i) }
            }
        }
        return set
    }
    
    private func checkLevelComplete() {
        var done = true
        for g in levelData.goals {
            if (collected[g.fruit] ?? 0) < g.target {
                done = false
                break
            }
        }
        if done {
            levelComplete = true
            if !didAddToRating {
                let name = RatingManager.shared.currentPlayerName
                if !name.isEmpty {
                    let points = levelData.goals.reduce(0) { $0 + $1.target }
                    RatingManager.shared.addPoints(points, forPlayer: name)
                    didAddToRating = true
                }
            }
        }
    }
}


