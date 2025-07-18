import SwiftUI

// MARK: - Budget Management Views

struct BudgetOverviewCard: View {
    let analysis: BudgetAnalysis
    
    // Safe computed properties to prevent division by zero
    private var progressPercentage: Int {
        guard analysis.totalBudgeted > 0 else { return 0 }
        let percentage = (analysis.totalSpent / analysis.totalBudgeted) * 100
        guard percentage.isFinite else { return 0 }
        return max(0, min(100, Int(percentage.rounded())))
    }
    
    private var safeProgressValue: Double {
        guard analysis.totalBudgeted > 0 else { return 0 }
        return min(analysis.totalSpent, analysis.totalBudgeted)
    }
    
    private var safeTotalValue: Double {
        return max(1, analysis.totalBudgeted) // Ensure never zero
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Budget Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(formatCurrency(analysis.totalSpent)) of \(formatCurrency(analysis.totalBudgeted))")
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
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
                        .foregroundColor(.aurumGray)
                    
                    Spacer()
                    
                    Text("\(progressPercentage)%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                ProgressView(value: safeProgressValue, total: safeTotalValue)
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
                .foregroundColor(.aurumGray)
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
                            .foregroundColor(.white)
                        
                        Text(budget.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.aurumGray)
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
                        .foregroundColor(.aurumGray)
                    
                    Text(formatCurrency(budget.currentSpent(expenses: expenses)))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(formatCurrency(budget.monthlyLimit))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Spacer()
                    
                    Text("\(Int(budget.progressPercentage(expenses: expenses) * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
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
                    .foregroundColor(.aurumGray)
                
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
    @State private var selectedCategory: Expense.ExpenseCategory? = nil
    @State private var showingEditBudget = false
    @State private var selectedBudget: Budget?
    @State private var showingDeleteAlert = false
    @State private var budgetToDelete: Budget?
    
    private var filteredBudgets: [Budget] {
        guard let category = selectedCategory else { return financeStore.budgets.filter { $0.isActive } }
        return financeStore.budgets.filter { $0.isActive && $0.category == category }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Budget overview
                BudgetOverviewCard(analysis: financeStore.budgetAnalysis)
                
                // Category Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterPill(
                            title: "All",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        ForEach(Expense.ExpenseCategory.allCases, id: \.self) { category in
                            FilterPill(
                                title: category.rawValue,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                
                // Individual budgets or empty state
                if filteredBudgets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 48))
                            .foregroundColor(.aurumGray)
                        
                        Text("No budgets yet")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Create your first budget to track spending categories")
                            .font(.subheadline)
                            .foregroundColor(.aurumGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button(action: { showingAddBudget = true }) {
                            Text("Create Budget")
                                .font(.headline)
                        }
                        .goldButton()
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                } else {
                    ForEach(filteredBudgets) { budget in
                        BudgetCard(budget: budget, expenses: financeStore.expenses)
                            .contextMenu {
                                Button {
                                    selectedBudget = budget
                                    showingEditBudget = true
                                } label: {
                                    Label("Edit Budget", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    budgetToDelete = budget
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.aurumDark)
        .navigationTitle("Budgets")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddBudget = true }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }
            }
        }
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView()
                .environmentObject(financeStore)
        }
        .sheet(isPresented: $showingEditBudget) {
            AddBudgetView(budget: selectedBudget)
                .environmentObject(financeStore)
        }
        .alert("Delete Budget", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let budget = budgetToDelete {
                    financeStore.deleteBudget(budget)
                }
            }
        } message: {
            if let budget = budgetToDelete {
                Text("Are you sure you want to delete \"\(budget.name)\"? This action cannot be undone.")
            }
        }
    }
}

struct AddBudgetView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @Environment(\.dismiss) private var dismiss
    
    private let budgetToEdit: Budget?
    
    @State private var name = ""
    @State private var selectedCategory: Expense.ExpenseCategory = .food
    @State private var monthlyLimit = ""
    @State private var alertThreshold = 80.0
    @State private var description = ""
    
    init(budget: Budget? = nil) {
        self.budgetToEdit = budget
        _name = State(initialValue: budget?.name ?? "")
        _selectedCategory = State(initialValue: budget?.category ?? .food)
        _monthlyLimit = State(initialValue: budget?.monthlyLimit != nil ? String(format: "%.0f", budget!.monthlyLimit) : "")
        _alertThreshold = State(initialValue: budget?.alertThreshold != nil ? (budget!.alertThreshold * 100) : 80.0)
        _description = State(initialValue: budget?.description ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie.fill")
                        .font(.title)
                        .foregroundColor(.aurumPurple)
                    
                    Text(budgetToEdit != nil ? "Edit Budget" : "Add Budget")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20) {
                    // Budget Name
                    FormSection(title: "Budget Name") {
                        TextField("e.g., Groceries, Entertainment", text: $name)
                            .aurumTextFieldStyle(placeholder: "e.g., Groceries, Entertainment")
                    }
                    
                    // Category
                    FormSection(title: "Category") {
                        CategoryPicker(
                            selection: $selectedCategory,
                            categories: Expense.ExpenseCategory.allCases
                        ) { category in
                            CategoryRow(
                                title: category.rawValue,
                                icon: category.icon,
                                color: Color(hex: category.color),
                                isSelected: self.selectedCategory == category
                            )
                        }
                    }
                    
                    // Monthly Limit
                    FormSection(title: "Monthly Limit") {
                        AmountInputField(amount: $monthlyLimit)
                    }
                    
                    // Alert Settings
                    FormSection(title: "Alert Settings") {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Alert when reaching \(Int(alertThreshold))% of budget")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 8) {
                                Slider(value: $alertThreshold, in: 50...95, step: 5)
                                    .tint(.aurumPurple)
                                
                                HStack {
                                    Text("50%")
                                        .font(.caption)
                                        .foregroundColor(.aurumGray)
                                    Spacer()
                                    Text("95%")
                                        .font(.caption)
                                        .foregroundColor(.aurumGray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.aurumCard)
                        .cornerRadius(12)
                    }
                    
                    // Description
                    FormSection(title: "Description (Optional)") {
                        TextField("Add a note...", text: $description)
                            .aurumTextFieldStyle(placeholder: "Add a note...")
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.bottom, 24)
        }
        .frame(width: 500, height: 700)
        .background(Color.aurumDark.ignoresSafeArea())
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.aurumGray)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveBudget()
                }
                .fontWeight(.semibold)
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #else
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.aurumGray)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveBudget()
                }
                .fontWeight(.semibold)
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #endif
        }
    }
    
    private var isValidInput: Bool {
        !name.isEmpty && 
        !monthlyLimit.isEmpty && 
        Double(monthlyLimit) != nil &&
        (Double(monthlyLimit) ?? 0) > 0
    }
    
    private func saveBudget() {
        guard let limitValue = Double(monthlyLimit) else { return }
        
        if let existingBudget = budgetToEdit {
            // Update existing budget
            let updatedBudget = Budget(
                id: existingBudget.id,
                name: name,
                category: selectedCategory,
                monthlyLimit: limitValue,
                startDate: existingBudget.startDate,
                endDate: existingBudget.endDate,
                isActive: existingBudget.isActive,
                alertThreshold: alertThreshold / 100,
                description: description.isEmpty ? nil : description
            )
            financeStore.updateBudget(updatedBudget)
        } else {
            // Create new budget
            let budget = Budget(
                name: name,
                category: selectedCategory,
                monthlyLimit: limitValue,
                startDate: Date(),
                alertThreshold: alertThreshold / 100,
                description: description.isEmpty ? nil : description
            )
            financeStore.addBudget(budget)
        }
        
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