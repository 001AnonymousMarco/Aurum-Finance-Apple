import Foundation
import SwiftUI
import Firebase

class FinanceStore: ObservableObject {
    @Published private var firestoreManager = FirestoreManager()
    
    var incomes: [Income] { firestoreManager.incomes }
    var expenses: [Expense] { firestoreManager.expenses }
    var savingsGoals: [SavingsGoal] { firestoreManager.savingsGoals }
    var liabilities: [Liability] { firestoreManager.liabilities }
    
    // MARK: - Computed Properties
    
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
    
    var recentTransactions: [AnyTransaction] {
        let incomeTransactions = incomes.map { AnyTransaction(income: $0) }
        let expenseTransactions = expenses.map { AnyTransaction(expense: $0) }
        
        return (incomeTransactions + expenseTransactions)
            .sorted { $0.date > $1.date }
            .prefix(10)
            .map { $0 }
    }
    
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
    
    enum TransactionType {
        case income
        case expense
    }
    
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