import SwiftUI
import FirebaseFirestore

@MainActor
class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    private let auth = FirebaseManager.shared
    
    @Published var incomes: [Income] = []
    @Published var expenses: [Expense] = []
    @Published var savingsGoals: [SavingsGoal] = []
    @Published var liabilities: [Liability] = []
    
    private var listeners: [ListenerRegistration] = []
    
    init() {
        setupListeners()
    }
    
    deinit {
        // Remove all listeners when the manager is deallocated
        listeners.forEach { $0.remove() }
    }
    
    private func setupListeners() {
        guard let userId = auth.currentUser?.uid else { return }
        
        // Listen for incomes
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
        
        // Listen for expenses
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
        
        // Listen for savings goals
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
        
        // Listen for liabilities
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
}

enum FirestoreError: Error {
    case notAuthenticated
    case documentNotFound
    case encodingError
    case decodingError
} 
