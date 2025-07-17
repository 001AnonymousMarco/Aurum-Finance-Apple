// MEDIUM PRIORITY FIX: Spacing and Padding Consistency
// Establish consistent spacing system throughout the application

// SPACING SYSTEM:
// - Extra Small: 4pt
// - Small: 8pt  
// - Medium: 16pt
// - Large: 24pt
// - Extra Large: 32pt

// Add to Extensions.swift - Spacing Constants:
extension CGFloat {
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
}

// In ContentView.swift - Fix Spacing:
// BEFORE:
VStack(spacing: 24) {
    // Content with mixed spacing
}

// AFTER:
VStack(spacing: .spacingL) {
    // Content with consistent spacing
}

// In DashboardView.swift - Fix Padding:
// BEFORE:
.padding(.horizontal, geometry.size.width * 0.05)

// AFTER:
.padding(.horizontal, .spacingL)

// In Various Card Views - Fix Card Padding:
// BEFORE:
.padding(16)
.padding(20)
.padding(24)

// AFTER:
.padding(.spacingM)  // For most cards
.padding(.spacingL)  // For important cards

// In Input Forms - Fix Form Spacing:
// BEFORE:
VStack(spacing: 28) {
    // Form elements
}

// AFTER:
VStack(spacing: .spacingXL) {
    // Form elements
}

// Add Padding Modifiers to Extensions.swift:
extension View {
    func cardPadding() -> some View {
        self.padding(.spacingM)
    }
    
    func formPadding() -> some View {
        self.padding(.spacingL)
    }
    
    func sectionPadding() -> some View {
        self.padding(.vertical, .spacingM)
    }
    
    func elementSpacing() -> some View {
        self.padding(.spacingS)
    }
}

// VALIDATION RULES:
// - Card internal padding: .spacingM (16pt)
// - Form section spacing: .spacingL (24pt)
// - Element spacing: .spacingS (8pt)
// - Section padding: .spacingM (16pt)
// - Page margins: .spacingL (24pt)