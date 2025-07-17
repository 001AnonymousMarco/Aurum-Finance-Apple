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
                LazyVStack(spacing: .spacingL) {
                    // Header
                    headerSection
                        .padding(.top, 16)
                    
                    // Enhanced Net Worth Card with Cash Flow
                    EnhancedNetWorthCard(
                        summary: financeStore.financialSummary,
                        cashFlow: financeStore.cashFlowAnalysis
                    )
                        .id(financeStore.financialSummary.netWorth)
                    
                    // Enhanced Quick Stats with Cash Flow Indicators
                    enhancedQuickStatsSection(width: geometry.size.width)
                        .id(financeStore.financialSummary.totalIncome)
                    
                    // Enhanced Charts Section with Better Analytics
                    enhancedChartsSection(width: geometry.size.width)
                        .id(financeStore.financialSummary.totalExpenses)
                    
                    // Monthly Trends Chart
                    monthlyTrendsSection(width: geometry.size.width)
                    
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
                    Image(systemName: "plus.circle.fill")
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
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.aurumCard)
                    .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Enhanced Quick Stats Section
    
    private func enhancedQuickStatsSection(width: CGFloat) -> some View {
        VStack(spacing: .spacingM) {
            Text("Financial Overview")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let columns = {
                #if os(macOS)
                return width > 1200 ? [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ] : width > 800 ? [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ] : [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ]
                #else
                return width > 600 ? [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ] : [
                    GridItem(.flexible(), spacing: 16)
                ]
                #endif
            }()
            
            LazyVGrid(columns: columns, spacing: 16) {
                let cashFlow = financeStore.cashFlowAnalysis
                
                QuickStatCard(
                    title: "Monthly Income",
                    value: cashFlow.monthlyIncome,
                    icon: "arrow.up.circle.fill",
                    color: .aurumGreen
                )
                
                QuickStatCard(
                    title: "Monthly Expenses",
                    value: cashFlow.monthlyExpenses,
                    icon: "arrow.down.circle.fill",
                    color: .aurumRed
                )
                
                CashFlowStatCard(cashFlow: cashFlow)
                
                QuickStatCard(
                    title: "Savings Rate",
                    value: cashFlow.savingsRate,
                    icon: "percent",
                    color: .aurumBlue,
                    isPercentage: true
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Enhanced Charts Section
    
    private func enhancedChartsSection(width: CGFloat) -> some View {
        VStack(spacing: 24) {
            Text("Analytics")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if width > 800 {
                HStack(spacing: 24) {
                    IncomeExpenseChart(financeStore: financeStore)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                    
                    EnhancedExpenseBreakdownChart(
                        expenseBreakdown: financeStore.detailedExpenseBreakdown,
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
                    
                    EnhancedExpenseBreakdownChart(
                        expenseBreakdown: financeStore.detailedExpenseBreakdown,
                        selectedCategory: $selectedExpenseCategory
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Monthly Trends Section
    
    private func monthlyTrendsSection(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("12-Month Trends")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            MonthlyTrendsChart(trends: financeStore.monthlyTrends)
                .frame(height: 200)
                .cardStyle()
        }
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

// MARK: - Enhanced Supporting Views

struct EnhancedNetWorthCard: View {
    let summary: FinancialSummary
    let cashFlow: CashFlowAnalysis
    
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
                
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: cashFlow.cashFlowStatus.icon)
                            .foregroundColor(Color(hex: cashFlow.cashFlowStatus.color))
                        Text(cashFlow.netCashFlow.currencyFormatted)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: cashFlow.cashFlowStatus.color))
                    }
                    Text("Monthly Cash Flow")
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                }
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
                
                VStack(alignment: .center, spacing: 8) {
                    Text("Savings Rate")
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                    Text("\(Int(cashFlow.savingsRate))%")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumBlue)
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

struct CashFlowStatCard: View {
    let cashFlow: CashFlowAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: cashFlow.cashFlowStatus.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: cashFlow.cashFlowStatus.color))
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(cashFlow.netCashFlow.compactCurrencyFormatted)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Cash Flow")
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

struct EnhancedExpenseBreakdownChart: View {
    let expenseBreakdown: [ExpenseBreakdownItem]
    @Binding var selectedCategory: ExpenseCategory?
    
    private var totalExpenses: Double {
        expenseBreakdown.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Expense Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(totalExpenses.compactCurrencyFormatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.aurumGold)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            GeometryReader { geometry in
                HStack(spacing: 20) {
                    // Donut Chart
                    ZStack {
                        DonutChart(
                            data: expenseBreakdown.map { ($0.amount, Color(hex: $0.category.color)) },
                            selectedIndex: selectedCategory != nil ? 
                                expenseBreakdown.firstIndex(where: { $0.category == selectedCategory }) : nil
                        )
                        .frame(width: 120, height: 120)
                        .onTapGesture { location in
                            selectedCategory = getSelectedCategory(at: location)
                        }
                        
                        VStack(spacing: 2) {
                            if let selected = selectedCategory,
                               let item = expenseBreakdown.first(where: { $0.category == selected }) {
                                Text(item.amount.compactCurrencyFormatted)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("\(Int(item.percentage))%")
                                    .font(.caption)
                                    .foregroundColor(.aurumGray)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text(totalExpenses.compactCurrencyFormatted)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(.aurumGray)
                            }
                        }
                    }
                    .frame(width: 120)
                    
                    // Enhanced Category List with Percentages
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(expenseBreakdown, id: \.id) { item in
                                EnhancedExpenseCategoryRow(
                                    item: item,
                                    isSelected: selectedCategory == item.category
                                )
                                .onTapGesture {
                                    selectedCategory = selectedCategory == item.category ? nil : item.category
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height)
            }
            .frame(height: 200)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private func getSelectedCategory(at location: CGPoint) -> ExpenseCategory? {
        let index = Int(location.y / 24)
        guard index < expenseBreakdown.count else { return nil }
        return expenseBreakdown[index].category
    }
}

struct EnhancedExpenseCategoryRow: View {
    let item: ExpenseBreakdownItem
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: item.category.color))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.category.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .aurumGray)
                    .lineLimit(1)
                
                Text("\(Int(item.percentage))%")
                    .font(.caption2)
                    .foregroundColor(.aurumGray)
            }
            
            Spacer()
            
            Text(item.amount.compactCurrencyFormatted)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .aurumGray)
        }
        .padding(.vertical, 2)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

struct MonthlyTrendsChart: View {
    let trends: [MonthlyTrend]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Income vs Expenses Trend")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.aurumGreen)
                            .frame(width: 8, height: 8)
                        Text("Income")
                            .font(.caption2)
                            .foregroundColor(.aurumGray)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.aurumRed)
                            .frame(width: 8, height: 8)
                        Text("Expenses")
                            .font(.caption2)
                            .foregroundColor(.aurumGray)
                    }
                }
            }
            
            GeometryReader { geometry in
                let maxValue = trends.map { max($0.income, $0.expenses) }.max() ?? 1
                let barWidth = max(10, (geometry.size.width - CGFloat(trends.count - 1) * 4) / CGFloat(trends.count))
                
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(trends) { trend in
                        VStack(spacing: 2) {
                            VStack(spacing: 1) {
                                // Income bar
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.aurumGreen)
                                    .frame(
                                        width: barWidth,
                                        height: max(2, CGFloat(trend.income / maxValue) * (geometry.size.height - 30))
                                    )
                                
                                // Expense bar
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.aurumRed)
                                    .frame(
                                        width: barWidth,
                                        height: max(2, CGFloat(trend.expenses / maxValue) * (geometry.size.height - 30))
                                    )
                            }
                            
                            Text(trend.shortMonthName)
                                .font(.caption2)
                                .foregroundColor(.aurumGray)
                                .frame(width: barWidth)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(20)
    }
}

#Preview {
    DashboardView(selectedTab: .constant(0))
}

// MARK: - Transaction Row (for Dashboard)

struct TransactionRow: View {
    let transaction: AnyTransaction
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon/Avatar
            Circle()
                .fill(Color(hex: transaction.categoryColor))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: transaction.categoryIcon)
                        .font(.title3)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description ?? "Transaction")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(transaction.type == .income ? "Income" : "Expense")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(transaction.type == .income ? .aurumGreen : .aurumRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            (transaction.type == .income ? Color.aurumGreen : Color.aurumRed)
                                .opacity(0.2)
                        )
                        .cornerRadius(8)
                    
                    Text(dateFormatter.string(from: transaction.date))
                        .font(.caption)
                        .foregroundColor(.aurumGray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text((transaction.type == .income ? "+" : "-") + transaction.amount.compactCurrencyFormatted)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.type == .income ? .aurumGreen : .aurumRed)
            }
        }
        .padding(.vertical, 8)
    }
} 