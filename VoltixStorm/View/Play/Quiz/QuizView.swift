//
//  QuizView.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 23.02.2026.
//

import SwiftUI

struct QuizView: View {
    let level: QuizLevel
    @Environment(\.dismiss) private var dismiss
    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex: Int = 0
    @State private var score: Int = 0
    @State private var selectedOptionIndex: Int? = nil
    @State private var hasAnswered: Bool = false
    @State private var showResult: Bool = false
    @State private var showPauseOverlay: Bool = false
    @State private var didAddToRating: Bool = false
    
    private var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    private var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(questions.count)
    }
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            if showResult {
                resultView
            } else if let question = currentQuestion {
                ZStack {
                    quizContentView(question: question)
                    if showPauseOverlay {
                        pauseOverlayView
                    }
                }
            } else if questions.isEmpty {
                ProgressView("Loading...")
                    .tint(.white)
            }
        }
        
        .onAppear {
            questions = QuizData.questions(for: level)
        }
    }
    
    private var resultView: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            ZStack {
                Image(.backQuestion)
                    .resizable()
                VStack {
                    Text("Quiz Complete!")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    Text("Your score: \(score) / \(questions.count)")
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                    
                    VStack(spacing: 15) {
                        Button {
                            dismiss()
                        } label: {
                            MainPinkBTNView(label: "next quiz",height: 70)
                        }
                        Button {
                            restartQuiz()
                        } label: {
                            MainPinkBTNView(label: "restart",height: 70)
                        }
                        Button {
                            NotificationCenter.default.post(name: .dismissToMainPage, object: nil)
                        } label: {
                            MainPinkBTNView(label: "main page",height: 70)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding()
                }
                .padding()
            }
            .frame(height: 500)
            .onAppear {
                updateRatingIfNeeded()
            }
        }
    }
    
    private func updateRatingIfNeeded() {
        guard !didAddToRating, score > 0 else { return }
        let name = RatingManager.shared.currentPlayerName
        guard !name.isEmpty else { return }
        RatingManager.shared.addPoints(score, forPlayer: name)
        didAddToRating = true
    }
    
    private func restartQuiz() {
        currentIndex = 0
        score = 0
        selectedOptionIndex = nil
        hasAnswered = false
        showResult = false
        showPauseOverlay = false
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
                            restartQuiz()
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
    
    private func quizContentView(question: QuizQuestion) -> some View {
        
            VStack(spacing: 24) {
                Text("\(level.title)")
                .font(.system(size: 30, weight: .heavy, design: .serif))
                .foregroundStyle(.white.opacity(0.9))
            ZStack{
                Image(.backQuestion)
                    .resizable()
                VStack(spacing: 15){
                    Text("Question \(currentIndex + 1) of \(questions.count)")
                        .font(.system(size: 16, weight: .medium,design: .serif))
                        .foregroundStyle(.goldCol)
                    
                    Text(question.question)
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .textCase(.uppercase)
                }
                .padding(20)
                .minimumScaleFactor(0.5)
            }.frame(height: 200)
            
            
            
            VStack(spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    optionButton(title: optionLabel(for: index) + option, index: index, question: question)
                }
            }
            .padding(.horizontal, 24)
            
           
                Button {
                    if currentIndex + 1 < questions.count {
                        nextQuestion()
                    } else {
                        showResult = true
                    }
                } label: {
                    MainPinkBTNView(label: currentIndex + 1 < questions.count ? "Continue" : "See Result")
                    
                }
                .opacity(hasAnswered ? 1 : 0.3)
                .disabled(!hasAnswered)
                .padding(.horizontal, 40)
                .padding(.top, 8)
            
            
            Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPauseOverlay = true
                    } label: {
                        Image(.pauseBN)
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                }
            }
           
        
    }
    
    private func optionLabel(for index: Int) -> String {
        let labels = ["A) ", "B) ", "C) ", "D) "]
        return index < labels.count ? labels[index] : "\(index + 1)) "
    }
    
    private func optionButton(title: String, index: Int, question: QuizQuestion) -> some View {
        let isCorrect = index == question.correctIndex
        let isSelected = selectedOptionIndex == index
        let showCorrect = hasAnswered && isCorrect
        let showWrong = hasAnswered && isSelected && !isCorrect
        
        return Button {
            guard !hasAnswered else { return }
            selectedOptionIndex = index
            hasAnswered = true
            if isCorrect {
                score += 1
            }
        } label: {
            ZStack {
                Image(.backQuestion)
                    .resizable()
                    .frame(height: 70)
                Text(title)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundStyle(optionColor(showCorrect: showCorrect, showWrong: showWrong, isSelected: isSelected))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(optionBackground(showCorrect: showCorrect, showWrong: showWrong))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
        }
        .disabled(hasAnswered)
    }
    
    private func optionColor(showCorrect: Bool, showWrong: Bool, isSelected: Bool) -> Color {
        if showCorrect { return .white }
        if showWrong { return .white }
        return .white
    }
    
    private func optionBackground(showCorrect: Bool, showWrong: Bool) -> Color {
        if showCorrect { return .green.opacity(0.7) }
        if showWrong { return .red.opacity(0.7) }
        return .white.opacity(0)
    }
    
    private func nextQuestion() {
        currentIndex += 1
        selectedOptionIndex = nil
        hasAnswered = false
    }
}

extension Notification.Name {
    static let dismissToMainPage = Notification.Name("VoltixStorm.DismissToMainPage")
}

#Preview {
    NavigationStack {
        QuizView(level: .easy)
    }
}
