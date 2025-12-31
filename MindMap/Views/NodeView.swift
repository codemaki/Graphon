import SwiftUI
import SwiftData

struct NodeView: View, Equatable {
    @Bindable var node: MindMapNode
    let isSelected: Bool
    let scale: CGFloat

    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    // Equatable 구현으로 불필요한 재렌더링 방지
    static func == (lhs: NodeView, rhs: NodeView) -> Bool {
        lhs.node.id == rhs.node.id &&
        lhs.node.text == rhs.node.text &&
        lhs.isSelected == rhs.isSelected &&
        abs(lhs.scale - rhs.scale) < 0.01 &&
        lhs.node.x == rhs.node.x &&
        lhs.node.y == rhs.node.y
    }

    var body: some View {
        VStack(spacing: 0) {
            if isEditing {
                TextField("Node text", text: $node.text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .font(.system(size: node.fontSize))
                    .padding(8)
                    .background(backgroundColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(borderColor, lineWidth: 2)
                    )
                    .onSubmit {
                        isEditing = false
                    }
            } else {
                Text(node.text)
                    .font(.system(size: node.fontSize))
                    .padding(8)
                    .background(backgroundColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(borderColor, lineWidth: isSelected ? 2 : 1)
                    )
                    .onTapGesture(count: 2) {
                        isEditing = true
                        isFocused = true
                    }
            }
        }
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .scaleEffect(min(1.0, 1.0 / scale))
    }

    private var backgroundColor: Color {
        if let colorHex = node.colorHex {
            return Color(hex: colorHex) ?? .white
        }
        return .white
    }

    private var borderColor: Color {
        isSelected ? .accentColor : .gray.opacity(0.3)
    }
}

// Color extension for hex support
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        #if os(macOS)
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
        #else
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
        #endif
    }

    func toHex() -> String? {
        #if os(macOS)
        guard let components = NSColor(self).cgColor.components else { return nil }
        #else
        guard let components = UIColor(self).cgColor.components else { return nil }
        #endif

        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#if os(macOS)
import AppKit
typealias PlatformColor = NSColor
#else
import UIKit
typealias PlatformColor = UIColor
#endif
