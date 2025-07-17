import SwiftUI

struct TransactionRow: View {
    let transaction: AnyTransaction
    
    var body: some View {
        HStack(spacing: 20) {
            // Date Column
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.date.formatted(.dateTime.month().day().year(.twoDigits)))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(transaction.date.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.system(size: 14))
                    .foregroundColor(.aurumGray)
            }
            .frame(width: 80, alignment: .leading)
            
            // Description Column
            Text(transaction.description ?? "")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            // Amount Column
            Text(transaction.type == .expense ? "-\(transaction.amount.currencyFormatted)" : transaction.amount.currencyFormatted)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.type == .expense ? .aurumRed : .white)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.aurumCard)
        .cornerRadius(12)
    }
} 