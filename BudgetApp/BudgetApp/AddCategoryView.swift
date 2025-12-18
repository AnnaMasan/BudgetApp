//
//  AddCategoryView.swift
//  BudgetApp
//
//  Created by Anna Masan on 2025
//  КВ-32, КПІ ім. Ігоря Сікорського
//

import SwiftUI

/// Екран додавання нової категорії
struct AddCategoryView: View {
    @EnvironmentObject var budgetManager: BudgetManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var budgetString = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Інформація про категорію")) {
                    TextField("Назва категорії", text: $name)
                    
                    TextField("Початковий бюджет (₴)", text: $budgetString)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    // Підказки для назв категорій
                    Text("Приклади: Їжа, Транспорт, Житло, Розваги, Освіта")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Нова категорія")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Зберегти") {
                        saveCategory()
                    }
                    .disabled(name.isEmpty || budgetString.isEmpty)
                }
            }
            .alert("Помилка", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    /// Зберігає нову категорію
    private func saveCategory() {
        // Валідація назви
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Введіть назву категорії"
            showingError = true
            return
        }
        
        // Валідація бюджету
        guard let budget = Double(budgetString.replacingOccurrences(of: ",", with: ".")),
              budget > 0 else {
            errorMessage = "Введіть коректну суму бюджету"
            showingError = true
            return
        }
        
        // Перевірка на унікальність назви
        if budgetManager.categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            errorMessage = "Категорія з такою назвою вже існує"
            showingError = true
            return
        }
        
        // Створення та збереження категорії
        budgetManager.addCategory(name: trimmedName, budget: budget)
        dismiss()
    }
}

#Preview {
    AddCategoryView()
        .environmentObject(BudgetManager())
}
