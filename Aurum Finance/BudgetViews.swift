import SwiftUI

// MARK: - Budget Management Views

struct BudgetOverviewCard: View {
    let analysis: BudgetAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Budget Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.aurumText)
                    
                    Text("\(formatCurrency(analysis.totalSpent)) of \(formatCurrency(analysis.totalBudgeted))")
                        .font(.subheadline)
                        .foregroundColor(.aurumSecondaryText)
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: analysis.overallStatus.icon)
                        .font(.title2)
                        .foregroundColor(Color(hex: analysis.overallStatus.color))
                    
                    Text(analysis.overallStatus.description)
                        .font(.caption)
                        .foregroundColor(Color(hex: analysis.overallStatus.color))
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Overall Progress")
                        .font(.subheadline)
                        .foregroundColor(.aurumSecondaryText)
                    
                    Spacer()
                    
                    Text("\(Int((analysis.totalSpent / analysis.totalBudgeted) * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.aurumText)
                }
                
                ProgressView(value: analysis.totalSpent, total: analysis.totalBudgeted)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: analysis.overallStatus.color)))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Budget status summary
            HStack(spacing: 20) {
                BudgetStatusItem(
                    count: analysis.budgetsOnTrack,
                    title: "On Track",
                    color: "#34C759"
                )
                
                BudgetStatusItem(
                    count: analysis.budgetsNearLimit,
                    title: "Near Limit",
                    color: "#FF9500"
                )
                
                BudgetStatusItem(
                    count: analysis.budgetsOverBudget,
                    title: "Over Budget",
                    color: "#FF3B30"
                )
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.aurumCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.aurumBorder, lineWidth: 1)
        )
    }
}

struct BudgetStatusItem: View {
    let count: Int
    let title: String
    let color: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: color))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.aurumSecondaryText)
        }
    }
}

struct BudgetCard: View {
    let budget: Budget
    let expenses: [Expense]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Category icon and name
                HStack(spacing: 8) {
                    Image(systemName: budget.category.icon)
                        .font(.title3)
                        .foregroundColor(Color(hex: budget.category.color))
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(budget.name)
                            .font(.headline)
                            .foregroundColor(.aurumText)
                        
                        Text(budget.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.aurumSecondaryText)
                    }
                }
                
                Spacer()
                
                // Status indicator
                VStack {
                    Image(systemName: budget.status(expenses: expenses).icon)
                        .font(.title3)
                        .foregroundColor(Color(hex: budget.status(expenses: expenses).color))
                }
            }
            
            // Amount spent vs budget
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.aurumSecondaryText)
                    
                    Text(formatCurrency(budget.currentSpent(expenses: expenses)))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.aurumText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundColor(.aurumSecondaryText)
                    
                    Text(formatCurrency(budget.monthlyLimit))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.aurumText)
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.aurumSecondaryText)
                    
                    Spacer()
                    
                    Text("\(Int(budget.progressPercentage(expenses: expenses) * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.aurumText)
                }
                
                ProgressView(value: budget.progressPercentage(expenses: expenses))
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: budget.status(expenses: expenses).color)))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            
            // Remaining amount
            let remaining = budget.remainingAmount(expenses: expenses)
            HStack {
                Text(remaining >= 0 ? "Remaining:" : "Over by:")
                    .font(.caption)
                    .foregroundColor(.aurumSecondaryText)
                
                Spacer()
                
                Text(formatCurrency(abs(remaining)))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(remaining >= 0 ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
            }
        }
        .padding(16)
        .background(Color.aurumCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.aurumBorder, lineWidth: 1)
        )
    }
}

struct BudgetListView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var showingAddBudget = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Budget overview
                BudgetOverviewCard(analysis: financeStore.budgetAnalysis)
                
                // Individual budgets
                ForEach(financeStore.budgets.filter { $0.isActive }) { budget in
                    BudgetCard(budget: budget, expenses: financeStore.expenses)
                }
                
                // Add new budget button
                Button(action: { showingAddBudget = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.aurumPurple)
                        
                        Text("Add New Budget")
                            .font(.headline)
                            .foregroundColor(.aurumText)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.aurumCard)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.aurumBorder, lineWidth: 1)
                    )
                }
            }
            .padding(16)
        }
        .background(Color.aurumDark)
        .navigationTitle("Budgets")
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView()
                .environmentObject(financeStore)
        }
    }
}

struct AddBudgetView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedCategory: Expense.ExpenseCategory = .food
    @State private var monthlyLimit = ""
    @State private var alertThreshold = 80.0
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Budget Details") {
                    TextField("Budget Name", text: $name)
                        .foregroundColor(.aurumText)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Expense.ExpenseCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .foregroundColor(.aurumText)
                    
                    TextField("Monthly Limit", text: $monthlyLimit)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.aurumText)
                    
                    TextField("Description (optional)", text: $description)
                        .foregroundColor(.aurumText)
                }
                
                Section("Alert Settings") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Alert when reaching \(Int(alertThreshold))% of budget")
                            .foregroundColor(.aurumText)
                        
                        Slider(value: $alertThreshold, in: 50...95, step: 5)
                            .tint(.aurumPurple)
                    }
                }
            }
            .background(Color.aurumDark)
            .scrollContentBackground(.hidden)
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.aurumSecondaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBudget()
                    }
                    .foregroundColor(.aurumPurple)
                    .disabled(name.isEmpty || monthlyLimit.isEmpty)
                }
            }
        }
    }
    
    private func saveBudget() {
        guard let limit = Double(monthlyLimit), limit > 0 else { return }
        
        let budget = Budget(
            name: name,
            category: selectedCategory,
            monthlyLimit: limit,
            startDate: Date(),
            alertThreshold: alertThreshold / 100,
            description: description.isEmpty ? nil : description
        )
        
        financeStore.addBudget(budget)
        dismiss()
    }
}

// Helper function for currency formatting
private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
} 