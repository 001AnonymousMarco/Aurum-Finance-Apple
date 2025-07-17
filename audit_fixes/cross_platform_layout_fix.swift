// HIGH PRIORITY FIX: Cross-Platform Layout Consistency
// Ensure proper layout adaptation for both iOS and macOS

// In DashboardView.swift - Fix Grid Layout:
// BEFORE:
let columns = width > 1000 ? [
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16)
] : [
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16)
]

// AFTER:
let columns = {
    #if os(macOS)
    return width > 1200 ? [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ] : width > 800 ? [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ] : [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    #else
    return width > 600 ? [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ] : [
        GridItem(.flexible(), spacing: 16)
    ]
    #endif
}()

// In ContentView.swift - Fix Toolbar Placement:
// BEFORE:
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        profileButton
    }
}

// AFTER:
.toolbar {
    #if os(iOS)
    ToolbarItem(placement: .navigationBarTrailing) {
        profileButton
    }
    #else
    ToolbarItem(placement: .primaryAction) {
        profileButton
    }
    #endif
}

// In InputForms.swift - Fix Sheet Sizing:
// BEFORE:
.frame(width: 500, height: 700)

// AFTER:
#if os(iOS)
.frame(maxWidth: .infinity, maxHeight: .infinity)
#else
.frame(width: 500, height: 700)
#endif

// Add Responsive Utilities to Extensions.swift:
extension View {
    func responsiveWidth(iOS: CGFloat, macOS: CGFloat) -> some View {
        #if os(iOS)
        self.frame(maxWidth: iOS)
        #else
        self.frame(maxWidth: macOS)
        #endif
    }
    
    func responsivePadding(iOS: CGFloat, macOS: CGFloat) -> some View {
        #if os(iOS)
        self.padding(iOS)
        #else
        self.padding(macOS)
        #endif
    }
}