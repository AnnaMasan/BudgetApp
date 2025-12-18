//
//  BudgetAppApp.swift
//  BudgetApp
//
//  Created by Анна Масан on 17.12.2025.
//

import SwiftUI

@main
struct BudgetAppApp: App {
    @StateObject private var budgetManager = BudgetManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(budgetManager)
        }
    }
}
