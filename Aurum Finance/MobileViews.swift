//
//  MobileViews.swift
//  Aurum Finance
//
//  Created by Marc Alleyne on 7/7/25.
//

import SwiftUI

// MARK: - Mobile Content View
struct MobileContentView: View {
    @StateObject private var financeStore = FinanceStore()
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var selectedTab = 0
    @State private var showingAddSheet = false
    @State private var addSheetType: AddSheetType = .income
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            NavigationStack {
                MobileDashboardView()
                    .navigationTitle("Dashboard")
                    .navigationBarTitleDisplayMode(.large)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Dashboard")
            }
            .tag(0)
            
            // Transactions Tab
            NavigationStack {
                MobileTransactionsView()
                    .navigationTitle("Transactions")
                    .navigationBarTitleDisplayMode(.large)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Transactions")
            }
            .tag(1)
            
            // Goals Tab
            NavigationStack {
                MobileGoalsView()
                    .navigationTitle("Goals")
                    .navigationBarTitleDisplayMode(.large)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "target")
                Text("Goals")
            }
            .tag(2)
            
            // Budgets Tab
            NavigationStack {
                MobileBudgetsView()
                    .navigationTitle("Budgets")
                    .navigationBarTitleDisplayMode(.large)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "chart.pie")
                Text("Budgets")
            }
            .tag(3)
            
            // More Tab (for additional features)
            NavigationStack {
                MobileMoreView()
                    .navigationTitle("More")
                    .navigationBarTitleDisplayMode(.large)
            }
            .environmentObject(financeStore)
            .tabItem {
                Image(systemName: "ellipsis.circle")
                Text("More")
            }
            .tag(4)
        }
        .accentColor(.aurumGold)
        .background(Color.aurumDark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                MobileProfileButton()
                    .environmentObject(financeStore)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            MobileAddSheet(sheetType: $addSheetType)
                .environmentObject(financeStore)
        }
        .overlay(
            MobileFloatingAddButton(
                showingSheet: $showingAddSheet,
                sheetType: $addSheetType
            ),
            alignment: .bottomTrailing
        )
    }
}

// MARK: - Mobile Dashboard View
struct MobileDashboardView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var currentDate = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Header Section
                mobileHeaderSection
                
                // Net Worth Card
                MobileNetWorthCard()
                
                // Quick Stats
                MobileQuickStatsView()
                
                // Recent Transactions
                MobileRecentTransactionsView()
                
                // Savings Goals
                MobileSavingsGoalsView()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100) // Space for floating button
        }
        .background(Color.aurumDark)
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }
    
    private var mobileHeaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good \(timeOfDay), \(financeStore.userProfile?.firstName ?? "")!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumText)
                    
                    Text(currentDate.formatted(date: .complete, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                }
                
                Spacer()
                
                Button(action: {
                    // Notification settings
                }) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.aurumGold)
                        .font(.title2)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<22: return "evening"
        default: return "night"
        }
    }
}

// MARK: - Mobile Net Worth Card
struct MobileNetWorthCard: View {
    @EnvironmentObject var financeStore: FinanceStore
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Net Worth")
                    .font(.headline)
                    .foregroundColor(.aurumText)
                Spacer()
                Text(financeStore.netWorth.formatted(.currency(code: "USD")))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.aurumGold)
            }
            
            // Net worth trend (simplified for mobile)
            HStack {
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.aurumGreen)
                Text("+$2,450 this month")
                    .font(.subheadline)
                    .foregroundColor(.aurumGreen)
                Spacer()
            }
        }
        .padding(20)
        .background(Color.aurumCard)
        .cornerRadius(16)
    }
}

// MARK: - Mobile Quick Stats View
struct MobileQuickStatsView: some View {
    @EnvironmentObject var financeStore: FinanceStore
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MobileStatCard(
                title: "Income",
                value: financeStore.totalIncome.formatted(.currency(code: "USD")),
                color: .aurumGreen,
                icon: "arrow.up.circle.fill"
            )
            
            MobileStatCard(
                title: "Expenses",
                value: financeStore.totalExpenses.formatted(.currency(code: "USD")),
                color: .aurumRed,
                icon: "arrow.down.circle.fill"
            )
        }
    }
}

// MARK: - Mobile Stat Card
struct MobileStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.aurumText)
            }
        }
        .padding(16)
        .background(Color.aurumCard)
        .cornerRadius(12)
    }
}

// MARK: - Mobile Recent Transactions View
struct MobileRecentTransactionsView: View {
    @EnvironmentObject var financeStore: FinanceStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .foregroundColor(.aurumText)
                Spacer()
                Button("See All") {
                    // Navigate to transactions
                }
                .font(.subheadline)
                .foregroundColor(.aurumGold)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(financeStore.recentTransactions.prefix(5)), id: \.id) { transaction in
                    MobileTransactionRow(transaction: transaction)
                }
            }
        }
    }
}

// MARK: - Mobile Transaction Row
struct MobileTransactionRow: View {
    let transaction: AnyTransaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(transaction.type == .income ? Color.aurumGreen : Color.aurumRed)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: transaction.type == .income ? "arrow.up" : "arrow.down")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                )
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description ?? "Transaction")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.aurumText)
                
                Text(transaction.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.aurumGray)
            }
            
            Spacer()
            
            // Amount
            Text(transaction.amount.formatted(.currency(code: "USD")))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.type == .income ? .aurumGreen : .aurumRed)
        }
        .padding(12)
        .background(Color.aurumCard)
        .cornerRadius(12)
    }
}

// MARK: - Mobile Savings Goals View
struct MobileSavingsGoalsView: View {
    @EnvironmentObject var financeStore: FinanceStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Savings Goals")
                    .font(.headline)
                    .foregroundColor(.aurumText)
                Spacer()
                Button("See All") {
                    // Navigate to goals
                }
                .font(.subheadline)
                .foregroundColor(.aurumGold)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(financeStore.savingsGoals.prefix(3)), id: \.id) { goal in
                    MobileGoalCard(goal: goal)
                }
            }
        }
    }
}

// MARK: - Mobile Goal Card
struct MobileGoalCard: View {
    let goal: SavingsGoal
    
    private var progressPercentage: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(goal.currentAmount / goal.targetAmount, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.aurumBlue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.aurumText)
                    
                    Text("\(Int(progressPercentage * 100))% complete")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                }
                
                Spacer()
                
                Text(goal.currentAmount.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.aurumGold)
            }
            
            // Progress bar
            ProgressView(value: progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .aurumBlue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(16)
        .background(Color.aurumCard)
        .cornerRadius(12)
    }
}

// MARK: - Mobile Profile Button
struct MobileProfileButton: View {
    @EnvironmentObject var financeStore: FinanceStore
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var body: some View {
        Menu {
            if let profile = financeStore.userProfile {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(profile.firstName) \(profile.lastName)")
                        .font(.headline)
                        .foregroundColor(.aurumText)
                    
                    Text(profile.email)
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                }
                .padding(.vertical, 4)
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

// MARK: - Mobile Add Sheet
struct MobileAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sheetType: AddSheetType
    @EnvironmentObject var financeStore: FinanceStore
    
    var body: some View {
        NavigationStack {
            Group {
                switch sheetType {
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
            .navigationTitle(addSheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var addSheetTitle: String {
        switch sheetType {
        case .income: return "Add Income"
        case .expense: return "Add Expense"
        case .savingsGoal: return "Add Goal"
        case .liability: return "Add Liability"
        }
    }
}

// MARK: - Mobile Floating Add Button
struct MobileFloatingAddButton: View {
    @Binding var showingSheet: Bool
    @Binding var sheetType: AddSheetType
    @State private var showingOptions = false
    
    var body: some View {
        VStack(spacing: 16) {
            if showingOptions {
                VStack(spacing: 12) {
                    MobileFloatingActionButton(
                        icon: "plus.circle.fill",
                        title: "Income",
                        color: .aurumGreen
                    ) {
                        sheetType = .income
                        showingSheet = true
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingOptions = false
                        }
                    }
                    
                    MobileFloatingActionButton(
                        icon: "minus.circle.fill",
                        title: "Expense",
                        color: .aurumRed
                    ) {
                        sheetType = .expense
                        showingSheet = true
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingOptions = false
                        }
                    }
                    
                    MobileFloatingActionButton(
                        icon: "target",
                        title: "Goal",
                        color: .aurumBlue
                    ) {
                        sheetType = .savingsGoal
                        showingSheet = true
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingOptions = false
                        }
                    }
                    
                    MobileFloatingActionButton(
                        icon: "creditcard.fill",
                        title: "Liability",
                        color: .aurumOrange
                    ) {
                        sheetType = .liability
                        showingSheet = true
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingOptions = false
                        }
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingOptions.toggle()
                }
            }) {
                Image(systemName: showingOptions ? "xmark" : "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.aurumGold)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Mobile Floating Action Button
struct MobileFloatingActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.aurumText)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.aurumCard)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Placeholder Views (to be implemented)
// MobileTransactionsView is now implemented in MobileTransactionsView.swift

// MobileGoalsView is now implemented in MobileGoalsView.swift

// MobileBudgetsView is now implemented in MobileBudgetsView.swift

// MobileMoreView is now implemented in MobileMoreView.swift 