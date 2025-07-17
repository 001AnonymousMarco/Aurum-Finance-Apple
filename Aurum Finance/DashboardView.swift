import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @Binding var selectedTab: Int
    @State private var selectedExpenseCategory: ExpenseCategory?
    @State private var showingAddSheet = false
    @State private var addSheetType: AddSheetType = .income
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header
                    headerSection
                        .padding(.top, 16)
                    
                    // Net Worth Card
                    NetWorthCard(summary: financeStore.financialSummary)
                        .id(financeStore.financialSummary.netWorth)
                    
                    // Quick Stats
                    quickStatsSection(width: geometry.size.width)
                        .id(financeStore.financialSummary.totalIncome)
                    
                    // Charts Section
                    chartsSection(width: geometry.size.width)
                        .id(financeStore.financialSummary.totalExpenses)
                    
                    // Savings Goals
                    savingsGoalsSection(width: geometry.size.width)
                    
                    // Recent Transactions
                    recentTransactionsSection
                        .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, geometry.size.width * 0.05)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.aurumDark)
        #if os(iOS)
        .navigationBarHidden(false)
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
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.aurumGold)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Good morning!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Welcome back to Aurum Finance")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.aurumCard)
                    .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Quick Stats Section
    
    private func quickStatsSection(width: CGFloat) -> some View {
        VStack(spacing: 16) {
            Text("Quick Overview")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let columns = width > 1000 ? [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ] : [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
            
            LazyVGrid(columns: columns, spacing: 16) {
                QuickStatCard(
                    title: "Monthly Income",
                    value: financeStore.financialSummary.totalIncome,
                    icon: "arrow.up.circle.fill",
                    color: .aurumGreen
                )
                
                QuickStatCard(
                    title: "Monthly Expenses",
                    value: financeStore.financialSummary.totalExpenses,
                    icon: "arrow.down.circle.fill",
                    color: .aurumRed
                )
                
                QuickStatCard(
                    title: "Savings Rate",
                    value: financeStore.financialSummary.monthlySavings,
                    icon: "percent",
                    color: .aurumBlue,
                    isPercentage: true
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Charts Section
    
    private func chartsSection(width: CGFloat) -> some View {
        VStack(spacing: 24) {
            Text("Financial Overview")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if width > 800 {
                HStack(spacing: 24) {
                    IncomeExpenseChart(financeStore: financeStore)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                    
                    ExpenseBreakdownChart(
                        expensesByCategory: financeStore.expensesByCategory,
                        selectedCategory: $selectedExpenseCategory
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                }
            } else {
                VStack(spacing: 24) {
                    IncomeExpenseChart(financeStore: financeStore)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                    
                    ExpenseBreakdownChart(
                        expensesByCategory: financeStore.expensesByCategory,
                        selectedCategory: $selectedExpenseCategory
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Savings Goals Section
    
    private func savingsGoalsSection(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Savings Goals")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    withAnimation {
                        selectedTab = 2 // Index of Goals tab
                    }
                }
                .font(.subheadline)
                .foregroundColor(.aurumGold)
            }
            
            let columns = [
                GridItem(.adaptive(
                    minimum: width > 1200 ? 300 : 250,
                    maximum: width * 0.3
                ), spacing: 16)
            ]
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(financeStore.savingsGoals.prefix(width > 1200 ? 4 : 3)) { goal in
                    SavingsGoalCard(goal: goal)
                        .frame(height: 160)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Recent Transactions Section
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    withAnimation {
                        selectedTab = 1 // Index of Transactions tab
                    }
                }
                .font(.subheadline)
                .foregroundColor(.aurumGold)
            }
            
            VStack(spacing: 0) {
                ForEach(financeStore.recentTransactions.prefix(5)) { transaction in
                    TransactionRow(transaction: transaction)
                        .padding(.vertical, 12)
                    
                    if transaction.id != financeStore.recentTransactions.prefix(5).last?.id {
                        Divider()
                            .background(Color.aurumGray.opacity(0.3))
                    }
                }
            }
            .cardStyle()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Supporting Views

struct NetWorthCard: View {
    let summary: FinancialSummary
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Net Worth")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(summary.netWorth.currencyFormatted)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.aurumGold)
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 32))
                    .foregroundColor(.aurumGold)
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Assets")
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                    Text(summary.totalAssets.compactCurrencyFormatted)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumGreen)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Liabilities")
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                    Text(summary.totalLiabilities.compactCurrencyFormatted)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumRed)
                }
            }
        }
        .padding(24)
        .cardStyle()
    }
}

struct QuickStatCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    var isPercentage: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if isPercentage {
                    let percentage = value > 0 ? (value / (value + abs(value))) * 100 : 0
                    Text("\(Int(percentage))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text(value.compactCurrencyFormatted)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(20)
        .frame(minWidth: 150, maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .cardStyle()
    }
}

struct SavingsGoalCard: View {
    let goal: SavingsGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: goal.category.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: goal.category.color))
                
                Spacer()
                
                Text("\(Int(goal.progress * 100))%")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(goal.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("\(goal.currentAmount.compactCurrencyFormatted) of \(goal.targetAmount.compactCurrencyFormatted)")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
            }
            
            ProgressView(value: goal.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: goal.category.color)))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(20)
        .frame(width: 200, height: 160)
        .cardStyle()
    }
}

#Preview {
    DashboardView(selectedTab: .constant(0))
} 