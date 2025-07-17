#!/usr/bin/env python3

import re

# Read the file
with open('/app/Aurum Finance/DashboardView.swift', 'r') as f:
    content = f.read()

# Define the old text to replace
old_text = """                    // Enhanced Quick Stats with Cash Flow Indicators
                    enhancedQuickStatsSection(width: geometry.size.width)
                        .id(financeStore.financialSummary.totalIncome)
                    
                    // Enhanced Charts Section with Better Analytics
                    enhancedChartsSection(width: geometry.size.width)
                        .id(financeStore.financialSummary.totalExpenses)"""

# Define the new text
new_text = """                    // Adaptive Layout for Enhanced Sections
                    #if os(macOS)
                    HStack(alignment: .top, spacing: 24) {
                        VStack(spacing: 24) {
                            enhancedQuickStatsSection(width: geometry.size.width * 0.5)
                                .id(financeStore.financialSummary.totalIncome)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 24) {
                            enhancedChartsSection(width: geometry.size.width * 0.5)
                                .id(financeStore.financialSummary.totalExpenses)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    #else
                    // Enhanced Quick Stats with Cash Flow Indicators
                    enhancedQuickStatsSection(width: geometry.size.width)
                        .id(financeStore.financialSummary.totalIncome)
                    
                    // Enhanced Charts Section with Better Analytics
                    enhancedChartsSection(width: geometry.size.width)
                        .id(financeStore.financialSummary.totalExpenses)
                    #endif"""

# Perform the replacement
if old_text in content:
    new_content = content.replace(old_text, new_text)
    
    # Write the modified content back to the file
    with open('/app/Aurum Finance/DashboardView.swift', 'w') as f:
        f.write(new_content)
    
    print("Successfully replaced the text in DashboardView.swift")
else:
    print("Old text not found in the file")
    print("Searching for similar patterns...")
    
    # Let's check what's actually in the file around those lines
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'enhancedQuickStatsSection' in line:
            print(f"Line {i+1}: {line}")
            # Print context
            start = max(0, i-3)
            end = min(len(lines), i+10)
            print("Context:")
            for j in range(start, end):
                marker = ">>> " if j == i else "    "
                print(f"{marker}{j+1}: {lines[j]}")
            print()