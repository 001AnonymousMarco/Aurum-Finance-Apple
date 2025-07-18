//
//  MobileGoalsView.swift
//  Aurum Finance
//
//  Created by Marc Alleyne on 7/7/25.
//

import SwiftUI

struct MobileGoalsView: View {
    @EnvironmentObject var financeStore: FinanceStore
    @State private var showingAddGoal = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Add Button
            mobileHeader
            
            // Goals List
            if financeStore.savingsGoals.isEmpty {
                mobileEmptyState
            } else {
                mobileGoalsList
            }
        }
        .background(Color.aurumDark)
        .sheet(isPresented: $showingAddGoal) {
            NavigationStack {
                AddSavingsGoalView()
                    .environmentObject(financeStore)
                    .navigationTitle("Add Goal")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingAddGoal = false
                            }
                        }
                    }
            }
        }
    }
    
    private var mobileHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Savings Goals")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.aurumText)
                
                Text("\(financeStore.savingsGoals.count) active goals")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
            }
            
            Spacer()
            
            Button(action: {
                showingAddGoal = true
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
    
    private var mobileGoalsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(financeStore.savingsGoals, id: \.id) { goal in
                    MobileGoalCard(goal: goal)
                        .contextMenu {
                            Button("Edit") {
                                // Edit goal
                            }
                            
                            Button("Delete", role: .destructive) {
                                // Delete goal
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100) // Space for floating button
        }
    }
    
    private var mobileEmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.aurumGray)
            
            VStack(spacing: 8) {
                Text("No Savings Goals")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.aurumText)
                
                Text("Create your first savings goal to start tracking your progress")
                    .font(.subheadline)
                    .foregroundColor(.aurumGray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddGoal = true
            }) {
                Text("Create Goal")
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

// MARK: - Mobile Goal Card (Enhanced)
struct MobileGoalCard: View {
    let goal: SavingsGoal
    
    private var progressPercentage: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(goal.savedAmount / goal.targetAmount, 1.0)
    }
    
    private var daysRemaining: Int {
        let calendar = Calendar.current
        let today = Date()
        let targetDate = goal.targetDate
        
        guard targetDate > today else { return 0 }
        
        let components = calendar.dateComponents([.day], from: today, to: targetDate)
        return components.day ?? 0
    }
    
    private var isOverdue: Bool {
        goal.targetDate < Date() && progressPercentage < 1.0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                // Goal Icon
                Circle()
                    .fill(Color.aurumBlue)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "target")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.aurumText)
                    
                    Text(goal.category)
                        .font(.subheadline)
                        .foregroundColor(.aurumGray)
                }
                
                Spacer()
                
                // Status Badge
                Text(statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .cornerRadius(6)
            }
            
            // Progress Section
            VStack(spacing: 12) {
                // Progress Bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.subheadline)
                            .foregroundColor(.aurumGray)
                        
                        Spacer()
                        
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.aurumGold)
                    }
                    
                    ProgressView(value: progressPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: .aurumBlue))
                        .scaleEffect(x: 1, y: 3, anchor: .center)
                }
                
                // Amount Details
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saved")
                            .font(.caption)
                            .foregroundColor(.aurumGray)
                        
                        Text(goal.savedAmount.formatted(.currency(code: "USD")))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.aurumGreen)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Target")
                            .font(.caption)
                            .foregroundColor(.aurumGray)
                        
                        Text(goal.targetAmount.formatted(.currency(code: "USD")))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.aurumText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundColor(.aurumGray)
                        
                        Text((goal.targetAmount - goal.savedAmount).formatted(.currency(code: "USD")))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.aurumRed)
                    }
                }
            }
            
            // Timeline
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.aurumGray)
                    .font(.caption)
                
                Text(timelineText)
                    .font(.caption)
                    .foregroundColor(.aurumGray)
                
                Spacer()
                
                if !isOverdue && daysRemaining > 0 {
                    Text("\(daysRemaining) days left")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.aurumGold)
                }
            }
        }
        .padding(20)
        .background(Color.aurumCard)
        .cornerRadius(16)
    }
    
    private var statusText: String {
        if progressPercentage >= 1.0 {
            return "Completed"
        } else if isOverdue {
            return "Overdue"
        } else if daysRemaining <= 7 {
            return "Due Soon"
        } else {
            return "In Progress"
        }
    }
    
    private var statusColor: Color {
        if progressPercentage >= 1.0 {
            return .aurumGreen
        } else if isOverdue {
            return .aurumRed
        } else if daysRemaining <= 7 {
            return .aurumOrange
        } else {
            return .aurumBlue
        }
    }
    
    private var timelineText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if progressPercentage >= 1.0 {
            return "Completed on \(formatter.string(from: goal.targetDate))"
        } else if isOverdue {
            return "Was due \(formatter.string(from: goal.targetDate))"
        } else {
            return "Due \(formatter.string(from: goal.targetDate))"
        }
    }
} 