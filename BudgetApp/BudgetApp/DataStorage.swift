//
//  DataStorage.swift
//  BudgetApp
//
//  Created by Anna Masan on 2025
//  КВ-32, КПІ ім. Ігоря Сікорського
//

import Foundation

/// Клас для збереження даних локально на пристрої
/// Використовує UserDefaults для персистентного зберігання
class DataStorage {
    
    private let userDefaults: UserDefaults
    
    // Ключі для збереження даних
    private enum Keys {
        static let categories = "budget_categories"
        static let expenses = "budget_expenses"
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Збереження даних
    
    /// Зберігає дані за вказаним ключем
    /// - Parameters:
    ///   - data: дані для збереження
    ///   - key: ключ збереження
    func save(data: Data, key: String) {
        userDefaults.set(data, forKey: key)
    }
    
    /// Завантажує дані за вказаним ключем
    /// - Parameter key: ключ для завантаження
    /// - Returns: збережені дані або nil
    func load(key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }
    
    /// Видаляє дані за вказаним ключем
    /// - Parameter key: ключ для видалення
    func delete(key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    // MARK: - Робота з категоріями
    
    /// Зберігає масив категорій
    /// - Parameter categories: масив категорій для збереження
    func saveCategories(_ categories: [Category]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            save(data: encoded, key: Keys.categories)
        }
    }
    
    /// Завантажує масив категорій
    /// - Returns: масив категорій або порожній масив
    func loadCategories() -> [Category] {
        guard let data = load(key: Keys.categories),
              let categories = try? JSONDecoder().decode([Category].self, from: data) else {
            return []
        }
        return categories
    }
    
    // MARK: - Робота з витратами
    
    /// Зберігає масив витрат
    /// - Parameter expenses: масив витрат для збереження
    func saveExpenses(_ expenses: [Expense]) {
        if let encoded = try? JSONEncoder().encode(expenses) {
            save(data: encoded, key: Keys.expenses)
        }
    }
    
    /// Завантажує масив витрат
    /// - Returns: масив витрат або порожній масив
    func loadExpenses() -> [Expense] {
        guard let data = load(key: Keys.expenses),
              let expenses = try? JSONDecoder().decode([Expense].self, from: data) else {
            return []
        }
        return expenses
    }
    
    // MARK: - Очищення даних
    
    /// Видаляє всі збережені дані
    func clearAllData() {
        delete(key: Keys.categories)
        delete(key: Keys.expenses)
    }
}
