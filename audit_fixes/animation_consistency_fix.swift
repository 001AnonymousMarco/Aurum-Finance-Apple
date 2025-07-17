// LOW PRIORITY FIX: Animation and Transition Consistency
// Add consistent animations throughout the application

// Add to Extensions.swift - Animation Constants:
extension Animation {
    static let aurumQuick = Animation.easeInOut(duration: 0.2)
    static let aurumStandard = Animation.easeInOut(duration: 0.3)
    static let aurumSlow = Animation.easeInOut(duration: 0.5)
    static let aurumSpring = Animation.interpolatingSpring(stiffness: 300, damping: 30)
}

// In ContentView.swift - Add Sheet Animations:
// BEFORE:
.sheet(isPresented: $showingAddSheet) {
    NavigationView {
        AddIncomeView()
    }
}

// AFTER:
.sheet(isPresented: $showingAddSheet) {
    NavigationView {
        AddIncomeView()
    }
    .transition(.move(edge: .bottom))
}

// In DashboardView.swift - Add Loading Animations:
// BEFORE:
if financeStore.isLoading {
    ProgressView()
}

// AFTER:
if financeStore.isLoading {
    ProgressView()
        .scaleEffect(1.2)
        .animation(.aurumSpring, value: financeStore.isLoading)
}

// In Button Actions - Add Feedback Animations:
// BEFORE:
Button(action: {
    // Action
}) {
    Text("Save")
}

// AFTER:
Button(action: {
    withAnimation(.aurumQuick) {
        // Action
    }
}) {
    Text("Save")
}
.scaleEffect(isPressed ? 0.95 : 1.0)
.animation(.aurumQuick, value: isPressed)

// Add Hover Effects for macOS:
#if os(macOS)
.onHover { hovering in
    withAnimation(.aurumQuick) {
        isHovering = hovering
    }
}
.scaleEffect(isHovering ? 1.05 : 1.0)
#endif

// Add to Extensions.swift - Animation Modifiers:
extension View {
    func buttonAnimation() -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.aurumQuick, value: isPressed)
    }
    
    func cardAnimation() -> some View {
        self
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.aurumStandard, value: isHovered)
    }
    
    func fadeInAnimation() -> some View {
        self
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.aurumStandard, value: isVisible)
    }
}