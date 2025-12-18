//
//  AddExpenseView.swift
//  BudgetApp
//
//  Created by Anna Masan on 2025
//  КВ-32, КПІ ім. Ігоря Сікорського
//

import SwiftUI

/// Екран додавання нової витрати
struct AddExpenseView: View {
    @EnvironmentObject var budgetManager: BudgetManager
    @Environment(\.dismiss) var dismiss
    
    let categoryId: UUID
    
    @State private var amountString = ""
    @State private var description = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    /// Поточна категорія
    private var category: Category? {
        budgetManager.findById(categoryId: categoryId)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Дані витрати")) {
                    TextField("Сума (₴)", text: $amountString)
                        .keyboardType(.decimalPad)
                    
                    TextField("Опис витрати", text: $description)
                }
                
                if let category = category {
                    Section(header: Text("Інформація")) {
                        HStack {
                            Text("Категорія")
                            Spacer()
                            Text(category.name)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Поточний залишок")
                            Spacer()
                            Text("\(category.currentBalance, specifier: "%.2f") ₴")
                                .foregroundColor(category.isOverBudget() ? .red : .green)
                        }
                    }
                }
            }
            .navigationTitle("Нова витрата")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Зберегти") {
                        saveExpense()
                    }
                    .disabled(amountString.isEmpty || description.isEmpty)
                }
            }
            .alert("Помилка", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    /// Зберігає нову витрату
    private func saveExpense() {
        // Валідація суми
        guard let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")),
              amount > 0 else {
            errorMessage = "Введіть коректну суму витрати"
            showingError = true
            return
        }
        
        // Валідація опису
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDescription.isEmpty else {
            errorMessage = "Введіть опис витрати"
            showingError = true
            return
        }
        
        // Створення та збереження витрати
        budgetManager.addExpense(
            amount: amount,
            description: trimmedDescription,
            categoryId: categoryId
        )
        
        dismiss()
    }
}

#Preview {
    AddExpenseView(categoryId: UUID())
        .environmentObject(BudgetManager())
}
