#!/usr/bin/env python3

import re

# Read the file
with open('/app/Aurum Finance/ContentView.swift', 'r') as f:
    content = f.read()

# Define the old and new strings
old_str = '''                            Button(action: { showingAddLiability = true }) {
                                Text("Add Liability")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.aurumGold)
                                    .cornerRadius(25)
                            }'''

new_str = '''                            Button(action: { showingAddLiability = true }) {
                                Text("Add Liability")
                                    .font(.headline)
                            }
                            .goldButton()'''

# Perform the replacement
if old_str in content:
    content = content.replace(old_str, new_str)
    print("Replacement successful!")
else:
    print("Old string not found in file")
    print("Searching for similar patterns...")
    # Let's try to find the button pattern
    pattern = r'Button\(action: \{ showingAddLiability = true \}\) \{[^}]*Text\("Add Liability"\)[^}]*\}'
    matches = re.findall(pattern, content, re.DOTALL)
    if matches:
        print(f"Found {len(matches)} similar patterns:")
        for i, match in enumerate(matches):
            print(f"Match {i+1}:")
            print(match)
    else:
        print("No similar patterns found")

# Write the file back
with open('/app/Aurum Finance/ContentView.swift', 'w') as f:
    f.write(content)

print("File processing complete")