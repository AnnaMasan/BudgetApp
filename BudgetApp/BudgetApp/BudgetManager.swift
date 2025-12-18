//
//  BudgetManager.swift
//  BudgetApp
//
//  Created by Anna Masan on 2025
//  КВ-32, КПІ ім. Ігоря Сікорського
//

import Foundation
import Combine

/// Структура для відображення статистики
struct Statistics {
    let totalBudget: Double
    let totalSpent: Double
    let totalRemaining: Double
    let categoriesOverBudget: Int
}

/// Головний клас для управління категоріями та витратами
/// Реалізує бізнес-логіку застосунку Budget App
class BudgetManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var categories: [Category] = []
    @Published private(set) var expenses: [Expense] = []
    
    // MARK: - Private Properties
    
    private let dataStorage: DataStorage
    
    // MARK: - Computed Properties
    
    /// Загальний бюджет всіх категорій
    var totalBudget: Double {
        categories.reduce(0) { $0 + $1.initialBudget }
    }
    
    // MARK: - Initialization
    
    init(dataStorage: DataStorage = DataStorage()) {
        self.dataStorage = dataStorage
        loadData()
    }
    
    // MARK: - Робота з категоріями
    
    /// Додає нову категорію
    /// - Parameter category: категорія для додавання
    func addCategory(category: Category) {
        categories.append(category)
        dataStorage.saveCategories(categories)
    }
    
    /// Створює та додає нову категорію
    /// - Parameters:
    ///   - name: назва категорії
    ///   - budget: початковий бюджет
    func addCategory(name: String, budget: Double) {
        let category = Category(name: name, initialBudget: budget)
        addCategory(category: category)
    }
    
    /// Видаляє категорію за ID
    /// - Parameter id: ідентифікатор категорії
    func deleteCategory(id: UUID) {
        categories.removeAll { $0.id == id }
        // Видаляємо також всі витрати цієї категорії
        expenses.removeAll { $0.categoryId == id }
        dataStorage.saveCategories(categories)
        dataStorage.saveExpenses(expenses)
    }
    
    /// Оновлює існуючу категорію
    /// - Parameter category: оновлена категорія
    func updateCategory(category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            dataStorage.saveCategories(categories)
        }
    }
    
    /// Знаходить категорію за ID
    /// - Parameter categoryId: ідентифікатор категорії
    /// - Returns: категорія або nil
    func findById(categoryId: UUID) -> Category? {
        return categories.first { $0.id == categoryId }
    }
    
    // MARK: - Робота з витратами
    
    /// Додає нову витрату
    /// - Parameter expense: витрата для додавання
    func addExpense(expense: Expense) {
        // Знаходимо категорію
        guard let index = categories.firstIndex(where: { $0.id == expense.categoryId }) else {
            return
        }
        
        // Оновлюємо баланс категорії
        categories[index].updateBalance(amount: expense.amount)
        
        // Додаємо витрату
        expenses.append(expense)
        
        // Зберігаємо дані
        dataStorage.saveCategories(categories)
        dataStorage.saveExpenses(expenses)
    }
    
    /// Створює та додає нову витрату
    /// - Parameters:
    ///   - amount: сума витрати
    ///   - description: опис витрати
    ///   - categoryId: ID категорії
    func addExpense(amount: Double, description: String, categoryId: UUID) {
        let expense = Expense(amount: amount, description: description, categoryId: categoryId)
        addExpense(expense: expense)
    }
    
    /// Видаляє витрату та повертає кошти до категорії
    /// - Parameter id: ідентифікатор витрати
    func deleteExpense(id: UUID) {
        guard let expense = expenses.first(where: { $0.id == id }),
              let categoryIndex = categories.firstIndex(where: { $0.id == expense.categoryId }) else {
            return
        }
        
        // Повертаємо кошти до категорії
        categories[categoryIndex].currentBalance += expense.amount
        
        // Видаляємо витрату
        expenses.removeAll { $0.id == id }
        
        // Зберігаємо дані
        dataStorage.saveCategories(categories)
        dataStorage.saveExpenses(expenses)
    }
    
    /// Отримує витрати для конкретної категорії
    /// - Parameter categoryId: ID категорії
    /// - Returns: масив витрат категорії
    func getExpenses(for categoryId: UUID) -> [Expense] {
        return expenses.filter { $0.categoryId == categoryId }
    }
    
    // MARK: - Статистика
    
    /// Обчислює загальний залишок бюджету
    /// - Returns: сума залишків всіх категорій
    func calculateTotalBalance() -> Double {
        return categories.reduce(0) { $0 + $1.currentBalance }
    }
    
    /// Отримує статистику по бюджету
    /// - Returns: структура Statistics
    func getStatistics() -> Statistics {
        let totalBudget = self.totalBudget
        let totalRemaining = calculateTotalBalance()
        let totalSpent = totalBudget - totalRemaining
        let overBudget = categories.filter { $0.isOverBudget() }.count
        
        return Statistics(
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            totalRemaining: totalRemaining,
            categoriesOverBudget: overBudget
        )
    }
    
    // MARK: - Збереження/Завантаження даних
    
    /// Завантажує дані з локального сховища
    private func loadData() {
        categories = dataStorage.loadCategories()
        expenses = dataStorage.loadExpenses()
    }
    
    /// Скидає всі дані
    func resetAllData() {
        categories = []
        expenses = []
        dataStorage.clearAllData()
    }
}
