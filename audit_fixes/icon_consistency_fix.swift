// MEDIUM PRIORITY FIX: Icon Usage Consistency
// Standardize SF Symbol usage across all components

// ICON STANDARDS:
// - Add actions: "plus.circle.fill"
// - Navigation: "house.fill", "list.bullet", "target", "chart.pie", "arrow.clockwise.circle", "creditcard"
// - Status indicators: "checkmark.circle.fill", "exclamationmark.triangle.fill", "xmark.circle.fill"
// - Profile/Settings: "person.circle.fill"
// - Notifications: "bell.fill"

// In ContentView.swift - Fix Add Button Icons:
// BEFORE:
Image(systemName: "plus")

// AFTER:
Image(systemName: "plus.circle.fill")

// In DashboardView.swift - Fix Notification Icon:
// BEFORE:
Image(systemName: "bell")

// AFTER:
Image(systemName: "bell.fill")

// In Various Views - Fix Status Icons:
// Success Status:
Image(systemName: "checkmark.circle.fill")
    .foregroundColor(.aurumGreen)

// Warning Status:
Image(systemName: "exclamationmark.triangle.fill")
    .foregroundColor(.aurumWarning)

// Error Status:
Image(systemName: "xmark.circle.fill")
    .foregroundColor(.aurumRed)

// Profile Icon:
Image(systemName: "person.circle.fill")
    .foregroundColor(.aurumGold)

// Add to Extensions.swift - Icon Constants:
extension Image {
    static let aurumAdd = Image(systemName: "plus.circle.fill")
    static let aurumProfile = Image(systemName: "person.circle.fill")
    static let aurumNotification = Image(systemName: "bell.fill")
    static let aurumSuccess = Image(systemName: "checkmark.circle.fill")
    static let aurumWarning = Image(systemName: "exclamationmark.triangle.fill")
    static let aurumError = Image(systemName: "xmark.circle.fill")
    static let aurumEdit = Image(systemName: "pencil.circle.fill")
    static let aurumDelete = Image(systemName: "trash.circle.fill")
    static let aurumSettings = Image(systemName: "gear.circle.fill")
}

// Usage Examples:
Button(action: addAction) {
    Image.aurumAdd
        .foregroundColor(.aurumGold)
}

Text("Success")
    .foregroundColor(.aurumGreen)
    .overlay(
        Image.aurumSuccess
            .foregroundColor(.aurumGreen)
            .position(x: 0, y: 0)
    )