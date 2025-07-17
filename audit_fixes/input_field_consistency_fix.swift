// HIGH PRIORITY FIX: Input Field Styling Consistency
// Standardize all input field styling across the application

// In InputForms.swift - Fix Text Field Styling:
// BEFORE:
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

// AFTER:
extension View {
    func aurumTextFieldStyle() -> some View {
        self
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .inputFieldStyle()
    }
}

// In AuthView.swift - Standardize Text Field Style:
// BEFORE:
struct AurumTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.aurumGray.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

// AFTER:
struct AurumTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .inputFieldStyle()
    }
}

// In CustomInputFields.swift - Standardize Input Styling:
// BEFORE:
.background(
    RoundedRectangle(cornerRadius: 12)
        .fill(Color.black.opacity(0.3))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEditing ? Color.aurumGold : Color.aurumGray.opacity(0.3), lineWidth: 2)
        )
)

// AFTER:
.background(
    RoundedRectangle(cornerRadius: 12)
        .fill(Color.black.opacity(0.3))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEditing ? Color.aurumGold : Color.aurumGray.opacity(0.3), lineWidth: 2)
        )
)

// Add Focused State Handling:
extension View {
    func inputFieldStyle(isFocused: Bool = false) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFocused ? Color.aurumGold : Color.aurumGray.opacity(0.3), lineWidth: 2)
                    )
            )
    }
}

// VALIDATION:
// - All text inputs must use .aurumTextFieldStyle()
// - All amount inputs must use AmountInputField
// - All percentage inputs must use PercentageInputField
// - Focus states must show aurumGold border