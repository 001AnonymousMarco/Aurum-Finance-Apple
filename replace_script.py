#!/usr/bin/env python3

import re

# Read the file
with open('/app/Aurum Finance/Extensions.swift', 'r') as f:
    content = f.read()

# Define the old text to replace
old_text = """    func pageMargins() -> some View {
        self.padding(.spacingL)
    }
}"""

# Define the new text
new_text = """    func pageMargins() -> some View {
        self.padding(.spacingL)
    }
}

// MARK: - Animation Constants

extension Animation {
    static let aurumQuick = Animation.easeInOut(duration: 0.2)
    static let aurumStandard = Animation.easeInOut(duration: 0.3)
    static let aurumSlow = Animation.easeInOut(duration: 0.5)
    static let aurumSpring = Animation.interpolatingSpring(stiffness: 300, damping: 30)
    static let aurumSpringBouncy = Animation.interpolatingSpring(stiffness: 400, damping: 25)
}

// MARK: - Animation View Extensions

extension View {
    func buttonAnimation(isPressed: Bool = false) -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.aurumQuick, value: isPressed)
    }
    
    func cardAnimation(isHovered: Bool = false) -> some View {
        self
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.aurumStandard, value: isHovered)
    }
    
    func fadeInAnimation(isVisible: Bool = true) -> some View {
        self
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.aurumStandard, value: isVisible)
    }
    
    func slideInAnimation(isVisible: Bool = true) -> some View {
        self
            .offset(y: isVisible ? 0 : 20)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.aurumSpring, value: isVisible)
    }
}"""

# Perform the replacement
if old_text in content:
    new_content = content.replace(old_text, new_text)
    
    # Write the updated content back to the file
    with open('/app/Aurum Finance/Extensions.swift', 'w') as f:
        f.write(new_content)
    
    print("Replacement successful!")
else:
    print("Old text not found in file")
    print("Looking for:")
    print(repr(old_text))
    print("\nActual end of file:")
    print(repr(content[-200:]))