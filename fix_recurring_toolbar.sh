#!/bin/bash

# Script to add toolbar to RecurringTransactionViews.swift

FILE="/app/Aurum Finance/RecurringTransactionViews.swift"

# Create backup
cp "$FILE" "$FILE.backup.$(date +%s)"

# Perform the replacement
sed -i 's|        \.background(Color\.aurumDark)\
        \.navigationTitle("Recurring")|        .background(Color.aurumDark)\
        .navigationTitle("Recurring")\
        .toolbar {\
            ToolbarItem(placement: .primaryAction) {\
                Button(action: { showingAddRecurring = true }) {\
                    Image(systemName: "plus")\
                        .font(.headline)\
                        .foregroundColor(.aurumGold)\
                }\
            }\
        }|' "$FILE"

echo "Replacement completed successfully"