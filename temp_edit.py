#!/usr/bin/env python3

import re

# Read the file
with open('/app/Aurum Finance/DashboardView.swift', 'r') as f:
    content = f.read()

# Define the old text to replace
old_text = '''            let columns = width > 1000 ? [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ] : [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]'''

# Define the new text
new_text = '''            let columns = {
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
            }()'''

# Perform the replacement
if old_text in content:
    new_content = content.replace(old_text, new_text)
    
    # Write back to file
    with open('/app/Aurum Finance/DashboardView.swift', 'w') as f:
        f.write(new_content)
    
    print("Replacement successful!")
else:
    print("Old text not found in file")
    print("Searching for similar patterns...")
    # Let's check what's actually there
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'let columns = width > 1000' in line:
            print(f"Found at line {i+1}: {line}")
            # Print surrounding lines
            start = max(0, i-2)
            end = min(len(lines), i+10)
            for j in range(start, end):
                print(f"{j+1:3}: {lines[j]}")
            break