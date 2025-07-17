#!/usr/bin/env python3

import re

# Read the file
with open('/app/Aurum Finance/BudgetViews.swift', 'r') as f:
    content = f.read()

# Define the old text to replace
old_text = '''                ForEach(financeStore.budgets.filter { $0.isActive }) { budget in
                    BudgetCard(budget: budget, expenses: financeStore.expenses)
                }
                
                // Add new budget button
                Button(action: { showingAddBudget = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.aurumPurple)
                        
                        Text("Add New Budget")
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

# Define the new text
new_text = '''                ForEach(financeStore.budgets.filter { $0.isActive }) { budget in
                    BudgetCard(budget: budget, expenses: financeStore.expenses)
                }'''

# Perform the replacement
if old_text in content:
    new_content = content.replace(old_text, new_text)
    
    # Write the updated content back to the file
    with open('/app/Aurum Finance/BudgetViews.swift', 'w') as f:
        f.write(new_content)
    
    print("Replacement successful!")
else:
    print("Old text not found in file")
    print("Searching for similar patterns...")
    
    # Let's check what's actually there
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'ForEach(financeStore.budgets.filter' in line:
            print(f"Found ForEach at line {i+1}")
            # Print surrounding context
            start = max(0, i-2)
            end = min(len(lines), i+25)
            for j in range(start, end):
                print(f"{j+1:3}: {lines[j]}")
            break