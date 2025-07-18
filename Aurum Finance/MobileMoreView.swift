//
//  MobileMoreView.swift
//  Aurum Finance
//
//  Created by Marc Alleyne on 7/7/25.
//

import SwiftUI

struct MobileMoreView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var selectedSection: MoreSection = .recurring
    
    var body: some View {
        VStack(spacing: 0) {
            // Section Picker
            mobileSectionPicker
            
            // Content
            switch selectedSection {
            case .recurring:
                MobileRecurringSection()
            case .debts:
                MobileDebtsSection()
            }
        }
        .background(Color.aurumDark)
    }
    
    private var mobileSectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(MoreSection.allCases, id: \.self) { section in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSection = section
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(section.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedSection == section ? .aurumGold : .aurumGray)
                        
                        Rectangle()
                            .fill(selectedSection == section ? Color.aurumGold : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.aurumDark)
    }
}

// MARK: - More Section Enum
enum MoreSection: CaseIterable {
    case recurring, debts
    
    var displayName: String {
        switch self {
        case .recurring: return "Recurring"
        case .debts: return "Debts"
        }
    }
}

// MARK: - Mobile Recurring Section
struct MobileRecurringSection: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var selectedFilter: RecurringFilter = .all
    @State private var showingAddRecurring = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            mobileRecurringHeader
            
            // Filter Pills
            mobileRecurringFilters
            
            // Content
            if financeStore.recurringTransactions.isEmpty {
                mobileRecurringEmptyState
            } else {
                mobileRecurringList
            }
        }
        .sheet(isPresented: $showingAddRecurring) {
            NavigationStack {
                AddRecurringTransactionView()
                    .environmentObject(financeStore)
                    .navigationTitle("Add Recurring")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingAddRecurring = false
                            }
                        }
                    }
            }
        }
    }
    
    private var mobileRecurringHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Recurring Transactions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.aurumText)
                
                Text("\(financeStore.recurringTransactions.count) active")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
            }
            
            Spacer()
            
            Button(action: {
                showingAddRecurring = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.aurumGold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.aurumDark)
    }
    
    private var mobileRecurringFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(RecurringFilter.allCases, id: \.self) { filter in
                    MobileFilterPill(
                        title: filter.displayName,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Color.aurumDark)
    }
    
    private var mobileRecurringList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredRecurringTransactions, id: \.id) { transaction in
                    MobileRecurringCard(transaction: transaction)
                        .contextMenu {
                            Button("Edit") {
                                // Edit recurring transaction
                            }
                            
                            Button("Delete", role: .destructive) {
                                // Delete recurring transaction
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100) // Space for floating button
        }
    }
    
    private var mobileRecurringEmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.clockwise.circle")
                .font(.system(size: 60))
                .foregroundColor(.aurumGray)
            
            VStack(spacing: 8) {
                Text("No Recurring Transactions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.aurumText)
                
                Text("Set up recurring transactions to automate your finances")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddRecurring = true
            }) {
                Text("Add Recurring")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.aurumGold)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.aurumDark)
    }
    
    private var filteredRecurringTransactions: [RecurringTransaction] {
        if selectedFilter == .all {
            return financeStore.recurringTransactions
        } else {
            return financeStore.recurringTransactions.filter { $0.frequency == selectedFilter }
        }
    }
}

// MARK: - Mobile Recurring Card
struct MobileRecurringCard: View {
    let transaction: RecurringTransaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(transaction.isIncome ? Color.aurumGreen : Color.aurumRed)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: transaction.isIncome ? "arrow.up" : "arrow.down")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                )
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.aurumText)
                    .lineLimit(1)
                
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.aurumGray)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.aurumGray)
                        .font(.caption2)
                    
                    Text(transaction.frequency.displayName)
                        .font(.caption2)
                        .foregroundColor(.aurumGray)
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.amount.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.isIncome ? .aurumGreen : .aurumRed)
                
                Text(transaction.isIncome ? "Income" : "Expense")
                    .font(.caption2)
                    .foregroundColor(.aurumGray)
            }
        }
        .padding(16)
        .background(Color.aurumCard)
        .cornerRadius(12)
    }
}

// MARK: - Mobile Debts Section
struct MobileDebtsSection: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var showingAddDebt = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            mobileDebtsHeader
            
            // Content
            if financeStore.liabilities.isEmpty {
                mobileDebtsEmptyState
            } else {
                mobileDebtsList
            }
        }
        .sheet(isPresented: $showingAddDebt) {
            NavigationStack {
                AddLiabilityView()
                    .environmentObject(financeStore)
                    .navigationTitle("Add Debt")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingAddDebt = false
                            }
                        }
                    }
            }
        }
    }
    
    private var mobileDebtsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Debts & Liabilities")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.aurumText)
                
                Text("\(financeStore.liabilities.count) active debts")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
            }
            
            Spacer()
            
            Button(action: {
                showingAddDebt = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.aurumGold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.aurumDark)
    }
    
    private var mobileDebtsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(financeStore.liabilities, id: \.id) { liability in
                    MobileDebtCard(liability: liability)
                        .contextMenu {
                            Button("Edit") {
                                // Edit debt
                            }
                            
                            Button("Delete", role: .destructive) {
                                // Delete debt
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100) // Space for floating button
        }
    }
    
    private var mobileDebtsEmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.aurumGray)
            
            VStack(spacing: 8) {
                Text("No Debts")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.aurumText)
                
                Text("Track your debts and liabilities to manage your financial health")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddDebt = true
            }) {
                Text("Add Debt")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.aurumGold)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.aurumDark)
    }
}

// MARK: - Mobile Debt Card
struct MobileDebtCard: View {
    let liability: Liability
    
    private var monthlyPayment: Double {
        // Calculate monthly payment based on liability details
        // This would need to be implemented based on your calculation logic
        return liability.balance * 0.05 // Placeholder: 5% of total
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                // Debt Icon
                Circle()
                    .fill(Color.aurumRed)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(liability.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumText)
                    
                    Text(liability.type.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                }
                
                Spacer()
                
                // Interest Rate
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(liability.interestRate, specifier: "%.1f")%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumRed)
                    
                    Text("APR")
                        .font(.caption2)
                        .foregroundColor(.aurumGray)
                }
            }
            
            // Amount Details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(liability.balance.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumText)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Monthly")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(monthlyPayment.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumRed)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Due Date")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(liability.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumGold)
                }
            }
        }
        .padding(20)
        .background(Color.aurumCard)
        .cornerRadius(16)
    }
} 