// CRITICAL FIX: Button Styling Consistency
// Replace all primary buttons with .goldButton() and secondary buttons with .secondaryButton()

// In ContentView.swift - Fix Add Liability Button:
// BEFORE:
Button(action: { showingAddLiability = true }) {
    Text("Add Liability")
        .font(.headline)
        .foregroundColor(.black)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.aurumGold)
        .cornerRadius(25)
}

// AFTER:
Button(action: { showingAddLiability = true }) {
    Text("Add Liability")
        .font(.headline)
}
.goldButton()

// In AuthView.swift - Fix Authentication Button:
// BEFORE:
Button(action: { Task { await authenticate() } }) {
    Text(isSignUp ? "Sign Up" : "Sign In")
        .font(.headline)
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.aurumGold)
        .cornerRadius(12)
}

// AFTER:
Button(action: { Task { await authenticate() } }) {
    Text(isSignUp ? "Sign Up" : "Sign In")
        .font(.headline)
        .frame(maxWidth: .infinity)
}
.goldButton()

// In InputForms.swift - Fix Save Buttons:
// BEFORE:
.foregroundColor(.black)
.padding(.horizontal, 24)
.padding(.vertical, 12)
.background(Color.aurumGold)
.cornerRadius(25)

// AFTER:
.goldButton()

// Add Secondary Button Usage:
Button("Cancel") {
    // Cancel action
}
.secondaryButton()

// VALIDATION RULE: 
// - All primary CTAs (Save, Add, Sign In, etc.) MUST use .goldButton()
// - All secondary actions (Cancel, View All, etc.) MUST use .secondaryButton()
// - No custom button styling allowed outside of these two styles