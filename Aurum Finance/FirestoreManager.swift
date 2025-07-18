import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    private let auth = FirebaseManager.shared
    
    @Published var incomes: [Income] = []
    @Published var expenses: [Expense] = []
    @Published var savingsGoals: [SavingsGoal] = []
    @Published var liabilities: [Liability] = []
    @Published var budgets: [Budget] = []
    @Published var recurringTransactions: [RecurringTransaction] = []
    
    private var listeners: [ListenerRegistration] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        FirebaseManager.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.setupListeners(for: user?.uid)
            }
            .store(in: &cancellables)
    }
    
    private func setupListeners(for userId: String?) {
        // 1. Remove all existing listeners to prevent duplicate data or crashes.
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        
        // 2. Clear all local data arrays when the user changes (e.g., on logout).
        incomes.removeAll()
        expenses.removeAll()
        savingsGoals.removeAll()
        liabilities.removeAll()
        budgets.removeAll()
        recurringTransactions.removeAll()
        
        // 3. Guard against a nil user ID. If the user is logged out, stop here.
        guard let userId = userId else {
            print("FirestoreManager: User is not authenticated. Listeners cleared.")
            return
        }
        
        print("FirestoreManager: Setting up new listeners for user \(userId)...")
        
        // 4. Set up listeners for authenticated user
        setupIncomeListener(userId: userId)
        setupExpenseListener(userId: userId)
        setupSavingsGoalListener(userId: userId)
        setupLiabilityListener(userId: userId)
        setupBudgetListener(userId: userId)
        setupRecurringTransactionListener(userId: userId)
    }
    
    private func setupIncomeListener(userId: String) {
        let incomeListener = db.collection("users/\(userId)/incomes")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching incomes: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.incomes = documents.compactMap { document in
                    Income.from(dictionary: document.data())
                }
            }
        listeners.append(incomeListener)
    }
    
    private func setupExpenseListener(userId: String) {
        let expenseListener = db.collection("users/\(userId)/expenses")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching expenses: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.expenses = documents.compactMap { document in
                    Expense.from(dictionary: document.data())
                }
            }
        listeners.append(expenseListener)
    }
    
    private func setupSavingsGoalListener(userId: String) {
        let goalsListener = db.collection("users/\(userId)/savingsGoals")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching goals: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.savingsGoals = documents.compactMap { document in
                    SavingsGoal.from(dictionary: document.data())
                }
            }
        listeners.append(goalsListener)
    }
    
    private func setupLiabilityListener(userId: String) {
        let liabilitiesListener = db.collection("users/\(userId)/liabilities")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching liabilities: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.liabilities = documents.compactMap { document in
                    Liability.from(dictionary: document.data())
                }
            }
        listeners.append(liabilitiesListener)
    }
    
    private func setupBudgetListener(userId: String) {
        let budgetsListener = db.collection("users/\(userId)/budgets")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching budgets: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.budgets = documents.compactMap { document in
                    Budget.from(dictionary: document.data())
                }
            }
        listeners.append(budgetsListener)
    }
    
    private func setupRecurringTransactionListener(userId: String) {
        let recurringListener = db.collection("users/\(userId)/recurringTransactions")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching recurring transactions: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.recurringTransactions = documents.compactMap { document in
                    RecurringTransaction.from(dictionary: document.data())
                }
            }
        listeners.append(recurringListener)
    }
    
    // MARK: - Income Operations
    
    func addIncome(_ income: Income) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/incomes").document(income.id.uuidString).setData(income.toDictionary())
    }
    
    func updateIncome(_ income: Income) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/incomes").document(income.id.uuidString).setData(income.toDictionary())
    }
    
    func deleteIncome(_ income: Income) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/incomes").document(income.id.uuidString).delete()
    }
    
    // MARK: - Expense Operations
    
    func addExpense(_ expense: Expense) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/expenses").document(expense.id.uuidString).setData(expense.toDictionary())
    }
    
    func updateExpense(_ expense: Expense) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/expenses").document(expense.id.uuidString).setData(expense.toDictionary())
    }
    
    func deleteExpense(_ expense: Expense) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/expenses").document(expense.id.uuidString).delete()
    }
    
    // MARK: - Savings Goal Operations
    
    func addSavingsGoal(_ goal: SavingsGoal) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/savingsGoals").document(goal.id.uuidString).setData(goal.toDictionary())
    }
    
    func updateSavingsGoal(_ goal: SavingsGoal) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/savingsGoals").document(goal.id.uuidString).setData(goal.toDictionary())
    }
    
    func deleteSavingsGoal(_ goal: SavingsGoal) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/savingsGoals").document(goal.id.uuidString).delete()
    }
    
    // MARK: - Liability Operations
    
    func addLiability(_ liability: Liability) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/liabilities").document(liability.id.uuidString).setData(liability.toDictionary())
    }
    
    func updateLiability(_ liability: Liability) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/liabilities").document(liability.id.uuidString).setData(liability.toDictionary())
    }
    
    func deleteLiability(_ liability: Liability) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/liabilities").document(liability.id.uuidString).delete()
    }
    
    // MARK: - Budget Operations
    
    func addBudget(_ budget: Budget) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/budgets").document(budget.id.uuidString).setData(budget.toDictionary())
    }
    
    func updateBudget(_ budget: Budget) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/budgets").document(budget.id.uuidString).setData(budget.toDictionary())
    }
    
    func deleteBudget(_ budget: Budget) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/budgets").document(budget.id.uuidString).delete()
    }
    
    // MARK: - Recurring Transaction Operations
    
    func addRecurringTransaction(_ transaction: RecurringTransaction) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/recurringTransactions").document(transaction.id.uuidString).setData(transaction.toDictionary())
    }
    
    func updateRecurringTransaction(_ transaction: RecurringTransaction) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/recurringTransactions").document(transaction.id.uuidString).setData(transaction.toDictionary())
    }
    
    func deleteRecurringTransaction(_ transaction: RecurringTransaction) async throws {
        guard let userId = auth.currentUser?.uid else { throw FirestoreError.notAuthenticated }
        try await db.collection("users/\(userId)/recurringTransactions").document(transaction.id.uuidString).delete()
    }
}

enum FirestoreError: Error {
    case notAuthenticated
    case documentNotFound
    case encodingError
    case decodingError
} 
