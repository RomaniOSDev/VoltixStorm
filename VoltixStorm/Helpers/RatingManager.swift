//
//  RatingManager.swift
//  VoltixStorm
//
//  Created by Роман Главацкий on 25.02.2026.
//

import Foundation

struct RatingEntry: Identifiable, Codable {
    let id: UUID
    var name: String
    var points: Int
    
    init(id: UUID = UUID(), name: String, points: Int) {
        self.id = id
        self.name = name
        self.points = points
    }
}

final class RatingManager {
    static let shared = RatingManager()
    
    private let entriesKey = "ratingEntries"
    private let nameKey = "playerName"
    
    private init() {}
    
    // MARK: - Player name
    
    var currentPlayerName: String {
        get {
            UserDefaults.standard.string(forKey: nameKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: nameKey)
        }
    }
    
    // MARK: - Rating entries
    
    func loadEntries() -> [RatingEntry] {
        guard let data = UserDefaults.standard.data(forKey: entriesKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([RatingEntry].self, from: data)
        } catch {
            return []
        }
    }
    
    func saveEntries(_ entries: [RatingEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: entriesKey)
        } catch {
            // ignore write errors in this simple game
        }
    }
    
    /// Добавить очки игроку (по имени). Имя — ключ.
    func addPoints(_ points: Int, forPlayer name: String) {
        guard !name.isEmpty else { return }
        var entries = loadEntries()
        if let idx = entries.firstIndex(where: { $0.name == name }) {
            entries[idx].points += points
        } else {
            entries.append(RatingEntry(name: name, points: points))
        }
        saveEntries(entries)
    }
    
    /// Полностью очистить рейтинг и имя игрока
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: entriesKey)
        UserDefaults.standard.removeObject(forKey: nameKey)
    }
}

