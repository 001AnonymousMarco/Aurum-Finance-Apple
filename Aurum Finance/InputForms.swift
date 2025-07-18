import SwiftUI

// Add view modifier extension at the top
extension View {
    func aurumTextFieldStyle(placeholder: String) -> some View {
        self
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.aurumGray.opacity(0.3), lineWidth: 2)
                    )
            )
    }
}

// MARK: - Add Income View

struct AddIncomeView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var source: String = ""
    @State private var category: Income.IncomeCategory = .salary
    @State private var date: Date = Date()
    @State private var description: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.aurumGreen)
                    
                    Text("Add Income")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 28) {
                    // Amount
                    FormSection(title: "Amount") {
                        AmountInputField(amount: $amount)
                            .padding(.horizontal, 4)
                    }
                    
                    // Source
                    FormSection(title: "Source") {
                        TextField("e.g., Tech Corp, Freelance Client", text: $source)
                            .aurumTextFieldStyle(placeholder: "e.g., Tech Corp, Freelance Client")
                    }
                    
                    // Category
                    FormSection(title: "Category") {
                        CategoryPicker(
                            selection: $category,
                            categories: Income.IncomeCategory.allCases
                        ) { category in
                            CategoryRow(
                                title: category.rawValue,
                                color: Color(hex: category.color),
                                isSelected: self.category == category
                            )
                        }
                    }
                    
                    // Date
                    FormSection(title: "Date") {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .accentColor(.aurumGold)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                    }
                    
                    // Description
                    FormSection(title: "Description (Optional)") {
                        TextField("Add a note...", text: $description)
                            .aurumTextFieldStyle(placeholder: "Add a note...")
                    }
                }
                .padding(.horizontal, 24)
                
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
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.body.weight(.medium))
                .foregroundColor(.aurumGray)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveIncome()
                }
                .font(.body.weight(.semibold))
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #else
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.body.weight(.medium))
                .foregroundColor(.aurumGray)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveIncome()
                }
                .font(.body.weight(.semibold))
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #endif
        }
    }
    
    private var isValidInput: Bool {
        !amount.isEmpty && !source.isEmpty && Double(amount) != nil
    }
    
    private func saveIncome() {
        guard let amountValue = Double(amount) else { return }
        
        let income = Income(
            amount: amountValue,
            source: source,
            category: category,
            date: date,
            description: description.isEmpty ? nil : description
        )
        
        financeStore.addIncome(income)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Add Expense View

struct AddExpenseView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var category: ExpenseCategory = .food
    @State private var date: Date = Date()
    @State private var expenseDescription: String = ""
    @State private var isRecurring: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.aurumRed)
                    
                    Text("Add Expense")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20) {
                    // Amount
                    FormSection(title: "Amount") {
                        AmountInputField(amount: $amount)
                    }
                    
                    // Category
                    FormSection(title: "Category") {
                        CategoryPicker(
                            selection: $category,
                            categories: ExpenseCategory.allCases
                        ) { category in
                            CategoryRow(
                                title: category.rawValue,
                                icon: category.icon,
                                color: Color(hex: category.color),
                                isSelected: self.category == category
                            )
                        }
                    }
                    
                    // Description
                    FormSection(title: "Description") {
                        TextField("e.g., Grocery shopping, Gas", text: $expenseDescription)
                            .aurumTextFieldStyle(placeholder: "e.g., Grocery shopping, Gas")
                    }
                    
                    // Date
                    FormSection(title: "Date") {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .accentColor(.aurumGold)
                            .padding()
                            .background(Color.aurumCard)
                            .cornerRadius(12)
                    }
                    
                    // Recurring Toggle
                    FormSection(title: "Recurring Expense") {
                        Toggle("", isOn: $isRecurring)
                            .toggleStyle(SwitchToggleStyle(tint: .aurumGold))
                            .padding()
                            .background(Color.aurumCard)
                            .cornerRadius(12)
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
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.aurumGray)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveExpense()
                }
                .fontWeight(.semibold)
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.aurumGray)
            }
            
            ToolbarItem(placement: .automatic) {
                Button("Save") {
                    saveExpense()
                }
                .fontWeight(.semibold)
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #endif
        }
    }
    
    private var isValidInput: Bool {
        !amount.isEmpty && !expenseDescription.isEmpty && Double(amount) != nil
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let expense = Expense(
            amount: amountValue,
            category: category,
            date: date,
            expenseDescription: expenseDescription,
            isRecurring: isRecurring
        )
        
        financeStore.addExpense(expense)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Add Savings Goal View

struct AddSavingsGoalView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @Environment(\.presentationMode) var presentationMode
    
    private let goalToEdit: SavingsGoal?
    
    @State private var title: String = ""
    @State private var targetAmount: String = ""
    @State private var currentAmount: String = ""
    @State private var deadline: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var category: SavingsGoal.GoalCategory = .emergency
    @State private var description: String = ""
    
    init(goal: SavingsGoal? = nil) {
        self.goalToEdit = goal
        _title = State(initialValue: goal?.title ?? "")
        _targetAmount = State(initialValue: goal?.targetAmount.formatted() ?? "")
        _currentAmount = State(initialValue: goal?.currentAmount.formatted() ?? "")
        _deadline = State(initialValue: goal?.deadline ?? Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date())
        _category = State(initialValue: goal?.category ?? .emergency)
        _description = State(initialValue: goal?.description ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.title)
                        .foregroundColor(.aurumBlue)
                    
                    Text(goalToEdit != nil ? "Edit Savings Goal" : "Add Savings Goal")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20) {
                    // Title
                    FormSection(title: "Goal Title") {
                        TextField("e.g., Emergency Fund, Vacation", text: $title)
                            .aurumTextFieldStyle(placeholder: "e.g., Emergency Fund, Vacation")
                    }
                    
                    // Target Amount
                    FormSection(title: "Target Amount") {
                        AmountInputField(amount: $targetAmount)
                    }
                    
                    // Current Amount
                    FormSection(title: "Current Amount") {
                        AmountInputField(amount: $currentAmount)
                    }
                    
                    // Category
                    FormSection(title: "Category") {
                        CategoryPicker(
                            selection: $category,
                            categories: SavingsGoal.GoalCategory.allCases
                        ) { category in
                            CategoryRow(
                                title: category.rawValue,
                                icon: category.icon,
                                color: Color(hex: category.color),
                                isSelected: self.category == category
                            )
                        }
                    }
                    
                    // Deadline
                    FormSection(title: "Target Date") {
                        DatePicker("", selection: $deadline, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .accentColor(.aurumGold)
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
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.body.weight(.medium))
                .foregroundColor(.aurumGray)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveSavingsGoal()
                }
                .font(.body.weight(.semibold))
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #else
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.aurumGray)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveSavingsGoal()
                }
                .fontWeight(.semibold)
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #endif
        }
    }
    
    private var isValidInput: Bool {
        !title.isEmpty && !targetAmount.isEmpty && Double(targetAmount) != nil && Double(currentAmount) != nil
    }
    
    private func saveSavingsGoal() {
        guard let target = Double(targetAmount),
              let current = Double(currentAmount) else { return }
        
        if let existingGoal = goalToEdit {
            // Update existing goal
            let updatedGoal = SavingsGoal(
                id: existingGoal.id,
                title: title,
                targetAmount: target,
                currentAmount: current,
                deadline: deadline,
                category: category,
                description: description.isEmpty ? nil : description
            )
            financeStore.updateSavingsGoal(updatedGoal)
        } else {
            // Create new goal
            let goal = SavingsGoal(
                title: title,
                targetAmount: target,
                currentAmount: current,
                deadline: deadline,
                category: category,
                description: description.isEmpty ? nil : description
            )
            financeStore.addSavingsGoal(goal)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Add Liability View

struct AddLiabilityView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @Environment(\.presentationMode) var presentationMode
    
    private let liabilityToEdit: Liability?
    
    @State private var name: String = ""
    @State private var type: Liability.LiabilityType = .creditCard
    @State private var balance: String = ""
    @State private var interestRate: String = ""
    @State private var minimumPayment: String = ""
    @State private var dueDate: Date = Date()
    @State private var description: String = ""
    
    init(liability: Liability? = nil) {
        self.liabilityToEdit = liability
        _name = State(initialValue: liability?.name ?? "")
        _type = State(initialValue: liability?.type ?? .creditCard)
        _balance = State(initialValue: liability?.balance.formatted() ?? "")
        _interestRate = State(initialValue: liability?.interestRate.formatted() ?? "")
        _minimumPayment = State(initialValue: liability?.minimumPayment.formatted() ?? "")
        _dueDate = State(initialValue: liability?.dueDate ?? Date())
        _description = State(initialValue: liability?.description ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "creditcard.fill")
                        .font(.title)
                        .foregroundColor(.aurumOrange)
                    
                    Text(liabilityToEdit != nil ? "Edit Liability" : "Add Liability")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20) {
                    // Name
                    FormSection(title: "Name") {
                        TextField("e.g., Chase Sapphire Card", text: $name)
                            .aurumTextFieldStyle(placeholder: "e.g., Chase Sapphire Card")
                    }
                    
                    // Type
                    FormSection(title: "Type") {
                        CategoryPicker(
                            selection: $type,
                            categories: Liability.LiabilityType.allCases
                        ) { type in
                            CategoryRow(
                                title: type.rawValue,
                                icon: type.icon,
                                color: Color(hex: type.color),
                                isSelected: self.type == type
                            )
                        }
                    }
                    
                    // Balance
                    FormSection(title: "Current Balance") {
                        AmountInputField(amount: $balance)
                    }
                    
                    // Interest Rate
                    FormSection(title: "Interest Rate") {
                        PercentageInputField(percentage: $interestRate)
                    }
                    
                    // Minimum Payment
                    FormSection(title: "Minimum Payment") {
                        AmountInputField(amount: $minimumPayment)
                    }
                    
                    // Due Date
                    FormSection(title: "Next Due Date") {
                        DatePicker("", selection: $dueDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .accentColor(.aurumGold)
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
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.aurumGray)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveLiability()
                }
                .fontWeight(.semibold)
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #else
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.aurumGray)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveLiability()
                }
                .fontWeight(.semibold)
                .foregroundColor(.aurumGold)
                .disabled(!isValidInput)
            }
            #endif
        }
    }
    
    private var isValidInput: Bool {
        !name.isEmpty && !balance.isEmpty && !interestRate.isEmpty && !minimumPayment.isEmpty &&
        Double(balance) != nil && Double(interestRate) != nil && Double(minimumPayment) != nil
    }
    
    private func saveLiability() {
        guard let balanceValue = Double(balance),
              let interestRateValue = Double(interestRate),
              let minimumPaymentValue = Double(minimumPayment) else { return }
        
        if let existingLiability = liabilityToEdit {
            // Update existing liability
            let updatedLiability = Liability(
                id: existingLiability.id,
                name: name,
                type: type,
                balance: balanceValue,
                interestRate: interestRateValue,
                minimumPayment: minimumPaymentValue,
                dueDate: dueDate,
                description: description.isEmpty ? nil : description
            )
            financeStore.updateLiability(updatedLiability)
        } else {
            // Create new liability
            let liability = Liability(
                name: name,
                type: type,
                balance: balanceValue,
                interestRate: interestRateValue,
                minimumPayment: minimumPaymentValue,
                dueDate: dueDate,
                description: description.isEmpty ? nil : description
            )
            financeStore.addLiability(liability)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Supporting Views

struct FormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.aurumGold)
                .padding(.horizontal, 4)
            
            content
                .background(Color.aurumCard.opacity(0.8))
                .cornerRadius(12)
        }
        .padding(.vertical, 8)
    }
}

struct CategoryPicker<T: Hashable & CaseIterable, Content: View>: View {
    @Binding var selection: T
    let categories: [T]
    let content: (T) -> Content
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(categories, id: \.self) { category in
                content(category)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = category
                        }
                    }
            }
        }
        .padding(12)
    }
}

struct CategoryRow: View {
    let title: String
    var icon: String? = nil
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .white : .aurumGray)
                .lineLimit(1)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(color)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.black.opacity(0.5) : Color.black.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? color : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Custom Input Fields

// Amount Input Field moved to CustomInputFields.swift 
