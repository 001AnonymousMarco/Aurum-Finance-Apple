// CRITICAL FIX: Typography Hierarchy Consistency
// Establish consistent text styling rules across all components

// TYPOGRAPHY RULES:
// 1. Primary headings: .title/.title2 + .bold + .white
// 2. Secondary headings: .headline + .semibold + .white  
// 3. Body text: .body + .regular + .white
// 4. Secondary text: .subheadline + .regular + .aurumGray
// 5. Captions: .caption + .regular + .aurumGray

// In BudgetViews.swift - Fix Text Styling:
// BEFORE:
Text("Budget Overview")
    .font(.title2)
    .fontWeight(.bold)
    .foregroundColor(.aurumText)

// AFTER:
Text("Budget Overview")
    .font(.title2)
    .fontWeight(.bold)
    .foregroundColor(.white)

// In DebtManagementViews.swift - Fix Text Styling:
// BEFORE:
Text("Debt Overview")
    .font(.title2)
    .fontWeight(.bold)
    .foregroundColor(.aurumText)

// AFTER:
Text("Debt Overview")
    .font(.title2)
    .fontWeight(.bold)
    .foregroundColor(.white)

// In RecurringTransactionViews.swift - Fix Text Styling:
// BEFORE:
Text("Recurring Transactions")
    .font(.title2)
    .fontWeight(.bold)
    .foregroundColor(.aurumText)

// AFTER:
Text("Recurring Transactions")
    .font(.title2)
    .fontWeight(.bold)
    .foregroundColor(.white)

// CONSISTENT SECONDARY TEXT:
// BEFORE:
.foregroundColor(.aurumSecondaryText)

// AFTER:
.foregroundColor(.aurumGray)

// ADD TO Extensions.swift - Typography Style Modifiers:
extension View {
    func primaryHeading() -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    func secondaryHeading() -> some View {
        self
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
    }
    
    func bodyText() -> some View {
        self
            .font(.body)
            .foregroundColor(.white)
    }
    
    func secondaryText() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(.aurumGray)
    }
    
    func captionText() -> some View {
        self
            .font(.caption)
            .foregroundColor(.aurumGray)
    }
}