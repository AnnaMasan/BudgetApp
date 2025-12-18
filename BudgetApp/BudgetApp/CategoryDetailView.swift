//
//  CategoryDetailView.swift
//  BudgetApp
//
//  Created by Anna Masan on 2025
//  КВ-32, КПІ ім. Ігоря Сікорського
//

import SwiftUI

/// Детальний екран категорії з витратами
struct CategoryDetailView: View {
    @EnvironmentObject var budgetManager: BudgetManager
    let category: Category
    
    @State private var showingAddExpense = false
    
    /// Актуальна версія категорії з BudgetManager
    private var currentCategory: Category {
        budgetManager.findById(categoryId: category.id) ?? category
    }
    
    /// Витрати цієї категорії
    private var categoryExpenses: [Expense] {
        budgetManager.getExpenses(for: category.id)
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        List {
            // Секція з інформацією про бюджет
            Section {
                BudgetInfoCard(category: currentCategory)
            }
            
            // Секція з витратами
            Section(header: Text("Витрати")) {
                if categoryExpenses.isEmpty {
                    Text("Витрат поки немає")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(categoryExpenses) { expense in
                        ExpenseRowView(expense: expense)
                    }
                    .onDelete(perform: deleteExpenses)
                }
            }
        }
        .navigationTitle(currentCategory.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddExpense = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(categoryId: category.id)
        }
    }
    
    /// Видаляє витрати за індексами
    private func deleteExpenses(at offsets: IndexSet) {
        let expensesToDelete = offsets.map { categoryExpenses[$0] }
        for expense in expensesToDelete {
            budgetManager.deleteExpense(id: expense.id)
        }
    }
}

/// Картка з інформацією про бюджет категорії
struct BudgetInfoCard: View {
    let category: Category
    
    private var spentAmount: Double {
        category.initialBudget - category.currentBalance
    }
    
    private var spentPercentage: Double {
        guard category.initialBudget > 0 else { return 0 }
        return min(spentAmount / category.initialBudget, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Залишок
            VStack(spacing: 4) {
                Text("Залишок")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("\(category.currentBalance, specifier: "%.2f") ₴")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(category.isOverBudget() ? .red : .green)
            }
            
            // Прогрес-бар
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(category.isOverBudget() ? Color.red : Color.blue)
                        .frame(width: geometry.size.width * spentPercentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            // Деталі бюджету
            HStack {
                VStack(alignment: .leading) {
                    Text("Витрачено")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(spentAmount, specifier: "%.2f") ₴")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Бюджет")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(category.initialBudget, specifier: "%.2f") ₴")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            // Попередження про перевитрату
            if category.isOverBudget() {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Бюджет перевищено!")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.top, 4)
            }
        }
        .padding()
    }
}

/// Рядок витрати в списку
struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.body)
                
                Text(expense.getFormattedDate())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("-\(expense.amount, specifier: "%.2f") ₴")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        CategoryDetailView(category: Category(name: "Їжа", initialBudget: 5000))
    }
    .environmentObject(BudgetManager())
}
