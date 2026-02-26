//
//  QuizModel.swift
//  VoltixStorm
//
//  Created by Doras Choenholz on 23.02.2026.
//

import Foundation

enum QuizLevel: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var title: String { rawValue }
    var levelNumber: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
}

struct QuizData {
    static func questions(for level: QuizLevel) -> [QuizQuestion] {
        switch level {
        case .easy: return easyQuestions
        case .medium: return mediumQuestions
        case .hard: return hardQuestions
        }
    }
    
    private static let easyQuestions: [QuizQuestion] = [
        QuizQuestion(question: "Which fruit is usually red or green?", options: ["Banana", "Apple", "Kiwi"], correctIndex: 1),
        QuizQuestion(question: "Which fruit is yellow and curved?", options: ["Banana", "Pear", "Plum"], correctIndex: 0),
        QuizQuestion(question: "Which fruit grows on palm trees?", options: ["Cherry", "Strawberry", "Coconut"], correctIndex: 2),
        QuizQuestion(question: "Which fruit has segments inside?", options: ["Orange", "Apple", "Peach"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is small and purple or green?", options: ["Grapes", "Mango", "Pineapple"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is pink inside with small black seeds?", options: ["Dragon fruit", "Pear", "Lemon"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is orange in color and round?", options: ["Orange", "Kiwi", "Plum"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is soft and brown outside with green inside?", options: ["Kiwi", "Apple", "Peach"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is long and yellow?", options: ["Banana", "Mango", "Cherry"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is red and small with green leaves on top?", options: ["Strawberry", "Plum", "Pear"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is large and green outside, red inside?", options: ["Watermelon", "Apple", "Mango"], correctIndex: 0),
        QuizQuestion(question: "Which fruit grows in tropical regions?", options: ["Mango", "Cherry", "Plum"], correctIndex: 0),
        QuizQuestion(question: "Which fruit has a hard brown shell and white inside?", options: ["Coconut", "Kiwi", "Peach"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is often green and bell-shaped?", options: ["Pear", "Banana", "Grape"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is dark purple and small?", options: ["Plum", "Pineapple", "Lemon"], correctIndex: 0)
    ]
    
    private static let mediumQuestions: [QuizQuestion] = [
        QuizQuestion(question: "Which fruit has a pit inside?", options: ["Peach", "Banana", "Orange"], correctIndex: 0),
        QuizQuestion(question: "Which fruit has seeds on the outside?", options: ["Strawberry", "Apple", "Plum"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is known for its sour taste?", options: ["Lemon", "Mango", "Banana"], correctIndex: 0),
        QuizQuestion(question: "Which fruit has a spiky outer skin?", options: ["Pineapple", "Cherry", "Pear"], correctIndex: 0),
        QuizQuestion(question: "Which fruit grows in clusters?", options: ["Grapes", "Peach", "Kiwi"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is commonly used to make guacamole?", options: ["Avocado", "Mango", "Lemon"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is dried to make raisins?", options: ["Grapes", "Watermelon", "Pear"], correctIndex: 0),
        QuizQuestion(question: "Which fruit has a star shape when cut?", options: ["Starfruit", "Apple", "Peach"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is often used in pies and jams?", options: ["Apple", "Coconut", "Banana"], correctIndex: 0),
        QuizQuestion(question: "Which fruit has orange flesh and a large pit?", options: ["Apricot", "Grape", "Kiwi"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is commonly associated with tropical islands?", options: ["Pineapple", "Apple", "Pear"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is small and bright red, often used as a topping?", options: ["Cherry", "Mango", "Lemon"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is often green or purple and very small?", options: ["Grapes", "Pineapple", "Mango"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is rich in vitamin C?", options: ["Orange", "Banana", "Cherry"], correctIndex: 0),
        QuizQuestion(question: "Which fruit has a fuzzy skin?", options: ["Peach", "Lemon", "Grape"], correctIndex: 0)
    ]
    
    private static let hardQuestions: [QuizQuestion] = [
        QuizQuestion(question: "Which fruit belongs to the citrus family?", options: ["Mandarin", "Peach", "Plum"], correctIndex: 0),
        QuizQuestion(question: "Which fruit floats in water?", options: ["Apple", "Grape", "Mango"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is bright pink outside and white inside with black seeds?", options: ["Dragon fruit", "Pear", "Apple"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is also called a plantain when cooked?", options: ["Banana", "Mango", "Plum"], correctIndex: 0),
        QuizQuestion(question: "Which fruit grows best in warm tropical climates?", options: ["Mango", "Apple", "Cherry"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is often blended into tropical drinks?", options: ["Pineapple", "Pear", "Plum"], correctIndex: 0),
        QuizQuestion(question: "Which fruit has smooth green skin and soft flesh?", options: ["Avocado", "Cherry", "Peach"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is commonly eaten dried as dates?", options: ["Date", "Kiwi", "Plum"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is often sliced and added to breakfast bowls?", options: ["Banana", "Plum", "Apricot"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is known for being very refreshing and juicy?", options: ["Watermelon", "Date", "Raisin"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is typically orange and used for fresh juice?", options: ["Orange", "Peach", "Pear"], correctIndex: 0),
        QuizQuestion(question: "Which fruit has thick skin and sweet yellow flesh inside?", options: ["Mango", "Cherry", "Lemon"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is commonly used in fruit salads?", options: ["Melon", "Lemon", "Avocado"], correctIndex: 0),
        QuizQuestion(question: "Which fruit is oval and brown outside with bright green inside?", options: ["Kiwi", "Plum", "Grape"], correctIndex: 0),
        QuizQuestion(question: "Which fruit has a tough rind and is often cut into slices for sharing?", options: ["Watermelon", "Date", "Apricot"], correctIndex: 0)
    ]
}
