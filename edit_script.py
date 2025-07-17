#!/usr/bin/env python3

import re

# Read the file
with open('/app/Aurum Finance/RecurringTransactionViews.swift', 'r') as f:
    content = f.read()

# Define the old string to replace
old_str = '''                    ForEach(filteredTransactions) { transaction in
                        RecurringTransactionCard(transaction: transaction)
                    }
                    
                    // Add new recurring transaction button
                    Button(action: { showingAddRecurring = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.aurumPurple)
                            
                            Text("Add Recurring Transaction")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.aurumCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.aurumBorder, lineWidth: 1)
                        )
                    }'''

# Define the new string
new_str = '''                    ForEach(filteredTransactions) { transaction in
                        RecurringTransactionCard(transaction: transaction)
                    }'''

# Perform the replacement
if old_str in content:
    new_content = content.replace(old_str, new_str)
    
    # Write the modified content back
    with open('/app/Aurum Finance/RecurringTransactionViews.swift', 'w') as f:
        f.write(new_content)
    
    print("Replacement successful!")
else:
    print("Old string not found in file")
    print("Searching for ForEach pattern...")
    
    # Let's find the actual pattern
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'ForEach(filteredTransactions)' in line:
            print(f"Found ForEach at line {i+1}")
            # Print surrounding context
            start = max(0, i-2)
            end = min(len(lines), i+30)
            for j in range(start, end):
                marker = ">>>" if j == i else "   "
                print(f"{marker} {j+1:3d}: {lines[j]}")
            break