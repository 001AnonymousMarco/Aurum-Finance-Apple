import Foundation
import SwiftUI

@MainActor
class FinanceStore: ObservableObject {
    @Published private var firestoreManager = FirestoreManager()
    
    // Search and filter states
    @Published var searchText = ""
    @Published var selectedDateRange: DateRange = .thisMonth
    @Published var selectedTransactionType: TransactionType? = nil
    @Published var selectedExpenseCategory: ExpenseCategory? = nil
    
    // Phase 2: Advanced Financial Management
    @Published var recurringTransactions: [RecurringTransaction] = []
    @Published var budgets: [Budget] = []
    @Published var recurringTransactionSchedule: [RecurringTransaction] = []
    
    var incomes: [Income] { firestoreManager.incomes }
    var expenses: [Expense] { firestoreManager.expenses }
    var savingsGoals: [SavingsGoal] { firestoreManager.savingsGoals }
    var liabilities: [Liability] { firestoreManager.liabilities }
    
    // MARK: - Enhanced Analytics Properties
    
    var financialSummary: FinancialSummary {
        let calendar = Calendar.current
        let now = Date()
        
        let monthlyIncomes = incomes.filter { income in
            calendar.isDate(income.date, equalTo: now, toGranularity: .month) &&
            calendar.isDate(income.date, equalTo: now, toGranularity: .year)
        }
        
        let monthlyExpenses = expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .month) &&
            calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
        }
        
        let totalIncome = monthlyIncomes.reduce(0) { $0 + $1.amount }
        let totalExpenses = monthlyExpenses.reduce(0) { $0 + $1.amount }
        let totalAssets = savingsGoals.reduce(0) { $0 + $1.currentAmount }
        let totalLiabilities = liabilities.reduce(0) { $0 + $1.balance }
        
        return FinancialSummary(
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            totalAssets: totalAssets,
            totalLiabilities: totalLiabilities
        )
    }
    
    // Enhanced cash flow analysis
    var cashFlowAnalysis: CashFlowAnalysis {
        let summary = financialSummary
        let cashFlow = summary.totalIncome - summary.totalExpenses
        let savingsRate = summary.totalIncome > 0 ? ((cashFlow / summary.totalIncome) * 100) : 0
        
        return CashFlowAnalysis(
            monthlyIncome: summary.totalIncome,
            monthlyExpenses: summary.totalExpenses,
            netCashFlow: cashFlow,
            savingsRate: savingsRate,
            netWorth: summary.netWorth
        )
    }
    
    // Expense breakdown with percentages
    var detailedExpenseBreakdown: [ExpenseBreakdownItem] {
        let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        guard totalExpenses > 0 else { return [] }
        
        return Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .map { category, amount in
                ExpenseBreakdownItem(
                    category: category,
                    amount: amount,
                    percentage: (amount / totalExpenses) * 100
                )
            }
            .sorted { $0.amount > $1.amount }
    }
    
    // Monthly trends for the last 12 months
    var monthlyTrends: [MonthlyTrend] {
        let calendar = Calendar.current
        let now = Date()
        var trends: [MonthlyTrend] = []
        
        for i in 0..<12 {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            
            let monthIncomes = incomes.filter { income in
                calendar.isDate(income.date, equalTo: monthDate, toGranularity: .month) &&
                calendar.isDate(income.date, equalTo: monthDate, toGranularity: .year)
            }
            
            let monthExpenses = expenses.filter { expense in
                calendar.isDate(expense.date, equalTo: monthDate, toGranularity: .month) &&
                calendar.isDate(expense.date, equalTo: monthDate, toGranularity: .year)
            }
            
            let income = monthIncomes.reduce(0) { $0 + $1.amount }
            let expenses = monthExpenses.reduce(0) { $0 + $1.amount }
            
            trends.append(MonthlyTrend(
                month: monthDate,
                income: income,
                expenses: expenses,
                netFlow: income - expenses
            ))
        }
        
        return trends.reversed() // Most recent first
    }
    
    // Filtered transactions based on search and filters
    var filteredTransactions: [AnyTransaction] {
        let allTransactions = recentTransactions
        
        return allTransactions.filter { transaction in
            // Search filter
            if !searchText.isEmpty {
                let searchMatches = transaction.description?.localizedCaseInsensitiveContains(searchText) ?? false
                if !searchMatches { return false }
            }
            
            // Date range filter
            if !selectedDateRange.contains(transaction.date) {
                return false
            }
            
            // Transaction type filter
            if let typeFilter = selectedTransactionType {
                switch typeFilter {
                case .income where transaction.type != .income:
                    return false
                case .expense where transaction.type != .expense:
                    return false
                default:
                    break
                }
            }
            
            // Category filter (for expenses)
            if let categoryFilter = selectedExpenseCategory,
               transaction.type == .expense {
                // Find the original expense to check category
                let expense = expenses.first { $0.id == transaction.id }
                if expense?.category != categoryFilter {
                    return false
                }
            }
            
            return true
        }
    }
    
    var recentTransactions: [AnyTransaction] {
        let incomeTransactions = incomes.map { AnyTransaction(income: $0) }
        let expenseTransactions = expenses.map { AnyTransaction(expense: $0) }
        
        return (incomeTransactions + expenseTransactions)
            .sorted { $0.date > $1.date }
            .prefix(10)
            .map { $0 }
    }
    
    // Legacy computed properties (keeping for compatibility)
    var expensesByCategory: [ExpenseCategory: Double] {
        Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }
    
    var incomesByCategory: [Income.IncomeCategory: Double] {
        Dictionary(grouping: incomes, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }
    
    // MARK: - Income Operations
    
    func addIncome(_ income: Income) {
        Task {
            try? await firestoreManager.addIncome(income)
        }
    }
    
    func updateIncome(_ income: Income) {
        Task {
            try? await firestoreManager.updateIncome(income)
        }
    }
    
    func deleteIncome(_ income: Income) {
        Task {
            try? await firestoreManager.deleteIncome(income)
        }
    }
    
    // MARK: - Expense Operations
    
    func addExpense(_ expense: Expense) {
        Task {
            try? await firestoreManager.addExpense(expense)
        }
    }
    
    func updateExpense(_ expense: Expense) {
        Task {
            try? await firestoreManager.updateExpense(expense)
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        Task {
            try? await firestoreManager.deleteExpense(expense)
        }
    }
    
    // MARK: - Savings Goal Operations
    
    func addSavingsGoal(_ goal: SavingsGoal) {
        Task {
            try? await firestoreManager.addSavingsGoal(goal)
        }
    }
    
    func updateSavingsGoal(_ goal: SavingsGoal) {
        Task {
            try? await firestoreManager.updateSavingsGoal(goal)
        }
    }
    
    func deleteSavingsGoal(_ goal: SavingsGoal) {
        Task {
            try? await firestoreManager.deleteSavingsGoal(goal)
        }
    }
    
    func addToSavingsGoal(_ goalId: UUID, amount: Double) {
        guard let goal = savingsGoals.first(where: { $0.id == goalId }) else { return }
        var updatedGoal = goal
        updatedGoal.currentAmount += amount
        updateSavingsGoal(updatedGoal)
    }
    
    // MARK: - Liability Operations
    
    func addLiability(_ liability: Liability) {
        Task {
            try? await firestoreManager.addLiability(liability)
        }
    }
    
    func updateLiability(_ liability: Liability) {
        Task {
            try? await firestoreManager.updateLiability(liability)
        }
    }
    
    func deleteLiability(_ liability: Liability) {
        Task {
            try? await firestoreManager.deleteLiability(liability)
        }
    }
    
    // MARK: - Phase 2: Advanced Financial Management Properties
    
    var budgetAnalysis: BudgetAnalysis {
        return BudgetAnalysis.analyze(budgets: budgets, expenses: expenses)
    }
    
    var upcomingRecurringTransactions: [RecurringTransaction] {
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return recurringTransactions
            .filter { $0.isActive && $0.nextDue <= nextWeek }
            .sorted { $0.nextDue < $1.nextDue }
    }
    
    var overdueRecurringTransactions: [RecurringTransaction] {
        return recurringTransactions
            .filter { $0.isActive && $0.nextDue < Date() }
            .sorted { $0.nextDue < $1.nextDue }
    }
    
    var totalMonthlyRecurringIncome: Double {
        return recurringTransactions
            .filter { $0.isActive && $0.isIncome && $0.frequency == .monthly }
            .reduce(0) { $0 + $1.amount }
    }
    
    var totalMonthlyRecurringExpenses: Double {
        return recurringTransactions
            .filter { $0.isActive && !$0.isIncome && $0.frequency == .monthly }
            .reduce(0) { $0 + $1.amount }
    }
    
    var debtToIncomeRatio: Double {
        let monthlyIncome = financialSummary.totalIncome
        guard monthlyIncome > 0 else { return 0 }
        
        let totalDebtPayments = liabilities.reduce(0) { $0 + $1.minimumPayment }
        return totalDebtPayments / monthlyIncome
    }
    
    var highPriorityDebts: [Liability] {
        return liabilities.filter { $0.priority == .high }.sorted { $0.interestRate > $1.interestRate }
    }
    
    var budgetAlerts: [Budget] {
        return budgets.filter { budget in
            let status = budget.status(expenses: expenses)
            return status == .nearLimit || status == .overBudget
        }
    }
    
    // MARK: - Phase 2: Management Methods
    
    func processRecurringTransactions() {
        let today = Date()
        var processedTransactions: [RecurringTransaction] = []
        
        for recurring in recurringTransactions {
            if recurring.shouldProcess(on: today) {
                // Create the actual transaction
                if recurring.isIncome {
                    let income = Income(
                        amount: recurring.amount,
                        source: recurring.name,
                        category: recurring.incomeCategory ?? .other,
                        date: today,
                        description: "Auto-generated from \(recurring.name)"
                    )
                    addIncome(income)
                } else {
                    let expense = Expense(
                        amount: recurring.amount,
                        category: recurring.expenseCategory ?? .other,
                        date: today,
                        expenseDescription: recurring.name,
                        notes: "Auto-generated from \(recurring.name)"
                    )
                    addExpense(expense)
                }
                
                // Update the recurring transaction
                let updated = recurring.updateNextDue()
                processedTransactions.append(updated)
            }
        }
        
        // Update the recurring transactions list
        for processed in processedTransactions {
            if let index = recurringTransactions.firstIndex(where: { $0.id == processed.id }) {
                recurringTransactions[index] = processed
            }
        }
    }
    
    func addRecurringTransaction(_ transaction: RecurringTransaction) {
        recurringTransactions.append(transaction)
        // TODO: Add Firestore persistence
    }
    
    func updateRecurringTransaction(_ transaction: RecurringTransaction) {
        if let index = recurringTransactions.firstIndex(where: { $0.id == transaction.id }) {
            recurringTransactions[index] = transaction
            // TODO: Add Firestore persistence
        }
    }
    
    func deleteRecurringTransaction(_ transaction: RecurringTransaction) {
        recurringTransactions.removeAll { $0.id == transaction.id }
        // TODO: Add Firestore persistence
    }
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        // TODO: Add Firestore persistence
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            // TODO: Add Firestore persistence
        }
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        // TODO: Add Firestore persistence
    }
}

// MARK: - Transaction Wrapper

struct AnyTransaction: Identifiable {
    let id: UUID
    let amount: Double
    let date: Date
    let description: String?
    let type: TransactionType
    let categoryColor: String
    let categoryIcon: String
    
    init(income: Income) {
        self.id = income.id
        self.amount = income.amount
        self.date = income.date
        self.description = income.description ?? income.source
        self.type = .income
        self.categoryColor = income.category.color
        self.categoryIcon = "plus.circle.fill"
    }
    
    init(expense: Expense) {
        self.id = expense.id
        self.amount = expense.amount
        self.date = expense.date
        self.description = expense.expenseDescription
        self.type = .expense
        self.categoryColor = expense.category.color
        self.categoryIcon = expense.category.icon
    }
} 