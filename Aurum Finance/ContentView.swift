//
//  ContentView.swift
//  Aurum Finance
//
//  Created by Marc Alleyne on 7/7/25.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject private var financeStore = FinanceStore()
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var selectedTab = 0
    @State private var showingAddSheet = false
    @State private var addSheetType: AddSheetType = .income
    @State private var showingProfileMenu = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.aurumDark)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            profileButton
                        }
                    }
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
                LiabilitiesView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.aurumDark)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "minus.circle")
                Text("Liabilities")
            }
            .tag(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accentColor(.aurumGold)
        .background(Color.aurumDark)
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
            if let email = firebaseManager.currentUser?.email {
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
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
    @State private var selectedFilter: TransactionFilter = .all
    @State private var searchText: String = ""
    @State private var showingAddSheet = false
    @State private var addSheetType: AddSheetType = .income
    
    enum TransactionFilter {
        case all, income, expenses
    }
    
    var filteredTransactions: [AnyTransaction] {
        var transactions = financeStore.recentTransactions
        
        // Apply type filter
        if selectedFilter != .all {
            transactions = transactions.filter { transaction in
                switch selectedFilter {
                case .income: return transaction.type == .income
                case .expenses: return transaction.type == .expense
                case .all: return true
                }
            }
        }
        
        // Apply search filter if text is not empty
        if !searchText.isEmpty {
            transactions = transactions.filter { transaction in
                let description = transaction.description?.lowercased() ?? ""
                let amount = transaction.amount.currencyFormatted.lowercased()
                return description.contains(searchText.lowercased()) ||
                       amount.contains(searchText.lowercased())
            }
        }
        
        return transactions
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter
            VStack(spacing: 16) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.aurumGray)
                    
                    TextField("Search transactions...", text: $searchText)
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.aurumGray)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                
                // Filter Pills
                HStack(spacing: 12) {
                    FilterPill(
                        title: "Income",
                        isSelected: selectedFilter == .income
                    ) {
                        selectedFilter = .income
                    }
                    
                    FilterPill(
                        title: "Expenses",
                        isSelected: selectedFilter == .expenses
                    ) {
                        selectedFilter = .expenses
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 16)
            .background(Color.aurumDark)
            
            // Transactions List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color.black.opacity(0.3))
        }
        .background(Color.aurumDark)
        .navigationTitle("Transactions")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { 
                    addSheetType = .expense
                    showingAddSheet = true 
                }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }
            }
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
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(backgroundColor)
                )
        }
        .buttonStyle(.plain)
        #if os(macOS)
        .onHover { hovering in
            isHovered = hovering
        }
        #endif
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .aurumGold
        } else if isHovered {
            return Color.aurumGray.opacity(0.3)
        } else {
            return Color.aurumCard
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
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.aurumGold)
                                    .cornerRadius(25)
                            }
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
                            
                            // Goals Grid
                            let columns = [
                                GridItem(.adaptive(
                                    minimum: geometry.size.width > 1200 ? 300 : 250,
                                    maximum: 400
                                ), spacing: 16)
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredGoals) { goal in
                                    SavingsGoalCard(goal: goal)
                                        .frame(height: 160)
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
                    Image(systemName: "plus")
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
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.aurumGold)
                                    .cornerRadius(25)
                            }
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
                    Image(systemName: "plus")
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
