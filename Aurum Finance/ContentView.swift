//
//  ContentView.swift
//  Aurum Finance
//
//  Created by Marc Alleyne on 7/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var financeStore = FinanceStore()
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var selectedTab = 0
    @State private var showingAddSheet = false
    @State private var addSheetType: AddSheetType = .income
    @State private var showingProfileMenu = false

    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .navigationBarTrailing
        #else
        return .primaryAction
        #endif
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.aurumDark)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Dashboard")
            }
            .tag(0)
            
            NavigationStack {
                TransactionsView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.aurumDark)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Transactions")
            }
            .tag(1)
            
            NavigationStack {
                SavingsGoalsView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.aurumDark)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "target")
                Text("Goals")
            }
            .tag(2)
            
            NavigationStack {
                BudgetListView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.aurumDark)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "chart.pie")
                Text("Budgets")
            }
            .tag(3)
            
            NavigationStack {
                RecurringTransactionsListView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.aurumDark)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "arrow.clockwise.circle")
                Text("Recurring")
            }
            .tag(4)
            
            NavigationStack {
                EnhancedLiabilitiesView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.aurumDark)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "creditcard")
                Text("Debts")
            }
            .tag(5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accentColor(.aurumGold)
        .background(Color.aurumDark)
        .toolbar {
            ToolbarItem(placement: toolbarPlacement) {
                profileButton
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationView {
                Group {
                    switch addSheetType {
                    case .income:
                        AddIncomeView()
                    case .expense:
                        AddExpenseView()
                    case .savingsGoal:
                        AddSavingsGoalView()
                    case .liability:
                        AddLiabilityView()
                    }
                }
                .environmentObject(financeStore)
            }
            #if os(macOS)
            .frame(minWidth: 500, minHeight: 700)
            #endif
        }
    }
    
    private var profileButton: some View {
        Menu {
            if let profile = financeStore.userProfile {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(profile.firstName) \(profile.lastName)")
                        .font(.headline)
                        .foregroundColor(.aurumText)
                    
                    Text(profile.email)
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                    
                    Text("Joined \(profile.joinDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                }
                .padding(.vertical, 4)
            } else if let email = firebaseManager.currentUser?.email {
                Text(email)
                    .foregroundColor(.aurumGray)
            }
            
            Divider()
            
            Button(role: .destructive, action: signOut) {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.aurumGold)
                .font(.title2)
        }
    }
    
    private func signOut() {
        do {
            try firebaseManager.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct FloatingAddButton: View {
    @Binding var showingSheet: Bool
    @Binding var sheetType: AddSheetType
    @State private var showingOptions = false
    
    var body: some View {
        VStack(spacing: 12) {
            if showingOptions {
                VStack(spacing: 8) {
                    FloatingActionButton(
                        icon: "plus.circle.fill",
                        title: "Income",
                        color: .aurumGreen
                    ) {
                        sheetType = .income
                        showingSheet = true
                        showingOptions = false
                    }
                    
                    FloatingActionButton(
                        icon: "minus.circle.fill",
                        title: "Expense",
                        color: .aurumRed
                    ) {
                        sheetType = .expense
                        showingSheet = true
                        showingOptions = false
                    }
                    
                    FloatingActionButton(
                        icon: "target",
                        title: "Goal",
                        color: .aurumBlue
                    ) {
                        sheetType = .savingsGoal
                        showingSheet = true
                        showingOptions = false
                    }
                    
                    FloatingActionButton(
                        icon: "creditcard.fill",
                        title: "Liability",
                        color: .aurumOrange
                    ) {
                        sheetType = .liability
                        showingSheet = true
                        showingOptions = false
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Button(action: {
                withAnimation(.aurumSpring) {
                    showingOptions.toggle()
                }
            }) {
                Image(systemName: showingOptions ? "xmark" : "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(width: 56, height: 56)
                    .background(Color.aurumGold)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    .rotationEffect(.degrees(showingOptions ? 45 : 0))
            }
        }
    }
}

struct FloatingActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.aurumCard)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .frame(width: 140)
    }
}

// Placeholder views for other tabs
struct TransactionsView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var showingFilterSheet = false
    @State private var showingAddSheet = false
    @State private var addSheetType: AddSheetType = .expense
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Header
            TransactionFilterHeader(
                searchText: $financeStore.searchText,
                showingFilterSheet: $showingFilterSheet
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.aurumCard)
            
            // Active Filters Display
            if hasActiveFilters {
                ActiveFiltersView()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.aurumDark)
            }
            
            // Transactions List
            TransactionsList(
                transactions: financeStore.filteredTransactions,
                showingAddSheet: $showingAddSheet,
                addSheetType: $addSheetType
            )
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.aurumDark)
        .navigationTitle("Transactions")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            TransactionFiltersSheet()
                .environmentObject(financeStore)
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationView {
                Group {
                    switch addSheetType {
                    case .income:
                        AddIncomeView()
                    case .expense:
                        AddExpenseView()
                    case .savingsGoal:
                        AddSavingsGoalView()
                    case .liability:
                        AddLiabilityView()
                    }
                }
                .environmentObject(financeStore)
            }
        }
    }
    
    private var hasActiveFilters: Bool {
        financeStore.selectedDateRange != .thisMonth ||
        financeStore.selectedTransactionType != nil ||
        financeStore.selectedExpenseCategory != nil
    }
}

struct TransactionFilterHeader: View {
    @Binding var searchText: String
    @Binding var showingFilterSheet: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.aurumGray)
                    .font(.system(size: 16))
                
                TextField("Search transactions...", text: $searchText)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .accentColor(.aurumGold)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.aurumGray)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.aurumDark)
            .cornerRadius(10)
            
            // Filter Button
            Button(action: { showingFilterSheet = true }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16))
                    .foregroundColor(.aurumGold)
                    .padding(12)
                    .cornerRadius(10)
            }
        }
    }
}

struct ActiveFiltersView: View {
    @EnvironmentObject var financeStore: FinanceStore
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Text("Filters:")
                    .font(.caption)
                    .foregroundColor(.aurumGray)
                
                if financeStore.selectedDateRange != .thisMonth {
                    RemovableFilterChip(
                        title: financeStore.selectedDateRange.displayName,
                        onRemove: { financeStore.selectedDateRange = .thisMonth }
                    )
                }
                
                if let transactionType = financeStore.selectedTransactionType {
                    RemovableFilterChip(
                        title: transactionType.rawValue,
                        onRemove: { financeStore.selectedTransactionType = nil }
                    )
                }
                
                if let category = financeStore.selectedExpenseCategory {
                    RemovableFilterChip(
                        title: category.rawValue,
                        onRemove: { financeStore.selectedExpenseCategory = nil }
                    )
                }
                
                Button("Clear All") {
                    financeStore.selectedDateRange = .thisMonth
                    financeStore.selectedTransactionType = nil
                    financeStore.selectedExpenseCategory = nil
                }
                .font(.caption)
                .foregroundColor(.aurumGold)
                .padding(.leading, 8)
            }
            .padding(.horizontal, 16)
        }
    }
}

struct RemovableFilterChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10))
                    .foregroundColor(.aurumGray)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.aurumCard)
        .cornerRadius(12)
    }
}

struct TransactionsList: View {
    let transactions: [AnyTransaction]
    @EnvironmentObject var financeStore: FinanceStore
    @Binding var showingAddSheet: Bool
    @Binding var addSheetType: AddSheetType
    
    var body: some View {
        if transactions.isEmpty {
            if financeStore.recentTransactions.isEmpty {
                // Main empty state - no transactions at all
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.aurumGray)
                    
                    Text("No transactions yet")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Add your first transaction to start tracking your finances")
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button(action: { showingAddSheet = true; addSheetType = .expense }) {
                        Text("Add First Transaction")
                            .font(.headline)
                    }
                    .goldButton()
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                // Filter empty state - transactions exist but none match filters
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.aurumGray)
                    
                    Text("No transactions found")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Try adjusting your search or filters")
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(groupedTransactions.keys.sorted(by: >)), id: \.self) { date in
                        TransactionDateSection(
                            date: date,
                            transactions: groupedTransactions[date] ?? []
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 100) // Extra padding for tab bar
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var groupedTransactions: [Date: [AnyTransaction]] {
        let calendar = Calendar.current
        return Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
    }
}

struct TransactionDateSection: View {
    let date: Date
    let transactions: [AnyTransaction]
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private var totalAmount: Double {
        transactions.reduce(0) { result, transaction in
            switch transaction.type {
            case .income:
                return result + transaction.amount
            case .expense:
                return result - transaction.amount
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Date Header
            HStack {
                Text(dateFormatter.string(from: date))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(totalAmount.currencyFormatted)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(totalAmount >= 0 ? .aurumGreen : .aurumRed)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.aurumCard)
            .cornerRadius(8)
            .padding(.vertical, 8)
            
            // Transactions for this date
            VStack(spacing: 0) {
                ForEach(transactions.sorted { $0.date > $1.date }) { transaction in
                    EnhancedTransactionRow(transaction: transaction)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.aurumCard)
                    
                    if transaction.id != transactions.last?.id {
                        Divider()
                            .background(Color.aurumGray.opacity(0.3))
                            .padding(.leading, 72)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.aurumCard)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EnhancedTransactionRow: View {
    let transaction: AnyTransaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(Color(hex: transaction.categoryColor))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: transaction.categoryIcon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description ?? "No description")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    Text(transaction.type.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(hex: transaction.type.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: transaction.type.color).opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(timeFormatter.string(from: transaction.date))
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text((transaction.type == .income ? "+" : "-") + transaction.amount.compactCurrencyFormatted)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.type == .income ? .aurumGreen : .aurumRed)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct TransactionFiltersSheet: View {
    @EnvironmentObject var financeStore: FinanceStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Date Range Filter
                VStack(alignment: .leading, spacing: 16) {
                    Text("Date Range")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(DateRange.allCases, id: \.id) { range in
                            FilterOptionButton(
                                title: range.displayName,
                                isSelected: financeStore.selectedDateRange.id == range.id,
                                action: { financeStore.selectedDateRange = range }
                            )
                        }
                    }
                }
                
                // Transaction Type Filter
                VStack(alignment: .leading, spacing: 16) {
                    Text("Transaction Type")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        FilterOptionButton(
                            title: "All",
                            isSelected: financeStore.selectedTransactionType == nil,
                            action: { financeStore.selectedTransactionType = nil }
                        )
                        
                        ForEach(TransactionType.allCases) { type in
                            FilterOptionButton(
                                title: type.rawValue,
                                isSelected: financeStore.selectedTransactionType == type,
                                action: { financeStore.selectedTransactionType = type }
                            )
                        }
                        
                        Spacer()
                    }
                }
                
                // Expense Category Filter (only if expense type is selected)
                if financeStore.selectedTransactionType == .expense || financeStore.selectedTransactionType == nil {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Expense Category")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            FilterOptionButton(
                                title: "All Categories",
                                isSelected: financeStore.selectedExpenseCategory == nil,
                                action: { financeStore.selectedExpenseCategory = nil }
                            )
                            
                            ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                FilterOptionButton(
                                    title: category.rawValue,
                                    isSelected: financeStore.selectedExpenseCategory == category,
                                    action: { financeStore.selectedExpenseCategory = category }
                                )
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.aurumDark)
            .navigationTitle("Filters")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        financeStore.selectedDateRange = .thisMonth
                        financeStore.selectedTransactionType = nil
                        financeStore.selectedExpenseCategory = nil
                    }
                    .foregroundColor(.aurumGold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.aurumGold)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

struct FilterOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.aurumGold : Color.aurumCard)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.aurumGold : Color.aurumGray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct TransactionGroup {
    let date: Date
    let transactions: [AnyTransaction]
    
    var totalAmount: Double {
        transactions.reduce(0) { sum, transaction in
            sum + (transaction.type == .income ? transaction.amount : -transaction.amount)
        }
    }
}

struct TransactionDateGroup: View {
    let group: TransactionGroup
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(group.date.shortFormatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(group.totalAmount.currencyFormatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(group.totalAmount >= 0 ? .aurumGreen : .aurumRed)
            }
            .padding(.vertical, 12)
            
            VStack(spacing: 0) {
                ForEach(group.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                    
                    if transaction.id != group.transactions.last?.id {
                        Divider()
                            .background(Color.aurumGray.opacity(0.3))
                    }
                }
            }
            .cardStyle()
            .padding(.bottom, 16)
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(backgroundView)
        }
        .buttonStyle(.plain)
        #if os(macOS)
        .onHover { hovering in
            isHovered = hovering
        }
        #endif
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.aurumGold)
        } else {
            Color.clear
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.aurumGray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct SavingsGoalsView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var selectedCategory: SavingsGoal.GoalCategory?
    @State private var showingAddGoal = false
    
    private var filteredGoals: [SavingsGoal] {
        if let category = selectedCategory {
            return financeStore.savingsGoals.filter { $0.category == category }
        }
        return financeStore.savingsGoals
    }
    
    private var totalProgress: Double {
        let totalCurrent = financeStore.savingsGoals.reduce(0) { $0 + $1.currentAmount }
        let totalTarget = financeStore.savingsGoals.reduce(0) { $0 + $1.targetAmount }
        return totalTarget > 0 ? totalCurrent / totalTarget : 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    if financeStore.savingsGoals.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "target")
                                .font(.system(size: 48))
                                .foregroundColor(.aurumGray)
                            
                            Text("No savings goals yet")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Add your first savings goal to start tracking your progress")
                                .font(.subheadline)
                                .foregroundColor(.aurumGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button(action: { showingAddGoal = true }) {
                                Text("Add Goal")
                                    .font(.headline)
                            }
                            .goldButton()
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, geometry.size.height * 0.2)
                    } else {
                        VStack(spacing: 24) {
                            // Overall Progress Card
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Overall Progress")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(totalProgress * 100))%")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.aurumGold)
                                }
                                
                                ProgressView(value: totalProgress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .aurumGold))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                            }
                            .padding(20)
                            .cardStyle()
                            .frame(maxWidth: min(800, geometry.size.width * 0.9))
                            
                            // Category Filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    FilterPill(
                                        title: "All",
                                        isSelected: selectedCategory == nil
                                    ) {
                                        selectedCategory = nil
                                    }
                                    
                                    ForEach(SavingsGoal.GoalCategory.allCases, id: \.self) { category in
                                        FilterPill(
                                            title: category.rawValue,
                                            isSelected: selectedCategory == category
                                        ) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                                .padding(.horizontal, geometry.size.width * 0.05)
                            }
                            
                            // Goals List
                            LazyVStack(spacing: 16) {
                                ForEach(filteredGoals) { goal in
                                    SavingsGoalCard(goal: goal)
                                }
                            }
                            .padding(.horizontal, geometry.size.width * 0.05)
                            .padding(.bottom, 24)
                        }
                        .padding(.top, 16)
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Savings Goals")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .sheet(isPresented: $showingAddGoal) {
            NavigationView {
                AddSavingsGoalView()
                    .environmentObject(financeStore)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddGoal = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }
            }
        }
    }
}

struct LiabilitiesView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var selectedType: Liability.LiabilityType?
    @State private var showingAddLiability = false
    
    private var filteredLiabilities: [Liability] {
        if let type = selectedType {
            return financeStore.liabilities.filter { $0.type == type }
        }
        return financeStore.liabilities
    }
    
    private var totalBalance: Double {
        financeStore.liabilities.reduce(0) { $0 + $1.balance }
    }
    
    private var totalMinimumPayment: Double {
        financeStore.liabilities.reduce(0) { $0 + $1.minimumPayment }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    if financeStore.liabilities.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.aurumGray)
                            
                            Text("No liabilities yet")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Add your credit cards, loans, and other debts to track them")
                                .font(.subheadline)
                                .foregroundColor(.aurumGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button(action: { showingAddLiability = true }) {
                                Text("Add Liability")
                                    .font(.headline)
                            }
                            .goldButton()
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, geometry.size.height * 0.2)
                    } else {
                        VStack(spacing: 24) {
                            // Summary Cards
                            HStack(spacing: 16) {
                                // Total Balance
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total Balance")
                                        .font(.subheadline)
                                        .foregroundColor(.aurumGray)
                                    
                                    Text(totalBalance.currencyFormatted)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                .cardStyle()
                                
                                // Monthly Payment
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Min. Payment")
                                        .font(.subheadline)
                                        .foregroundColor(.aurumGray)
                                    
                                    Text(totalMinimumPayment.currencyFormatted)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.aurumRed)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                .cardStyle()
                            }
                            .frame(maxWidth: min(800, geometry.size.width * 0.9))
                            .padding(.horizontal, geometry.size.width * 0.05)
                            
                            // Type Filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    FilterPill(
                                        title: "All",
                                        isSelected: selectedType == nil
                                    ) {
                                        selectedType = nil
                                    }
                                    
                                    ForEach(Liability.LiabilityType.allCases, id: \.self) { type in
                                        FilterPill(
                                            title: type.rawValue,
                                            isSelected: selectedType == type
                                        ) {
                                            selectedType = type
                                        }
                                    }
                                }
                                .padding(.horizontal, geometry.size.width * 0.05)
                            }
                            
                            // Liabilities List
                            VStack(spacing: 16) {
                                ForEach(filteredLiabilities) { liability in
                                    LiabilityCard(liability: liability)
                                        .frame(maxWidth: min(800, geometry.size.width * 0.9))
                                }
                            }
                            .padding(.horizontal, geometry.size.width * 0.05)
                            .padding(.bottom, 24)
                        }
                        .padding(.top, 16)
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Liabilities")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .sheet(isPresented: $showingAddLiability) {
            NavigationView {
                AddLiabilityView()
                    .environmentObject(financeStore)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddLiability = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }
            }
        }
    }
}

struct LiabilityCard: View {
    let liability: Liability
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(liability.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(liability.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                }
                
                Spacer()
                
                Image(systemName: liability.type.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: liability.type.color))
            }
            
            Divider()
                .background(Color.aurumGray.opacity(0.3))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(liability.balance.currencyFormatted)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("APR")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text("\(String(format: "%.1f", liability.interestRate))%")
                        .font(.headline)
                        .foregroundColor(.aurumOrange)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Due")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                    
                    Text(liability.dueDate.shortFormatted)
                        .font(.headline)
                        .foregroundColor(.aurumRed)
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
}

#Preview {
    ContentView()
}
