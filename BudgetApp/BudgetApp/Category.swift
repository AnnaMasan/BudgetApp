//
//  Category.swift
//  BudgetApp
//
//  Created by Anna Masan on 2025
//  КВ-32, КПІ ім. Ігоря Сікорського
//

import Foundation

/// Модель категорії витрат
/// Представляє категорію витрат з бюджетом та поточним балансом
struct Category: Identifiable, Codable {
    let id: UUID
    var name: String
    var initialBudget: Double
    var currentBalance: Double
    
    init(id: UUID = UUID(), name: String, initialBudget: Double) {
        self.id = id
        self.name = name
        self.initialBudget = initialBudget
        self.currentBalance = initialBudget
    }
    
    /// Оновлює баланс категорії після витрати
    /// - Parameter amount: сума витрати
    mutating func updateBalance(amount: Double) {
        currentBalance -= amount
    }
    
    /// Перевіряє чи перевищено бюджет
    /// - Returns: true якщо баланс менший за нуль
    func isOverBudget() -> Bool {
        return currentBalance < 0
    }
    
    /// Скидає баланс до початкового бюджету
    mutating func reset() {
        currentBalance = initialBudget
    }
}
