//
//  MobileTransactionsView.swift
//  Aurum Finance
//
//  Created by Marc Alleyne on 7/7/25.
//

import SwiftUI

struct MobileTransactionsView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var selectedFilter: TransactionFilter = .all
    @State private var showingFilters = false
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            mobileSearchFilterBar
            
            // Transactions List
            if financeStore.allTransactions.isEmpty {
                mobileEmptyState
            } else {
                mobileTransactionsList
            }
        }
        .background(Color.aurumDark)
        .sheet(isPresented: $showingFilters) {
            MobileTransactionFiltersSheet(selectedFilter: $selectedFilter)
        }
    }
    
    private var mobileSearchFilterBar: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.aurumGray)
                
                TextField("Search transactions...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.aurumText)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.aurumGray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.aurumCard)
            .cornerRadius(12)
            
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
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
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.aurumDark)
    }
    
    private var mobileTransactionsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                    if let transactions = groupedTransactions[date] {
                        MobileTransactionDateSection(
                            date: date,
                            transactions: transactions
                        )
                    }
                }
            }
            .padding(.bottom, 100) // Space for floating button
        }
    }
    
    private var mobileEmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.circle")
                .font(.system(size: 60))
                .foregroundColor(.aurumGray)
            
            VStack(spacing: 8) {
                Text("No Transactions Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.aurumText)
                
                Text("Add your first income or expense to get started")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.aurumDark)
    }
    
    private var groupedTransactions: [Date: [AnyTransaction]] {
        let filteredTransactions = financeStore.recentTransactions.filter { transaction in
            let matchesFilter = selectedFilter == .all || 
                (selectedFilter == .income && transaction.type == .income) ||
                (selectedFilter == .expense && transaction.type == .expense)
            
            let matchesSearch = searchText.isEmpty || 
                (transaction.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                transaction.type.rawValue.localizedCaseInsensitiveContains(searchText)
            
            return matchesFilter && matchesSearch
        }
        
        return Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
}

// MARK: - Mobile Transaction Date Section
struct MobileTransactionDateSection: View {
    let date: Date
    let transactions: [AnyTransaction]
    
    var body: some View {
        VStack(spacing: 0) {
            // Date Header
            HStack {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.aurumGray)
                
                Spacer()
                
                Text(dayTotal.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.aurumText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.aurumDark)
            
            // Transactions
            VStack(spacing: 1) {
                ForEach(transactions, id: \.id) { transaction in
                    MobileTransactionRow(transaction: transaction)
                        .contextMenu {
                            Button("Edit") {
                                // Edit transaction
                            }
                            
                            Button("Delete", role: .destructive) {
                                // Delete transaction
                            }
                        }
                }
            }
        }
    }
    
    private var dayTotal: Double {
        transactions.reduce(0) { total, transaction in
            total + (transaction.type == .income ? transaction.amount : -transaction.amount)
        }
    }
}

// MARK: - Mobile Transaction Row
struct MobileTransactionRow: View {
    let transaction: AnyTransaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Circle()
                .fill(transaction.type == .income ? Color.aurumGreen : Color.aurumRed)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: categoryIcon)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                )
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description ?? "Transaction")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.aurumText)
                    .lineLimit(1)
                
                Text(transaction.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.aurumGray)
                
                Text(transaction.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.aurumGray)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.amount.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.type == .income ? .aurumGreen : .aurumRed)
                
                Text(transaction.type == .income ? "Income" : "Expense")
                    .font(.caption2)
                    .foregroundColor(.aurumGray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.aurumCard)
    }
    
    private var categoryIcon: String {
        switch transaction.type {
        case .income: return "dollarsign.circle"
        case .expense: return "arrow.down"
        }
    }
}

// MARK: - Mobile Filter Pill
struct MobileFilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .aurumGold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.aurumGold : Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(Color.aurumGold, lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Mobile Transaction Filters Sheet
struct MobileTransactionFiltersSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedFilter: TransactionFilter
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        dismiss()
                    }) {
                        HStack {
                            Text(filter.displayName)
                                .foregroundColor(.aurumText)
                            
                            Spacer()
                            
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.aurumGold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Transaction Filter Enum
enum TransactionFilter: CaseIterable {
    case all, income, expense
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .income: return "Income"
        case .expense: return "Expense"
        }
    }
} 