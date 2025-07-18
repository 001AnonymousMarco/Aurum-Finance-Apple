import SwiftUI

// MARK: - Enhanced Debt Management Views

struct DebtOverviewCard: View {
    @EnvironmentObject var financeStore: FinanceStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Debt Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(financeStore.liabilities.count) active debts")
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "creditcard.trianglebadge.exclamationmark")
                        .font(.title2)
                        .foregroundColor(.aurumOrange)
                }
            }
            
            // Total debt and payments
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Debt")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(formatCurrency(financeStore.liabilities.reduce(0) { $0 + $1.balance }))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.aurumRed)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Monthly Payments")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(formatCurrency(financeStore.liabilities.reduce(0) { $0 + $1.minimumPayment }))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.aurumText)
                }
            }
            
            // Debt-to-income ratio
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Debt-to-Income Ratio")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    let ratio = financeStore.debtToIncomeRatio
                    Text("\(Int(ratio * 100))%")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(ratio > 0.36 ? .aurumRed : (ratio > 0.28 ? .aurumWarning : .aurumGreen))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("High Priority Debts")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text("\(financeStore.highPriorityDebts.count)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(financeStore.highPriorityDebts.isEmpty ? .aurumGreen : .aurumRed)
                }
            }
            
            // Debt advice
            if financeStore.debtToIncomeRatio > 0.36 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.aurumRed)
                    
                    Text("High debt-to-income ratio. Consider debt consolidation or extra payments.")
                        .font(.caption)
                        .foregroundColor(.aurumRed)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color.aurumCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.aurumBorder, lineWidth: 1)
        )
    }
}

struct EnhancedLiabilityCard: View {
    let liability: Liability
    @State private var showingPayoffCalculator = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Type and priority indicator
                HStack(spacing: 8) {
                    Image(systemName: liability.type.icon)
                        .font(.title3)
                        .foregroundColor(Color(hex: liability.type.color))
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(liability.name)
                            .font(.headline)
                            .foregroundColor(.aurumText)
                        
                        Text(liability.type.rawValue)
                            .font(.caption)
                            .foregroundColor(.aurumGray)
                    }
                }
                
                Spacer()
                
                // Priority badge
                VStack {
                    Text(liability.priority.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: liability.priority.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: liability.priority.color).opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Balance and interest rate
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(formatCurrency(liability.balance))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Interest Rate")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text("\(String(format: "%.2f", liability.interestRate))%")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(liability.isHighInterest ? Color(hex: "#FF3B30") : .aurumText)
                }
            }
            
            // Minimum payment and payoff strategy
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Minimum Payment: \(formatCurrency(liability.minimumPayment))")
                        .font(.subheadline)
                        .foregroundColor(.aurumText)
                    
                    Spacer()
                }
                
                if let strategy = liability.minimumPayoffStrategy() {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Payoff Time")
                                .font(.caption)
                                .foregroundColor(.aurumGray)
                            
                            Text("\(strategy.monthsToPayoff) months")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.aurumText)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Total Interest")
                                .font(.caption)
                                .foregroundColor(.aurumGray)
                            
                            Text(formatCurrency(strategy.totalInterestPaid))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "#FF9500"))
                        }
                    }
                    .padding(.top, 4)
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { showingPayoffCalculator = true }) {
                    HStack {
                        Image(systemName: "calculator")
                        Text("Payoff Calculator")
                    }
                    .font(.subheadline)
                    .foregroundColor(.aurumBlue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.aurumBlue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                if liability.isHighInterest {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.aurumRed)
                        Text("High Interest")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.aurumRed)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.aurumCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.aurumBorder, lineWidth: 1)
        )
        .sheet(isPresented: $showingPayoffCalculator) {
            PayoffCalculatorView(liability: liability)
        }
    }
}

struct PayoffCalculatorView: View {
    let liability: Liability
    @Environment(\.dismiss) private var dismiss
    
    @State private var extraPayment: String = ""
    @State private var customPayment: String = ""
    @State private var calculationMode: CalculationMode = .extraPayment
    
    enum CalculationMode: String, CaseIterable {
        case extraPayment = "Extra Payment"
        case customPayment = "Custom Payment"
    }
    
    private var debtInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Debt Information")
                .font(.headline)
                .foregroundColor(.aurumText)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Balance")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    Text(formatCurrency(liability.balance))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Interest Rate")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    Text("\(String(format: "%.2f", liability.interestRate))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumText)
                }
            }
            
            Text("Minimum Payment: \(formatCurrency(liability.minimumPayment))")
                .font(.subheadline)
                .foregroundColor(.aurumGray)
        }
        .padding(16)
        .background(Color.aurumCard)
        .cornerRadius(12)
    }
    
    private var paymentStrategySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Strategy")
                .font(.headline)
                .foregroundColor(.aurumText)
            
            Picker("Mode", selection: $calculationMode) {
                ForEach(CalculationMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            VStack(alignment: .leading, spacing: 8) {
                if calculationMode == .extraPayment {
                    Text("Extra Payment Amount")
                        .font(.subheadline)
                        .foregroundColor(.aurumText)
                    AmountInputField(amount: $extraPayment)
                } else {
                    Text("Total Monthly Payment")
                        .font(.subheadline)
                        .foregroundColor(.aurumText)
                    AmountInputField(amount: $customPayment)
                }
            }
        }
        .padding(16)
        .background(Color.aurumCard)
        .cornerRadius(12)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    debtInfoSection
                    paymentStrategySection
                    
                    // Results
                    if let strategy = calculateStrategy() {
                        PayoffResultsView(
                            strategy: strategy,
                            originalStrategy: liability.minimumPayoffStrategy()
                        )
                        .cardStyle()
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
            .background(Color.aurumDark)
            .navigationTitle("Payoff Calculator")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.aurumGray)
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 600)
    }
    
    private func calculateStrategy() -> DebtPayoffStrategy? {
        let payment: Double
        
        if calculationMode == .extraPayment {
            guard let extra = Double(extraPayment), extra >= 0 else { return nil }
            payment = liability.minimumPayment + extra
        } else {
            guard let custom = Double(customPayment), custom >= liability.minimumPayment else { return nil }
            payment = custom
        }
        
        return DebtPayoffStrategy.calculate(
            principal: liability.balance,
            interestRate: liability.interestRate,
            monthlyPayment: payment
        )
    }
}

struct PayoffResultsView: View {
    let strategy: DebtPayoffStrategy
    let originalStrategy: DebtPayoffStrategy?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payoff Results")
                .font(.headline)
                .foregroundColor(.aurumText)
            
            // New strategy results
            VStack(spacing: 12) {
                ResultRow(
                    title: "Payoff Date",
                    value: formatDate(strategy.payoffDate),
                    color: "#FFFFFF"
                )
                
                ResultRow(
                    title: "Time to Payoff",
                    value: "\(strategy.monthsToPayoff) months",
                    color: "#FFFFFF"
                )
                
                ResultRow(
                    title: "Total Interest Paid",
                    value: formatCurrency(strategy.totalInterestPaid),
                    color: "#FF9500"
                )
                
                ResultRow(
                    title: "Total Amount Paid",
                    value: formatCurrency(strategy.totalAmountPaid),
                    color: "#FFFFFF"
                )
            }
            
            // Comparison with minimum payments
            if let original = originalStrategy {
                Divider()
                    .background(Color.aurumBorder)
                
                Text("Savings vs. Minimum Payments")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.aurumText)
                
                let timeSaved = original.monthsToPayoff - strategy.monthsToPayoff
                let interestSaved = original.totalInterestPaid - strategy.totalInterestPaid
                
                VStack(spacing: 8) {
                    if timeSaved > 0 {
                        HStack {
                            Text("Time Saved:")
                                .foregroundColor(.aurumGray)
                            Spacer()
                            Text("\(timeSaved) months")
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "#34C759"))
                        }
                    }
                    
                    if interestSaved > 0 {
                        HStack {
                            Text("Interest Saved:")
                                .foregroundColor(.aurumGray)
                            Spacer()
                            Text(formatCurrency(interestSaved))
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "#34C759"))
                        }
                    }
                }
            }
        }
        .padding(16)
    }
}

struct ResultRow: View {
    let title: String
    let value: String
    let color: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.aurumGray)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: color))
        }
    }
}

struct EnhancedLiabilitiesView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var showingAddDebt = false
    @State private var showingEditDebt = false
    @State private var selectedLiability: Liability?
    @State private var showingDeleteAlert = false
    @State private var liabilityToDelete: Liability?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Debt overview
                DebtOverviewCard()
                
                // High priority debts section
                if !financeStore.highPriorityDebts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("High Priority Debts")
                                .font(.headline)
                                .foregroundColor(.aurumText)
                            
                            Spacer()
                            
                            Image(systemName: "flame.fill")
                                .foregroundColor(.aurumRed)
                        }
                        
                        ForEach(financeStore.highPriorityDebts) { liability in
                            EnhancedLiabilityCard(liability: liability)
                                .contextMenu {
                                    Button {
                                        selectedLiability = liability
                                        showingEditDebt = true
                                    } label: {
                                        Label("Edit Debt", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        liabilityToDelete = liability
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                
                // All debts section
                VStack(alignment: .leading, spacing: 12) {
                    Text("All Debts")
                        .font(.headline)
                        .foregroundColor(.aurumText)
                    
                    ForEach(financeStore.liabilities.sorted { $0.interestRate > $1.interestRate }) { liability in
                        EnhancedLiabilityCard(liability: liability)
                            .contextMenu {
                                Button {
                                    selectedLiability = liability
                                    showingEditDebt = true
                                } label: {
                                    Label("Edit Debt", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    liabilityToDelete = liability
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.aurumDark)
        .navigationTitle("Debt Management")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddDebt = true }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }
            }
        }
        .sheet(isPresented: $showingAddDebt) {
            NavigationView {
                AddLiabilityView()
                    .environmentObject(financeStore)
            }
        }
        .sheet(isPresented: $showingEditDebt) {
            NavigationView {
                AddLiabilityView(liability: selectedLiability)
                    .environmentObject(financeStore)
            }
        }
        .alert("Delete Debt", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let liability = liabilityToDelete {
                    financeStore.deleteLiability(liability)
                }
            }
        } message: {
            if let liability = liabilityToDelete {
                Text("Are you sure you want to delete \"\(liability.name)\"? This action cannot be undone.")
            }
        }
    }
}

// Helper functions
private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
} 
