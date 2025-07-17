#!/usr/bin/env python3

import re

file_path = "/app/Aurum Finance/RecurringTransactionViews.swift"

# Read the file
with open(file_path, 'r') as f:
    content = f.read()

# Define the old and new strings
old_str = """        .background(Color.aurumDark)
        .navigationTitle("Recurring")"""

new_str = """        .background(Color.aurumDark)
        .navigationTitle("Recurring")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddRecurring = true }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }
            }
        }"""

# Perform the replacement
if old_str in content:
    new_content = content.replace(old_str, new_str)
    
    # Write back to file
    with open(file_path, 'w') as f:
        f.write(new_content)
    
    print("Replacement completed successfully")
else:
    print("Old string not found in file")
    print("Looking for:")
    print(repr(old_str))