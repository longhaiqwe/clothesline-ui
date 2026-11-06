import SwiftUI

/// Visual preferences only; no dependency on a host product's notes or models.
enum RailStyle: String, CaseIterable {
    case system, looseleaf
    static let defaultsKey = "rail.style"
    var title: String { self == .system ? "系统材质" : "手绘纸张" }
}

enum RailPaper {
    static let ink = Color(red: 0.20, green: 0.23, blue: 0.20)
    static let canvas = Color(red: 0.97, green: 0.95, blue: 0.89)
    static let sage = Color(red: 0.62, green: 0.72, blue: 0.68)
    static func color(_ index: Int) -> Color {
        let colors = [Color(red: 0.96, green: 0.86, blue: 0.58),
                      Color(red: 0.76, green: 0.84, blue: 0.72),
                      Color(red: 0.75, green: 0.84, blue: 0.88),
                      Color(red: 0.93, green: 0.75, blue: 0.67)]
        return colors[max(0, min(index, colors.count - 1))]
    }
}

private struct RailStyleKey: EnvironmentKey {
    static let defaultValue = RailStyle.system
}
extension EnvironmentValues {
    var railStyle: RailStyle {
        get { self[RailStyleKey.self] }
        set { self[RailStyleKey.self] = newValue }
    }
}

/// Keep view identity and @State while changing the appearance of an open window.
struct RailAppearance: ViewModifier {
    @ObservedObject var state: RailState
    var windowBackground = false
    func body(content: Content) -> some View {
        content
            .background {
                if windowBackground {
                    state.style == .looseleaf ? RailPaper.canvas : Color(nsColor: .windowBackgroundColor)
                }
            }
            .environment(\.railStyle, state.style)
            .transformEnvironment(\.colorScheme) { if state.style == .looseleaf { $0 = .light } }
            .foregroundStyle(state.style == .looseleaf ? RailPaper.ink : Color.primary)
            .tint(state.style == .looseleaf ? RailPaper.ink : Color.accentColor)
    }
}

/// Fixed curves keep outlines stable during text entry, layout and animation.
struct RailPaperShape: Shape {
    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: 2, dy: 2)
        var p = Path()
        p.move(to: CGPoint(x: r.minX + 7, y: r.minY + 1))
        p.addCurve(to: CGPoint(x: r.maxX - 6, y: r.minY), control1: CGPoint(x: r.width * 0.34, y: r.minY - 1), control2: CGPoint(x: r.width * 0.7, y: r.minY + 3))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY + 7), control: CGPoint(x: r.maxX + 1, y: r.minY))
        p.addCurve(to: CGPoint(x: r.maxX - 1, y: r.maxY - 6), control1: CGPoint(x: r.maxX - 2, y: r.height * 0.35), control2: CGPoint(x: r.maxX + 1, y: r.height * 0.7))
        p.addQuadCurve(to: CGPoint(x: r.maxX - 7, y: r.maxY), control: CGPoint(x: r.maxX, y: r.maxY + 1))
        p.addCurve(to: CGPoint(x: r.minX + 6, y: r.maxY - 1), control1: CGPoint(x: r.width * 0.67, y: r.maxY - 2), control2: CGPoint(x: r.width * 0.3, y: r.maxY + 1))
        p.addQuadCurve(to: CGPoint(x: r.minX, y: r.maxY - 7), control: CGPoint(x: r.minX - 1, y: r.maxY))
        p.addCurve(to: CGPoint(x: r.minX + 1, y: r.minY + 7), control1: CGPoint(x: r.minX + 2, y: r.height * 0.68), control2: CGPoint(x: r.minX - 1, y: r.height * 0.3))
        p.addQuadCurve(to: CGPoint(x: r.minX + 7, y: r.minY + 1), control: CGPoint(x: r.minX, y: r.minY))
        p.closeSubpath()
        return p
    }
}

/// Apply after sizing/padding. Background changes do not rebuild interactive content.
struct RailPaperSurface: ViewModifier {
    @Environment(\.railStyle) private var style
    var colorIndex: Int = 0
    var fill: Color? = nil
    var radius: CGFloat = 8
    var raised = true
    func body(content: Content) -> some View {
        content.background {
            if style == .looseleaf {
                ZStack {
                    if raised { RailPaperShape().fill(RailPaper.ink).offset(x: 3, y: 4) }
                    RailPaperShape().fill(fill ?? RailPaper.color(colorIndex))
                    RailPaperShape().stroke(RailPaper.ink, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                }
            } else {
                RoundedRectangle(cornerRadius: radius).fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
            }
        }
    }
}
