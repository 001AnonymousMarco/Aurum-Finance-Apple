#!/bin/bash

# Replace the Add Liability button styling
sed -i 's/Button(action: { showingAddLiability = true }) {/Button(action: { showingAddLiability = true }) {/g' "/app/Aurum Finance/ContentView.swift"
sed -i '/Text("Add Liability")/,/\.cornerRadius(25)/{
    /Text("Add Liability")/!{
        /\.font(.headline)/!{
            /\.foregroundColor(.black)/d
            /\.padding(.horizontal, 24)/d
            /\.padding(.vertical, 12)/d
            /\.background(Color.aurumGold)/d
            /\.cornerRadius(25)/d
        }
    }
}' "/app/Aurum Finance/ContentView.swift"

# Add the goldButton() modifier
sed -i '/Text("Add Liability")/,/}$/{
    /}$/{
        i\            }\
        i\            .goldButton()
        d
    }
}' "/app/Aurum Finance/ContentView.swift"