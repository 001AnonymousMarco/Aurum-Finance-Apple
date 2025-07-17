import Foundation

// MARK: - Type Aliases
typealias ExpenseCategory = Expense.ExpenseCategory

// MARK: - Enhanced Analytics Models

struct CashFlowAnalysis {
    let monthlyIncome: Double
    let monthlyExpenses: Double
    let netCashFlow: Double
    let savingsRate: Double
    let netWorth: Double
    
    var cashFlowStatus: CashFlowStatus {
        if netCashFlow > 0 {
            return .positive
        } else if netCashFlow < 0 {
            return .negative
        } else {
            return .neutral
        }
    }
    
    enum CashFlowStatus {
        case positive, negative, neutral
        
        var color: String {
            switch self {
            case .positive: return "#34C759"
            case .negative: return "#FF3B30"
            case .neutral: return "#8A8A8E"
            }
        }
        
        var icon: String {
            switch self {
            case .positive: return "arrow.up.right.circle.fill"
            case .negative: return "arrow.down.right.circle.fill"
            case .neutral: return "minus.circle.fill"
            }
        }
    }
}

struct ExpenseBreakdownItem: Identifiable {
    let id = UUID()
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double
}

struct MonthlyTrend: Identifiable {
    let id = UUID()
    let month: Date
    let income: Double
    let expenses: Double
    let netFlow: Double
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: month)
    }
    
    var shortMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: month)
    }
}

enum DateRange: CaseIterable, Identifiable, Equatable {
    case thisWeek
    case thisMonth
    case lastMonth
    case last3Months
    case last6Months
    case thisYear
    case custom(start: Date, end: Date)
    
    var id: String {
        switch self {
        case .thisWeek: return "thisWeek"
        case .thisMonth: return "thisMonth"
        case .lastMonth: return "lastMonth"
        case .last3Months: return "last3Months"
        case .last6Months: return "last6Months"
        case .thisYear: return "thisYear"
        case .custom: return "custom"
        }
    }
    
    var displayName: String {
        switch self {
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .lastMonth: return "Last Month"
        case .last3Months: return "Last 3 Months"
        case .last6Months: return "Last 6 Months"
        case .thisYear: return "This Year"
        case .custom(let start, let end):
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
    
    static var allCases: [DateRange] {
        return [.thisWeek, .thisMonth, .lastMonth, .last3Months, .last6Months, .thisYear]
    }
    
    static func == (lhs: DateRange, rhs: DateRange) -> Bool {
        switch (lhs, rhs) {
        case (.thisWeek, .thisWeek),
             (.thisMonth, .thisMonth),
             (.lastMonth, .lastMonth),
             (.last3Months, .last3Months),
             (.last6Months, .last6Months),
             (.thisYear, .thisYear):
            return true
        case (.custom(let start1, let end1), .custom(let start2, let end2)):
            return start1 == start2 && end1 == end2
        default:
            return false
        }
    }
    
    func contains(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .thisWeek:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .thisMonth:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .lastMonth:
            guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return false }
            return calendar.isDate(date, equalTo: lastMonth, toGranularity: .month)
        case .last3Months:
            guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) else { return false }
            return date >= threeMonthsAgo && date <= now
        case .last6Months:
            guard let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) else { return false }
            return date >= sixMonthsAgo && date <= now
        case .thisYear:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        case .custom(let start, let end):
            return date >= start && date <= end
        }
    }
}

enum TransactionType: String, CaseIterable, Identifiable {
    case income = "Income"
    case expense = "Expense"
    
    var id: String { rawValue }
    
    var color: String {
        switch self {
        case .income: return "#34C759"
        case .expense: return "#FF3B30"
        }
    }
    
    var icon: String {
        switch self {
        case .income: return "plus.circle.fill"
        case .expense: return "minus.circle.fill"
        }
    }
}

// MARK: - View Models

enum AddSheetType {
    case income, expense, savingsGoal, liability
}

// MARK: - Phase 2: Advanced Financial Management Models

// MARK: - Recurring Transaction Models

enum RecurrenceFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    
    var icon: String {
        switch self {
        case .daily: return "calendar"
        case .weekly: return "calendar.day.timeline.left"
        case .biweekly: return "calendar.badge.clock"
        case .monthly: return "calendar.circle"
        case .quarterly: return "calendar.circle.fill"
        case .yearly: return "calendar.badge.plus"
        }
    }
    
    var description: String {
        return self.rawValue
    }
    
    func nextDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }
}

struct RecurringTransaction: Identifiable, Codable {
    let id = UUID()
    var name: String
    var amount: Double
    var frequency: RecurrenceFrequency
    var category: String
    var isIncome: Bool
    var startDate: Date
    var endDate: Date?
    var isActive: Bool = true
    var lastProcessed: Date?
    var nextDue: Date
    var description: String?
    
    var expenseCategory: Expense.ExpenseCategory? {
        if isIncome { return nil }
        return Expense.ExpenseCategory(rawValue: category) ?? .other
    }
    
    var incomeCategory: Income.IncomeCategory? {
        if !isIncome { return nil }
        return Income.IncomeCategory(rawValue: category) ?? .other
    }
    
    func shouldProcess(on date: Date = Date()) -> Bool {
        guard isActive else { return false }
        
        // Check if we've already processed today
        if let lastProcessed = lastProcessed,
           Calendar.current.isDate(lastProcessed, inSameDayAs: date) {
            return false
        }
        
        // Check if it's time to process
        return date >= nextDue
    }
    
    func updateNextDue() -> RecurringTransaction {
        var updated = self
        updated.nextDue = frequency.nextDate(from: nextDue)
        updated.lastProcessed = Date()
        return updated
    }
}

// MARK: - Budget Management Models

struct Budget: Identifiable, Codable {
    let id = UUID()
    var name: String
    var category: Expense.ExpenseCategory
    var monthlyLimit: Double
    var startDate: Date
    var endDate: Date?
    var isActive: Bool = true
    var alertThreshold: Double = 0.8 // Alert at 80%
    var description: String?
    
    func currentSpent(expenses: [Expense]) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        return expenses.filter { expense in
            expense.category == category &&
            calendar.isDate(expense.date, equalTo: now, toGranularity: .month) &&
            calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
        }.reduce(0) { $0 + $1.amount }
    }
    
    func progressPercentage(expenses: [Expense]) -> Double {
        let spent = currentSpent(expenses: expenses)
        return monthlyLimit > 0 ? min(spent / monthlyLimit, 1.0) : 0.0
    }
    
    func remainingAmount(expenses: [Expense]) -> Double {
        return monthlyLimit - currentSpent(expenses: expenses)
    }
    
    func status(expenses: [Expense]) -> BudgetStatus {
        let progress = progressPercentage(expenses: expenses)
        if progress >= 1.0 {
            return .overBudget
        } else if progress >= alertThreshold {
            return .nearLimit
        } else {
            return .onTrack
        }
    }
}

enum BudgetStatus {
    case onTrack, nearLimit, overBudget
    
    var color: String {
        switch self {
        case .onTrack: return "#34C759"
        case .nearLimit: return "#FF9500"
        case .overBudget: return "#FF3B30"
        }
    }
    
    var icon: String {
        switch self {
        case .onTrack: return "checkmark.circle.fill"
        case .nearLimit: return "exclamationmark.triangle.fill"
        case .overBudget: return "xmark.circle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .onTrack: return "On Track"
        case .nearLimit: return "Near Limit"
        case .overBudget: return "Over Budget"
        }
    }
}

// MARK: - Enhanced Debt Management Models

struct DebtPayoffStrategy: Codable {
    let monthlyPayment: Double
    let payoffDate: Date
    let totalInterestPaid: Double
    let totalAmountPaid: Double
    let monthsToPayoff: Int
    
    static func calculate(
        principal: Double,
        interestRate: Double,
        monthlyPayment: Double
    ) -> DebtPayoffStrategy? {
        guard principal > 0, interestRate >= 0, monthlyPayment > 0 else { return nil }
        
        let monthlyRate = interestRate / 100 / 12
        var balance = principal
        var totalInterest: Double = 0
        var months = 0
        
        // Prevent infinite loop
        let maxMonths = 1000
        
        while balance > 0.01 && months < maxMonths {
            let interestPayment = balance * monthlyRate
            let principalPayment = min(monthlyPayment - interestPayment, balance)
            
            if principalPayment <= 0 {
                // Payment too small to cover interest
                return nil
            }
            
            balance -= principalPayment
            totalInterest += interestPayment
            months += 1
        }
        
        let payoffDate = Calendar.current.date(byAdding: .month, value: months, to: Date()) ?? Date()
        
        return DebtPayoffStrategy(
            monthlyPayment: monthlyPayment,
            payoffDate: payoffDate,
            totalInterestPaid: totalInterest,
            totalAmountPaid: principal + totalInterest,
            monthsToPayoff: months
        )
    }
}

struct BudgetAnalysis {
    let totalBudgeted: Double
    let totalSpent: Double
    let budgetsOnTrack: Int
    let budgetsNearLimit: Int
    let budgetsOverBudget: Int
    let overallStatus: BudgetStatus
    
    static func analyze(budgets: [Budget], expenses: [Expense]) -> BudgetAnalysis {
        let activeBudgets = budgets.filter { $0.isActive }
        let totalBudgeted = activeBudgets.reduce(0) { $0 + $1.monthlyLimit }
        let totalSpent = activeBudgets.reduce(0) { $0 + $1.currentSpent(expenses: expenses) }
        
        var onTrack = 0, nearLimit = 0, overBudget = 0
        
        for budget in activeBudgets {
            switch budget.status(expenses: expenses) {
            case .onTrack: onTrack += 1
            case .nearLimit: nearLimit += 1
            case .overBudget: overBudget += 1
            }
        }
        
        let overallStatus: BudgetStatus = {
            if overBudget > 0 { return .overBudget }
            if nearLimit > 0 { return .nearLimit }
            return .onTrack
        }()
        
        return BudgetAnalysis(
            totalBudgeted: totalBudgeted,
            totalSpent: totalSpent,
            budgetsOnTrack: onTrack,
            budgetsNearLimit: nearLimit,
            budgetsOverBudget: overBudget,
            overallStatus: overallStatus
        )
    }
}

// MARK: - Core Data Models

struct Income: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var source: String
    var category: IncomeCategory
    var date: Date
    var description: String?
    
    enum IncomeCategory: String, CaseIterable, Codable {
        case salary = "Salary"
        case freelance = "Freelance"
        case investment = "Investment"
        case bonus = "Bonus"
        case rental = "Rental"
        case other = "Other"
        
        var color: String {
            switch self {
            case .salary: return "#A855F7"
            case .freelance: return "#3B82F6"
            case .investment: return "#F97316"
            case .bonus: return "#34C759"
            case .rental: return "#FF9500"
            case .other: return "#8A8A8E"
            }
        }
    }
    
    // Manual Firestore encoding
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "amount": amount,
            "source": source,
            "category": category.rawValue,
            "date": date
        ]
        if let description = description {
            dict["description"] = description
        }
        return dict
    }
    
    // Manual Firestore decoding
    static func from(dictionary dict: [String: Any]) -> Income? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let amount = dict["amount"] as? Double,
              let source = dict["source"] as? String,
              let categoryString = dict["category"] as? String,
              let category = IncomeCategory(rawValue: categoryString),
              let date = dict["date"] as? Date else {
            return nil
        }
        
        let description = dict["description"] as? String
        
        return Income(
            id: id,
            amount: amount,
            source: source,
            category: category,
            date: date,
            description: description
        )
    }
}

struct Expense: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var expenseDescription: String
    var isRecurring: Bool = false
    var notes: String? = nil
    
    enum ExpenseCategory: String, CaseIterable, Codable {
        case food = "Food & Dining"
        case transportation = "Transportation"
        case housing = "Housing"
        case utilities = "Utilities"
        case entertainment = "Entertainment"
        case healthcare = "Healthcare"
        case shopping = "Shopping"
        case education = "Education"
        case travel = "Travel"
        case other = "Other"
        
        var color: String {
            switch self {
            case .food: return "#A855F7"
            case .transportation: return "#3B82F6"
            case .housing: return "#F97316"
            case .utilities: return "#34C759"
            case .entertainment: return "#FF9500"
            case .healthcare: return "#FF3B30"
            case .shopping: return "#8A8A8E"
            case .education: return "#5856D6"
            case .travel: return "#FF2D92"
            case .other: return "#636366"
            }
        }
        
        var icon: String {
            switch self {
            case .food: return "fork.knife"
            case .transportation: return "car.fill"
            case .housing: return "house.fill"
            case .utilities: return "bolt.fill"
            case .entertainment: return "tv.fill"
            case .healthcare: return "cross.fill"
            case .shopping: return "bag.fill"
            case .education: return "book.fill"
            case .travel: return "airplane"
            case .other: return "ellipsis"
            }
        }
    }
    
    // Manual Firestore encoding
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "amount": amount,
            "category": category.rawValue,
            "date": date,
            "expenseDescription": expenseDescription,
            "isRecurring": isRecurring
        ]
    }
    
    // Manual Firestore decoding
    static func from(dictionary dict: [String: Any]) -> Expense? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let amount = dict["amount"] as? Double,
              let categoryString = dict["category"] as? String,
              let category = ExpenseCategory(rawValue: categoryString),
              let date = dict["date"] as? Date,
              let expenseDescription = dict["expenseDescription"] as? String else {
            return nil
        }
        
        let isRecurring = dict["isRecurring"] as? Bool ?? false
        
        return Expense(
            id: id,
            amount: amount,
            category: category,
            date: date,
            expenseDescription: expenseDescription,
            isRecurring: isRecurring
        )
    }
}

struct SavingsGoal: Identifiable, Codable {
    var id = UUID()
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date
    var category: GoalCategory
    var description: String?
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    var isCompleted: Bool {
        currentAmount >= targetAmount
    }
    
    enum GoalCategory: String, CaseIterable, Codable {
        case emergency = "Emergency Fund"
        case vacation = "Vacation"
        case car = "Car"
        case house = "House"
        case education = "Education"
        case retirement = "Retirement"
        case other = "Other"
        
        var color: String {
            switch self {
            case .emergency: return "#FF3B30"
            case .vacation: return "#3B82F6"
            case .car: return "#34C759"
            case .house: return "#A855F7"
            case .education: return "#F97316"
            case .retirement: return "#FF9500"
            case .other: return "#8A8A8E"
            }
        }
        
        var icon: String {
            switch self {
            case .emergency: return "shield.fill"
            case .vacation: return "airplane"
            case .car: return "car.fill"
            case .house: return "house.fill"
            case .education: return "graduationcap.fill"
            case .retirement: return "clock.fill"
            case .other: return "target"
            }
        }
    }
    
    // Manual Firestore encoding
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "targetAmount": targetAmount,
            "currentAmount": currentAmount,
            "deadline": deadline,
            "category": category.rawValue
        ]
        if let description = description {
            dict["description"] = description
        }
        return dict
    }
    
    // Manual Firestore decoding
    static func from(dictionary dict: [String: Any]) -> SavingsGoal? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = dict["title"] as? String,
              let targetAmount = dict["targetAmount"] as? Double,
              let currentAmount = dict["currentAmount"] as? Double,
              let deadline = dict["deadline"] as? Date,
              let categoryString = dict["category"] as? String,
              let category = GoalCategory(rawValue: categoryString) else {
            return nil
        }
        
        let description = dict["description"] as? String
        
        return SavingsGoal(
            id: id,
            title: title,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline,
            category: category,
            description: description
        )
    }
}

struct Liability: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: LiabilityType
    var balance: Double
    var interestRate: Double
    var minimumPayment: Double
    var dueDate: Date
    var description: String?
    
    enum LiabilityType: String, CaseIterable, Codable {
        case creditCard = "Credit Card"
        case personalLoan = "Personal Loan"
        case mortgage = "Mortgage"
        case studentLoan = "Student Loan"
        case carLoan = "Car Loan"
        case other = "Other"
        
        var color: String {
            switch self {
            case .creditCard: return "#FF3B30"
            case .personalLoan: return "#FF9500"
            case .mortgage: return "#A855F7"
            case .studentLoan: return "#3B82F6"
            case .carLoan: return "#34C759"
            case .other: return "#8A8A8E"
            }
        }
        
        var icon: String {
            switch self {
            case .creditCard: return "creditcard.fill"
            case .personalLoan: return "person.fill"
            case .mortgage: return "house.fill"
            case .studentLoan: return "graduationcap.fill"
            case .carLoan: return "car.fill"
            case .other: return "minus.circle.fill"
            }
        }
    }
    
    // Manual Firestore encoding
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "name": name,
            "type": type.rawValue,
            "balance": balance,
            "interestRate": interestRate,
            "minimumPayment": minimumPayment,
            "dueDate": dueDate
        ]
        if let description = description {
            dict["description"] = description
        }
        return dict
    }
    
    // Manual Firestore decoding
    static func from(dictionary dict: [String: Any]) -> Liability? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = dict["name"] as? String,
              let typeString = dict["type"] as? String,
              let type = LiabilityType(rawValue: typeString),
              let balance = dict["balance"] as? Double,
              let interestRate = dict["interestRate"] as? Double,
              let minimumPayment = dict["minimumPayment"] as? Double,
              let dueDate = dict["dueDate"] as? Date else {
            return nil
        }
        
        let description = dict["description"] as? String
        
        return Liability(
            id: id,
            name: name,
            type: type,
            balance: balance,
            interestRate: interestRate,
            minimumPayment: minimumPayment,
            dueDate: dueDate,
            description: description
        )
    }
    
    // MARK: - Debt Management Features
    
    func payoffStrategy(monthlyPayment: Double? = nil) -> DebtPayoffStrategy? {
        let payment = monthlyPayment ?? minimumPayment
        return DebtPayoffStrategy.calculate(
            principal: balance,
            interestRate: interestRate,
            monthlyPayment: payment
        )
    }
    
    func minimumPayoffStrategy() -> DebtPayoffStrategy? {
        return payoffStrategy(monthlyPayment: minimumPayment)
    }
    
    func acceleratedPayoffStrategy(extraPayment: Double) -> DebtPayoffStrategy? {
        return payoffStrategy(monthlyPayment: minimumPayment + extraPayment)
    }
    
    func debtToIncomeRatio(monthlyIncome: Double) -> Double {
        guard monthlyIncome > 0 else { return 0 }
        return minimumPayment / monthlyIncome
    }
    
    var isHighInterest: Bool {
        return interestRate > 15.0 // Consider high if over 15%
    }
    
    var priority: DebtPriority {
        if isHighInterest {
            return .high
        } else if interestRate > 7.0 {
            return .medium
        } else {
            return .low
        }
    }
}

enum DebtPriority: String {
    case high = "High Priority"
    case medium = "Medium Priority"
    case low = "Low Priority"
    
    var color: String {
        switch self {
        case .high: return "#FF3B30"
        case .medium: return "#FF9500"
        case .low: return "#34C759"
        }
    }
    
    var description: String {
        switch self {
        case .high: return "Pay off first - high interest"
        case .medium: return "Pay extra when possible"
        case .low: return "Minimum payments are fine"
        }
    }
}

// MARK: - Transaction Protocol

protocol Transaction {
    var id: UUID { get }
    var amount: Double { get }
    var date: Date { get }
    var transactionDescription: String? { get }
}

extension Income: Transaction {
    var transactionDescription: String? { self.description }
}

extension Expense: Transaction {
    var transactionDescription: String? { self.expenseDescription }
}

// MARK: - Financial Summary

struct FinancialSummary {
    let totalIncome: Double
    let totalExpenses: Double
    let totalAssets: Double
    let totalLiabilities: Double
    
    var netWorth: Double {
        totalAssets - totalLiabilities
    }
    
    var monthlySavings: Double {
        totalIncome - totalExpenses
    }
} 
