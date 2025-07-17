#!/usr/bin/env python3

# Read the file
with open('/app/Aurum Finance/ContentView.swift', 'r') as f:
    content = f.read()

# Define the old and new strings with correct indentation
old_str = """            ToolbarItem(placement: .primaryAction) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }"""

new_str = """            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddGoal = true }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }
            }"""

# Find the SavingsGoalsView occurrence
pos = content.find("showingAddGoal = false")
if pos != -1:
    # Find the toolbar section after this position
    toolbar_pos = content.find(".toolbar {", pos)
    if toolbar_pos != -1:
        # Find the ToolbarItem after the toolbar
        toolbaritem_pos = content.find(old_str, toolbar_pos)
        if toolbaritem_pos != -1:
            print(f"Found the SavingsGoalsView toolbar at position {toolbaritem_pos}")
            # Replace only this occurrence
            content = content[:toolbaritem_pos] + new_str + content[toolbaritem_pos+len(old_str):]
            print("Replacement completed successfully")
        else:
            print("Could not find ToolbarItem in SavingsGoalsView")
    else:
        print("Could not find .toolbar in SavingsGoalsView")
else:
    print("Could not find SavingsGoalsView")

# Write the modified content back
with open('/app/Aurum Finance/ContentView.swift', 'w') as f:
    f.write(content)