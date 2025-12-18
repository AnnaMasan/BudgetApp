//
//  Expense.swift
//  BudgetApp
//
//  Created by Anna Masan on 2025
//  КВ-32, КПІ ім. Ігоря Сікорського
//

import Foundation

/// Модель витрати
/// Представляє окрему витрату з сумою, описом та датою
struct Expense: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var description: String
    var date: Date
    var categoryId: UUID
    
    init(id: UUID = UUID(), amount: Double, description: String, date: Date = Date(), categoryId: UUID) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
        self.categoryId = categoryId
    }
    
    /// Повертає форматовану дату витрати
    /// - Returns: дата у форматі "dd.MM.yyyy"
    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date)
    }
}
