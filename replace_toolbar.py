#!/usr/bin/env python3

import re

# Read the file
with open('/app/Aurum Finance/ContentView.swift', 'r') as f:
    content = f.read()

# Define the old and new strings
old_str = """                ToolbarItem(placement: .primaryAction) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }"""

new_str = """                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddGoal = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(.aurumGold)
                    }
                }"""

# Find all occurrences to see which one to replace
occurrences = []
start = 0
while True:
    pos = content.find(old_str, start)
    if pos == -1:
        break
    occurrences.append(pos)
    start = pos + 1

print(f"Found {len(occurrences)} occurrences of the pattern")

# We need to find the one in SavingsGoalsView
# Look for the context around each occurrence
for i, pos in enumerate(occurrences):
    # Get context before and after
    context_before = content[max(0, pos-500):pos]
    context_after = content[pos+len(old_str):pos+len(old_str)+500]
    
    print(f"\nOccurrence {i+1} at position {pos}:")
    print("Context before:", context_before[-100:])
    print("Context after:", context_after[:100])
    
    # Check if this is in SavingsGoalsView
    if "SavingsGoalsView" in context_before:
        print(f"This is the SavingsGoalsView occurrence - replacing it")
        # Replace only this occurrence
        content = content[:pos] + new_str + content[pos+len(old_str):]
        break

# Write the modified content back
with open('/app/Aurum Finance/ContentView.swift', 'w') as f:
    f.write(content)

print("Replacement completed")