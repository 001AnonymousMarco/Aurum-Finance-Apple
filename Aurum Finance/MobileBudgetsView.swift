//
//  MobileBudgetsView.swift
//  Aurum Finance
//
//  Created by Marc Alleyne on 7/7/25.
//

import SwiftUI

struct MobileBudgetsView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var showingAddBudget = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Add Button
            mobileHeader
            
            // Budgets List
            if financeStore.budgets.isEmpty {
                mobileEmptyState
            } else {
                mobileBudgetsList
            }
        }
        .background(Color.aurumDark)
        .sheet(isPresented: $showingAddBudget) {
            NavigationStack {
                AddBudgetView()
                    .environmentObject(financeStore)
                    .navigationTitle("Add Budget")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingAddBudget = false
                            }
                        }
                    }
            }
        }
    }
    
    private var mobileHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Budgets")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.aurumText)
                
                Text("\(financeStore.budgets.count) active budgets")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
            }
            
            Spacer()
            
            Button(action: {
                showingAddBudget = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.aurumGold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.aurumDark)
    }
    
    private var mobileBudgetsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(financeStore.budgets, id: \.id) { budget in
                    MobileBudgetCard(budget: budget)
                        .contextMenu {
                            Button("Edit") {
                                // Edit budget
                            }
                            
                            Button("Delete", role: .destructive) {
                                // Delete budget
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100) // Space for floating button
        }
    }
    
    private var mobileEmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(.aurumGray)
            
            VStack(spacing: 8) {
                Text("No Budgets")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.aurumText)
                
                Text("Create your first budget to start tracking your spending")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddBudget = true
            }) {
                Text("Create Budget")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.aurumGold)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.aurumDark)
    }
}

// MARK: - Mobile Budget Card
struct MobileBudgetCard: View {
    let budget: Budget
    
    private var spentAmount: Double {
        // Calculate spent amount for this budget category
        // This would need to be implemented based on your transaction data
        return 0.0 // Placeholder
    }
    
    private var remainingAmount: Double {
        return budget.amount - spentAmount
    }
    
    private var progressPercentage: Double {
        guard budget.amount > 0 else { return 0 }
        return min(spentAmount / budget.amount, 1.0)
    }
    
    private var isOverBudget: Bool {
        spentAmount > budget.amount
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                // Budget Icon
                Circle()
                    .fill(budgetColor)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: budgetIcon)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumText)
                    
                    Text(budget.category)
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                }
                
                Spacer()
                
                // Status Badge
                Text(statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .cornerRadius(6)
            }
            
            // Progress Section
            VStack(spacing: 12) {
                // Progress Bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Spent")
                            .font(.subheadline)
                            .foregroundColor(.aurumGray)
                        
                        Spacer()
                        
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(progressColor)
                    }
                    
                    ProgressView(value: progressPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                        .scaleEffect(x: 1, y: 3, anchor: .center)
                }
                
                // Amount Details
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Spent")
                            .font(.caption)
                            .foregroundColor(.aurumGray)
                        
                        Text(spentAmount.formatted(.currency(code: "USD")))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.aurumRed)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Budget")
                            .font(.caption)
                            .foregroundColor(.aurumGray)
                        
                        Text(budget.amount.formatted(.currency(code: "USD")))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.aurumText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundColor(.aurumGray)
                        
                        Text(remainingAmount.formatted(.currency(code: "USD")))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(remainingColor)
                    }
                }
            }
            
            // Period Info
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.aurumGray)
                    .font(.caption)
                
                Text("\(budget.period.rawValue.capitalized) budget")
                    .font(.caption)
                    .foregroundColor(.aurumGray)
                
                Spacer()
                
                if isOverBudget {
                    Text("Over budget")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.aurumRed)
                }
            }
        }
        .padding(20)
        .background(Color.aurumCard)
        .cornerRadius(16)
    }
    
    private var statusText: String {
        if progressPercentage >= 1.0 {
            return "Over Budget"
        } else if progressPercentage >= 0.8 {
            return "Warning"
        } else {
            return "On Track"
        }
    }
    
    private var statusColor: Color {
        if progressPercentage >= 1.0 {
            return .aurumRed
        } else if progressPercentage >= 0.8 {
            return .aurumOrange
        } else {
            return .aurumGreen
        }
    }
    
    private var progressColor: Color {
        if progressPercentage >= 1.0 {
            return .aurumRed
        } else if progressPercentage >= 0.8 {
            return .aurumOrange
        } else {
            return .aurumGreen
        }
    }
    
    private var remainingColor: Color {
        if remainingAmount < 0 {
            return .aurumRed
        } else if remainingAmount < budget.amount * 0.2 {
            return .aurumOrange
        } else {
            return .aurumGreen
        }
    }
    
    private var budgetColor: Color {
        switch budget.category.lowercased() {
        case "food", "dining": return .aurumOrange
        case "transportation", "gas": return .aurumBlue
        case "entertainment": return .aurumPurple
        case "shopping": return .aurumPink
        case "bills", "utilities": return .aurumRed
        case "health", "medical": return .aurumGreen
        case "education": return .aurumTeal
        default: return .aurumGold
        }
    }
    
    private var budgetIcon: String {
        switch budget.category.lowercased() {
        case "food", "dining": return "fork.knife"
        case "transportation", "gas": return "car.fill"
        case "entertainment": return "gamecontroller.fill"
        case "shopping": return "bag.fill"
        case "bills", "utilities": return "bolt.fill"
        case "health", "medical": return "cross.fill"
        case "education": return "book.fill"
        default: return "chart.pie"
        }
    }
} 