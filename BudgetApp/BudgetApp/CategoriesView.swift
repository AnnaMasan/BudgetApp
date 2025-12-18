//
//  CategoriesView.swift
//  BudgetApp
//
//  Created by Anna Masan on 2025
//  КВ-32, КПІ ім. Ігоря Сікорського
//

import SwiftUI

/// Екран відображення списку категорій бюджету
struct CategoriesView: View {
    @EnvironmentObject var budgetManager: BudgetManager
    @State private var showingAddCategory = false
    
    var body: some View {
        NavigationView {
            List {
                if budgetManager.categories.isEmpty {
                    // Повідомлення коли немає категорій
                    Text("Додайте першу категорію")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    // Список категорій
                    ForEach(budgetManager.categories) { category in
                        NavigationLink(destination: CategoryDetailView(category: category)) {
                            CategoryRowView(category: category)
                        }
                    }
                    .onDelete(perform: deleteCategories)
                }
            }
            .navigationTitle("Категорії бюджету")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCategory = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
        }
    }
    
    /// Видаляє категорії за індексами
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = budgetManager.categories[index]
            budgetManager.deleteCategory(id: category.id)
        }
    }
}

/// Рядок категорії в списку
struct CategoryRowView: View {
    let category: Category
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                
                Text("Бюджет: \(category.initialBudget, specifier: "%.2f") ₴")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Залишок з кольоровим індикатором
            VStack(alignment: .trailing) {
                Text("\(category.currentBalance, specifier: "%.2f") ₴")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(category.isOverBudget() ? .red : .green)
                
                Text("залишок")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CategoriesView()
        .environmentObject(BudgetManager())
}
