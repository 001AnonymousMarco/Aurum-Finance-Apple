import Foundation

// MARK: - Type Aliases
typealias ExpenseCategory = Expense.ExpenseCategory

// MARK: - View Models

enum AddSheetType {
    case income, expense, savingsGoal, liability
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
