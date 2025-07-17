// HIGH PRIORITY FIX: Card Styling Consistency
// Ensure all card-like components use .cardStyle() modifier

// In BudgetViews.swift - Fix Card Styling:
// BEFORE:
.background(Color.aurumCard)
.cornerRadius(16)
.overlay(
    RoundedRectangle(cornerRadius: 16)
        .stroke(Color.aurumBorder, lineWidth: 1)
)

// AFTER:
.cardStyle()

// In DebtManagementViews.swift - Fix Card Styling:
// BEFORE:
.background(Color.aurumCard)
.cornerRadius(16)
.overlay(
    RoundedRectangle(cornerRadius: 16)
        .stroke(Color.aurumBorder, lineWidth: 1)
)

// AFTER:
.cardStyle()

// In RecurringTransactionViews.swift - Fix Card Styling:
// BEFORE:
.background(Color.aurumCard)
.cornerRadius(16)
.overlay(
    RoundedRectangle(cornerRadius: 16)
        .stroke(Color.aurumBorder, lineWidth: 1)
)

// AFTER:
.cardStyle()

// In CustomInputFields.swift - Fix Input Field Styling:
// BEFORE:
.background(
    RoundedRectangle(cornerRadius: 12)
        .fill(Color.black.opacity(0.3))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.aurumGray.opacity(0.3), lineWidth: 2)
        )
)

// AFTER:
.inputFieldStyle()

// Add to Extensions.swift - Input Field Style:
extension View {
    func inputFieldStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.aurumGray.opacity(0.3), lineWidth: 2)
                    )
            )
    }
    
    func inputFieldStyleFocused() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.aurumGold, lineWidth: 2)
                    )
            )
    }
}

// VALIDATION: All card-like components must use:
// - .cardStyle() for main cards
// - .inputFieldStyle() for input fields
// - No custom background/cornerRadius combinations