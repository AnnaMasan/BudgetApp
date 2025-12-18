//
//  StatisticsView.swift
//  BudgetApp
//
//  Created by Anna Masan on 2025
//  КВ-32, КПІ ім. Ігоря Сікорського
//

import SwiftUI

/// Екран статистики та загального огляду бюджету
struct StatisticsView: View {
    @EnvironmentObject var budgetManager: BudgetManager
    
    private var statistics: Statistics {
        budgetManager.getStatistics()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Загальний баланс
                    TotalBalanceCard(statistics: statistics)
                    
                    // Розподіл по категоріях
                    if !budgetManager.categories.isEmpty {
                        CategoryBreakdownView(categories: budgetManager.categories)
                    } else {
                        EmptyStateView()
                    }
                }
                .padding()
            }
            .navigationTitle("Статистика")
        }
    }
}

/// Картка загального балансу
struct TotalBalanceCard: View {
    let statistics: Statistics
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Загальний залишок")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("\(statistics.totalRemaining, specifier: "%.2f") ₴")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(statistics.totalRemaining >= 0 ? .green : .red)
            
            Divider()
            
            HStack(spacing: 30) {
                // Загальний бюджет
                VStack {
                    Text("Бюджет")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(statistics.totalBudget, specifier: "%.2f") ₴")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // Витрачено
                VStack {
                    Text("Витрачено")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(statistics.totalSpent, specifier: "%.2f") ₴")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                
                // Перевищення
                VStack {
                    Text("Перевищено")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(statistics.categoriesOverBudget)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(statistics.categoriesOverBudget > 0 ? .red : .green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

/// Розподіл по категоріях
struct CategoryBreakdownView: View {
    let categories: [Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Розподіл по категоріях")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(categories) { category in
                CategoryProgressRow(category: category)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

/// Рядок прогресу категорії
struct CategoryProgressRow: View {
    let category: Category
    
    private var spentAmount: Double {
        category.initialBudget - category.currentBalance
    }
    
    private var spentPercentage: Double {
        guard category.initialBudget > 0 else { return 0 }
        return min(max(spentAmount / category.initialBudget, 0), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(category.currentBalance, specifier: "%.2f") ₴")
                    .font(.subheadline)
                    .foregroundColor(category.isOverBudget() ? .red : .primary)
            }
            
            // Прогрес-бар
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(category.isOverBudget() ? Color.red : Color.blue)
                        .frame(width: geometry.size.width * spentPercentage, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            HStack {
                Text("Витрачено: \(spentAmount, specifier: "%.2f") ₴")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("з \(category.initialBudget, specifier: "%.2f") ₴")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

/// Порожній стан
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Немає даних для відображення")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Додайте категорії та витрати для перегляду статистики")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    StatisticsView()
        .environmentObject(BudgetManager())
}
