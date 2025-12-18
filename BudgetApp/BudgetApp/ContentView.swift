//
//  ContentView.swift
//  BudgetApp
//
//  Created by Анна Масан on 17.12.2025.
//

import SwiftUI

/// Головний екран застосунку з навігацією по вкладках
struct ContentView: View {
    @EnvironmentObject var budgetManager: BudgetManager
    
    var body: some View {
        TabView {
            // Вкладка категорій
            CategoriesView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Категорії")
                }
            
            // Вкладка статистики
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Статистика")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(BudgetManager())
}

