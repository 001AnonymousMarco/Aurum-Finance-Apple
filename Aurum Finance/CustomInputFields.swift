import SwiftUI

struct AmountInputField: View {
    @Binding var amount: String
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text("$")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.aurumGold)
                
                TextField("0.00", text: $amount)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .onChange(of: amount) { _, newValue in
                        formatAmount(newValue)
                    }
                    .onTapGesture {
                        isEditing = true
                    }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isEditing ? Color.aurumGold : Color.aurumGray.opacity(0.3), lineWidth: 2)
                    )
            )
            
            // Preview of formatted amount
            if let doubleValue = Double(amount) {
                Text(doubleValue.currencyFormatted)
                    .font(.subheadline)
                    .foregroundColor(.aurumGold)
                    .padding(.horizontal, 4)
                    .transition(.opacity)
            }
        }
        .onAppear {
            isEditing = false
        }
    }
    
    private func formatAmount(_ newValue: String) {
        // Only allow numbers and one decimal point
        let filtered = newValue.filter { "0123456789.".contains($0) }
        
        if filtered != newValue {
            amount = filtered
            return
        }
        
        // Handle decimal points
        let parts = filtered.split(separator: ".")
        if parts.count > 2 {
            amount = String(parts[0]) + "." + String(parts[1])
            return
        }
        
        // Limit decimal places to 2
        if parts.count == 2 && parts[1].count > 2 {
            amount = String(parts[0]) + "." + String(parts[1].prefix(2))
            return
        }
        
        amount = filtered
    }
}

struct PercentageInputField: View {
    @Binding var percentage: String
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                TextField("0.00", text: $percentage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .onChange(of: percentage) { _, newValue in
                        formatPercentage(newValue)
                    }
                    .onTapGesture {
                        isEditing = true
                    }
                
                Text("%")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.aurumGold)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isEditing ? Color.aurumGold : Color.aurumGray.opacity(0.3), lineWidth: 2)
                    )
            )
            
            // Preview of formatted percentage
            if let doubleValue = Double(percentage) {
                Text("\(String(format: "%.2f", doubleValue))%")
                    .font(.subheadline)
                    .foregroundColor(.aurumGold)
                    .padding(.horizontal, 4)
                    .transition(.opacity)
            }
        }
        .onAppear {
            isEditing = false
        }
    }
    
    private func formatPercentage(_ newValue: String) {
        // Only allow numbers and one decimal point
        let filtered = newValue.filter { "0123456789.".contains($0) }
        
        if filtered != newValue {
            percentage = filtered
            return
        }
        
        // Handle decimal points
        let parts = filtered.split(separator: ".")
        if parts.count > 2 {
            percentage = String(parts[0]) + "." + String(parts[1])
            return
        }
        
        // Limit decimal places to 2
        if parts.count == 2 && parts[1].count > 2 {
            percentage = String(parts[0]) + "." + String(parts[1].prefix(2))
            return
        }
        
        // Ensure value is between 0 and 100
        if let value = Double(filtered) {
            if value > 100 {
                percentage = "100"
                return
            }
        }
        
        percentage = filtered
    }
} 