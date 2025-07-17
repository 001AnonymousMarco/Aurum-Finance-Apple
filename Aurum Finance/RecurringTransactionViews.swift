import SwiftUI

// MARK: - Recurring Transaction Views

struct RecurringTransactionsOverviewCard: View {
    @EnvironmentObject var financeStore: FinanceStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Recurring Transactions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(financeStore.recurringTransactions.filter { $0.isActive }.count) active schedules")
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title2)
                        .foregroundColor(.aurumBlue)
                }
            }
            
            // Monthly recurring summary
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Income")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(formatCurrency(financeStore.totalMonthlyRecurringIncome))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumGreen)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Monthly Expenses")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(formatCurrency(financeStore.totalMonthlyRecurringExpenses))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumRed)
                }
            }
            
            // Upcoming and overdue alerts
            if !financeStore.overdueRecurringTransactions.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.aurumWarning)
                    
                    Text("\(financeStore.overdueRecurringTransactions.count) overdue transaction(s)")
                        .font(.subheadline)
                        .foregroundColor(.aurumWarning)
                    
                    Spacer()
                    
                    Button("Process Now") {
                        financeStore.processRecurringTransactions()
                    }
                    .font(.caption)
                    .foregroundColor(.aurumBlue)
                }
                .padding(.top, 8)
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

struct RecurringTransactionCard: View {
    let transaction: RecurringTransaction
    @EnvironmentObject var financeStore: FinanceStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Type and frequency indicator
                VStack(spacing: 4) {
                    Image(systemName: transaction.frequency.icon)
                        .font(.title3)
                        .foregroundColor(.aurumBlue)
                    
                    Text(transaction.frequency.rawValue)
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                }
                .frame(width: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(transaction.category)
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    if let description = transaction.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.aurumTertiaryText)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(transaction.amount))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(transaction.isIncome ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                    
                    Text(transaction.isIncome ? "Income" : "Expense")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                }
            }
            
            // Next due date and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Due")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(formatDate(transaction.nextDue))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(transaction.nextDue < Date() ? Color(hex: "#FF9500") : .aurumText)
                }
                
                Spacer()
                
                // Status badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(transaction.isActive ? Color(hex: "#34C759") : Color(hex: "#8A8A8E"))
                        .frame(width: 8, height: 8)
                    
                    Text(transaction.isActive ? "Active" : "Inactive")
                        .font(.caption)
                        .foregroundColor(transaction.isActive ? Color(hex: "#34C759") : Color(hex: "#8A8A8E"))
                }
            }
            
            // Process button if overdue
            if transaction.shouldProcess() {
                Button(action: {
                    financeStore.processRecurringTransactions()
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Process Transaction")
                    }
                    .font(.subheadline)
                    .foregroundColor(.aurumBlue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.aurumBlue.opacity(0.1))
                    .cornerRadius(8)
                }
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

struct RecurringTransactionsListView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var showingAddRecurring = false
    @State private var selectedFilter: RecurringFilter = .all
    
    enum RecurringFilter: String, CaseIterable {
        case all = "All"
        case income = "Income"
        case expense = "Expense"
        case overdue = "Overdue"
        case upcoming = "Upcoming"
    }
    
    var filteredTransactions: [RecurringTransaction] {
        let transactions = financeStore.recurringTransactions
        
        switch selectedFilter {
        case .all:
            return transactions
        case .income:
            return transactions.filter { $0.isIncome }
        case .expense:
            return transactions.filter { !$0.isIncome }
        case .overdue:
            return financeStore.overdueRecurringTransactions
        case .upcoming:
            return financeStore.upcomingRecurringTransactions
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(RecurringFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Overview card
                    RecurringTransactionsOverviewCard()
                    
                    // Recurring transactions list
                    ForEach(filteredTransactions) { transaction in
                        RecurringTransactionCard(transaction: transaction)
                    }
                }
                .padding(16)
            }
        }
        .background(Color.aurumDark)
        .navigationTitle("Recurring")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddRecurring = true }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }
            }
        }
        .sheet(isPresented: $showingAddRecurring) {
            AddRecurringTransactionView()
                .environmentObject(financeStore)
        }
    }
}

struct AddRecurringTransactionView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var amount = ""
    @State private var isIncome = false
    @State private var selectedFrequency: RecurrenceFrequency = .monthly
    @State private var selectedIncomeCategory: Income.IncomeCategory = .salary
    @State private var selectedExpenseCategory: Expense.ExpenseCategory = .food
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var description = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title)
                        .foregroundColor(.aurumPurple)
                    
                    Text("Add Recurring Transaction")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20) {
                    // Name
                    FormSection(title: "Transaction Name") {
                        TextField("e.g., Salary, Rent, Netflix", text: $name)
                            .aurumTextFieldStyle(placeholder: "e.g., Salary, Rent, Netflix")
                    }
                    
                    // Amount
                    FormSection(title: "Amount") {
                        AmountInputField(amount: $amount)
                    }
                    
                    // Type Selection
                    FormSection(title: "Type") {
                        HStack(spacing: 0) {
                            Button(action: { 
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isIncome = false 
                                }
                            }) {
                                Text("Expense")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isIncome ? .aurumGray : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isIncome ? Color.clear : Color.aurumRed)
                                    .cornerRadius(8, corners: [.topLeft, .bottomLeft])
                            }
                            
                            Button(action: { 
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isIncome = true 
                                }
                            }) {
                                Text("Income")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isIncome ? .white : .aurumGray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isIncome ? Color.aurumGreen : Color.clear)
                                    .cornerRadius(8, corners: [.topRight, .bottomRight])
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.aurumGray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 4)
                    }
                    
                    // Category
                    FormSection(title: "Category") {
                        if isIncome {
                            CategoryPicker(
                                selection: $selectedIncomeCategory,
                                categories: Income.IncomeCategory.allCases
                            ) { category in
                                CategoryRow(
                                    title: category.rawValue,
                                    color: Color(hex: category.color),
                                    isSelected: self.selectedIncomeCategory == category
                                )
                            }
                        } else {
                            CategoryPicker(
                                selection: $selectedExpenseCategory,
                                categories: Expense.ExpenseCategory.allCases
                            ) { category in
                                CategoryRow(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    color: Color(hex: category.color),
                                    isSelected: self.selectedExpenseCategory == category
                                )
                            }
                        }
                    }
                    
                    // Frequency
                    FormSection(title: "Frequency") {
                        CategoryPicker(
                            selection: $selectedFrequency,
                            categories: RecurrenceFrequency.allCases
                        ) { frequency in
                            CategoryRow(
                                title: frequency.rawValue,
                                icon: frequency.icon,
                                color: Color.aurumPurple,
                                isSelected: self.selectedFrequency == frequency
                            )
                        }
                    }
                    
                    // Start Date
                    FormSection(title: "Start Date") {
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .accentColor(.aurumGold)
                            .padding()
                            .background(Color.aurumCard)
                            .cornerRadius(12)
                    }
                    
                    // End Date Toggle
                    FormSection(title: "End Date (Optional)") {
                        VStack(spacing: 12) {
                            Toggle("Set End Date", isOn: $hasEndDate)
                                .toggleStyle(SwitchToggleStyle(tint: .aurumGold))
                                .padding()
                                .background(Color.aurumCard)
                                .cornerRadius(12)
                            
                            if hasEndDate {
                                DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .accentColor(.aurumGold)
                                    .padding()
                                    .background(Color.aurumCard)
                                    .cornerRadius(12)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
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
                    saveRecurringTransaction()
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
                    saveRecurringTransaction()
                }
                .fontWeight(.semibold)
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #endif
        }
    }
    
    private var isValidInput: Bool {
        !name.isEmpty && !amount.isEmpty && Double(amount) != nil
    }
    
    private func saveRecurringTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        let category = isIncome ? selectedIncomeCategory.rawValue : selectedExpenseCategory.rawValue
        let nextDue = selectedFrequency.nextDate(from: startDate)
        
        let transaction = RecurringTransaction(
            name: name,
            amount: amountValue,
            frequency: selectedFrequency,
            category: category,
            isIncome: isIncome,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            nextDue: nextDue,
            description: description.isEmpty ? nil : description
        )
        
        financeStore.addRecurringTransaction(transaction)
        dismiss()
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .aurumDark : .aurumText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? .aurumPurple : Color.aurumCard)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.aurumBorder, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// Helper functions
fileprivate func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
}

fileprivate func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
} 