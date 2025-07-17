import Foundation
import SwiftUI

// MARK: - Currency Formatting

extension Double {
    var currencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    var compactCurrencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        if self >= 1000000 {
            formatter.positiveSuffix = "M"
            return formatter.string(from: NSNumber(value: self / 1000000)) ?? "$0M"
        } else if self >= 1000 {
            formatter.positiveSuffix = "K"
            return formatter.string(from: NSNumber(value: self / 1000)) ?? "$0K"
        } else {
            return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
        }
    }
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let aurumText = Color("AurumText", bundle: nil)
    static let aurumSecondaryText = Color("AurumSecondaryText", bundle: nil)
    static let aurumBorder = Color("AurumBorder", bundle: nil)
    // Fallbacks if asset not found (optional, for safety)
    static var aurumTextFallback: Color { Color.white }
    static var aurumSecondaryTextFallback: Color { Color(red: 0.54, green: 0.54, blue: 0.56) } // #8A8A8E
    static var aurumBorderFallback: Color { Color(red: 0.23, green: 0.23, blue: 0.24) } // #3A3A3C
    static let aurumTertiaryText = Color("AurumTertiaryText", bundle: nil)
    static var aurumTertiaryTextFallback: Color { Color(red: 0.39, green: 0.39, blue: 0.40) } // #636366
}

// MARK: - Date Extensions

extension Date {
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
    
    var monthYearFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }
    
    var dayMonthFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    var timeAgoFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - App Colors

extension Color {
    // Primary Branding Colors
    static let aurumGold = Color(hex: "#F4B400")        // Primary Accent (Signal Gold)
    static let aurumInk = Color(hex: "#0B0D14")         // Primary Background (Aurum Ink)
    
    // Background Colors
    static let aurumDark = Color(hex: "#000000")        // Primary Background (Black)
    static let aurumCard = Color(hex: "#1C1C1E")        // Secondary Background (Off-Black)
    
    // Accent Colors
    static let aurumPurple = Color(hex: "#A855F7")      // Primary Accent
    static let aurumBlue = Color(hex: "#3B82F6")        // Secondary Accent
    static let aurumOrange = Color(hex: "#F97316")      // Tertiary Accent
    
    // Semantic Colors
    static let aurumGreen = Color(hex: "#34C759")       // Success
    static let aurumRed = Color(hex: "#FF3B30")         // Error
    static let aurumWarning = Color(hex: "#FF9500")     // Warning
    
    // Text & Greyscale Colors
    static let aurumGray = Color(hex: "#8A8A8E")        // Secondary Text / Medium Gray
    static let aurumGrayTertiary = Color(hex: "#636366") // Tertiary Text
    static let aurumGrayDark = Color(hex: "#3A3A3C")    // Dark Gray
    static let aurumGrayLight = Color(hex: "#E5E5EA")   // Light Gray
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.aurumCard)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    func goldButton() -> some View {
        self
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.aurumGold)
            .cornerRadius(25)
            .shadow(color: Color.aurumGold.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    func secondaryButton() -> some View {
        self
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.aurumCard)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.aurumGray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Custom Shapes

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: RectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = corners.contains(.topLeft) ? radius : 0
        let topRight = corners.contains(.topRight) ? radius : 0
        let bottomLeft = corners.contains(.bottomLeft) ? radius : 0
        let bottomRight = corners.contains(.bottomRight) ? radius : 0
        
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        
        if topRight > 0 {
            path.addArc(center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
                       radius: topRight,
                       startAngle: Angle(degrees: -90),
                       endAngle: Angle(degrees: 0),
                       clockwise: false)
        }
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        
        if bottomRight > 0 {
            path.addArc(center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
                       radius: bottomRight,
                       startAngle: Angle(degrees: 0),
                       endAngle: Angle(degrees: 90),
                       clockwise: false)
        }
        
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        
        if bottomLeft > 0 {
            path.addArc(center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
                       radius: bottomLeft,
                       startAngle: Angle(degrees: 90),
                       endAngle: Angle(degrees: 180),
                       clockwise: false)
        }
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        
        if topLeft > 0 {
            path.addArc(center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
                       radius: topLeft,
                       startAngle: Angle(degrees: 180),
                       endAngle: Angle(degrees: 270),
                       clockwise: false)
        }
        
        return path
    }
}

struct RectCorner: OptionSet {
    let rawValue: Int
    
    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)
    
    static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Icon Constants

extension Image {
    static let aurumAdd = Image(systemName: "plus.circle.fill")
    static let aurumProfile = Image(systemName: "person.circle.fill")
    static let aurumNotification = Image(systemName: "bell.fill")
    static let aurumSuccess = Image(systemName: "checkmark.circle.fill")
    static let aurumWarning = Image(systemName: "exclamationmark.triangle.fill")
    static let aurumError = Image(systemName: "xmark.circle.fill")
    static let aurumEdit = Image(systemName: "pencil.circle.fill")
    static let aurumDelete = Image(systemName: "trash.circle.fill")
    static let aurumSettings = Image(systemName: "gear.circle.fill")
    static let aurumInfo = Image(systemName: "info.circle.fill")
    static let aurumClose = Image(systemName: "xmark.circle.fill")
}
