import SwiftUI

// MARK: - Income vs Expense Chart

struct IncomeExpenseChart: View {
    let financeStore: FinanceStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Income vs Expenses")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("This Month")
                    .font(.caption)
                    .foregroundColor(.aurumGray)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            GeometryReader { geometry in
                VStack(spacing: 12) {
                    // Income Bar
                    BarChartRow(
                        title: "Income",
                        icon: "arrow.up.circle.fill",
                        iconColor: .aurumGreen,
                        value: financeStore.financialSummary.totalIncome,
                        maxValue: maxValue,
                        barColor: .aurumGreen,
                        width: geometry.size.width - 40 // Account for padding
                    )
                    
                    // Expense Bar
                    BarChartRow(
                        title: "Expenses",
                        icon: "arrow.down.circle.fill",
                        iconColor: .aurumRed,
                        value: financeStore.financialSummary.totalExpenses,
                        maxValue: maxValue,
                        barColor: .aurumRed,
                        width: geometry.size.width - 40
                    )
                    
                    // Net Savings
                    BarChartRow(
                        title: "Net",
                        icon: "equal.circle.fill",
                        iconColor: .aurumGold,
                        value: financeStore.financialSummary.monthlySavings,
                        maxValue: maxValue,
                        barColor: .aurumGold,
                        width: geometry.size.width - 40
                    )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(height: 140)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private var maxValue: Double {
        max(
            financeStore.financialSummary.totalIncome,
            financeStore.financialSummary.totalExpenses,
            abs(financeStore.financialSummary.monthlySavings)
        )
    }
}

struct BarChartRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    let value: Double
    let maxValue: Double
    let barColor: Color
    let width: CGFloat
    
    private var barWidth: CGFloat {
        guard maxValue > 0 else { return 0 }
        let availableWidth = max(0, width - 180) // Ensure available width is never negative
        let ratio = abs(value) / maxValue
        return max(0, min(availableWidth, CGFloat(ratio) * availableWidth)) // Clamp between 0 and availableWidth
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Label
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .frame(width: 100, alignment: .leading)
            
            // Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.aurumGray.opacity(0.2))
                        .frame(height: 32)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(barColor)
                        .frame(width: barWidth, height: 32)
                }
            }
            .frame(height: 32)
            
            // Value
            Text(value.compactCurrencyFormatted)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 80, alignment: .trailing)
        }
    }
}

// MARK: - Expense Breakdown Chart

struct ExpenseBreakdownChart: View {
    let expensesByCategory: [ExpenseCategory: Double]
    @Binding var selectedCategory: ExpenseCategory?
    
    private var sortedExpenses: [(category: ExpenseCategory, amount: Double)] {
        expensesByCategory.map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    private var totalExpenses: Double {
        expensesByCategory.values.reduce(0, +)
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
                            data: sortedExpenses.map { ($0.amount, Color(hex: $0.category.color)) },
                            selectedIndex: selectedCategory != nil ? sortedExpenses.firstIndex(where: { $0.category == selectedCategory }) : nil
                        )
                        .frame(width: 120, height: 120)
                        .onTapGesture { location in
                            selectedCategory = getSelectedCategory(at: location)
                        }
                        
                        VStack(spacing: 2) {
                            if let selected = selectedCategory,
                               let amount = expensesByCategory[selected] {
                                Text(amount.compactCurrencyFormatted)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(selected.rawValue)
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
                    
                    // Category List
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(sortedExpenses, id: \.category) { item in
                                ExpenseCategoryRow(
                                    category: item.category,
                                    amount: item.amount,
                                    percentage: item.amount / totalExpenses,
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
        guard index < sortedExpenses.count else { return nil }
        return sortedExpenses[index].category
    }
}

// MARK: - Supporting Views

struct DonutChart: View {
    let data: [(value: Double, color: Color)]
    let selectedIndex: Int?
    
    private var total: Double {
        data.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.aurumGray.opacity(0.2), lineWidth: 20)
                
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    DonutSegment(
                        value: item.value,
                        total: total,
                        startAngle: startAngle(for: index),
                        color: item.color,
                        isSelected: selectedIndex == index
                    )
                }
            }
            .frame(width: min(geometry.size.width, geometry.size.height),
                   height: min(geometry.size.width, geometry.size.height))
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousSum = data.prefix(index).reduce(0) { $0 + $1.value }
        return Angle(degrees: (previousSum / total) * 360 - 90)
    }
}

struct DonutSegment: View {
    let value: Double
    let total: Double
    let startAngle: Angle
    let color: Color
    let isSelected: Bool
    
    private var endAngle: Angle {
        Angle(degrees: startAngle.degrees + (value / total) * 360)
    }
    
    var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(value / total))
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: isSelected ? 24 : 20,
                    lineCap: .round
                )
            )
            .rotationEffect(startAngle)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct ExpenseCategoryRow: View {
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: category.color))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .aurumGray)
                    .lineLimit(1)
                
                Text("\(Int(percentage * 100))%")
                    .font(.caption2)
                    .foregroundColor(.aurumGray)
            }
            
            Spacer()
            
            Text(amount.compactCurrencyFormatted)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .aurumGray)
        }
        .padding(.vertical, 2)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
} 