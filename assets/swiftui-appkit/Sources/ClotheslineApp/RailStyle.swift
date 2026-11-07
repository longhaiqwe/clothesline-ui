import SwiftUI

/// Visual preferences only; no dependency on a host product's notes or models.
enum RailStyle: String, CaseIterable {
    case system, looseleaf
    static let defaultsKey = "rail.style"
    var title: String { self == .system ? "系统材质" : "手绘纸张" }
}

enum RailPaper {
    // Looseleaf Notebook palette: https://kevintngo.github.io/looseleaf/#/foundations/theming
    static let ink = Color(red: 42 / 255.0, green: 36 / 255.0, blue: 32 / 255.0) // #2A2420
    static let inkMuted = Color(red: 74 / 255.0, green: 67 / 255.0, blue: 60 / 255.0) // --ll-ink-muted #4A433C
    static let sheet = Color(red: 248 / 255.0, green: 245 / 255.0, blue: 238 / 255.0) // --ll-paper #F8F5EE
    static let canvas = sheet
    static let slip = Color(red: 251 / 255.0, green: 248 / 255.0, blue: 241 / 255.0) // --ll-slip #FBF8F1
    static let backdrop = Color(red: 168 / 255.0, green: 200 / 255.0, blue: 187 / 255.0) // --ll-desk #A8C8BB
    static let shadow = Color(red: 58 / 255.0, green: 44 / 255.0, blue: 30 / 255.0) // --ll-shade #3A2C1E
    static let marker = Color(red: 223 / 255.0, green: 107 / 255.0, blue: 60 / 255.0) // --ll-marker #DF6B3C
    static let sage = backdrop // Compatibility alias for existing custom fills.
    static func color(_ index: Int?) -> Color {
        guard let index else { return sheet }
        // Explicit opt-in stock; yellow stays official, green/blue/pink use lighter 200 tints.
        // Refactoring UI palette: official base, --cap 0 --strength 0; preserve hue.
        let colors = [Color(red: 247 / 255.0, green: 227 / 255.0, blue: 138 / 255.0), // #F7E38A
                      Color(red: 236 / 255.0, green: 245 / 255.0, blue: 221 / 255.0), // #ECF5DD
                      Color(red: 226 / 255.0, green: 238 / 255.0, blue: 248 / 255.0), // #E2EEF8
                      Color(red: 251 / 255.0, green: 225 / 255.0, blue: 222 / 255.0)] // #FBE1DE
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
                    if state.style == .looseleaf {
                        RailPaper.canvas.overlay { RailPaperTexture() }
                    } else {
                        Color(nsColor: .windowBackgroundColor)
                    }
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
    var colorIndex: Int? = nil
    var fill: Color? = nil
    var radius: CGFloat = 8
    var raised = true
    var stock: RailPaperStock = .paper
    func body(content: Content) -> some View {
        content.background {
            if style == .looseleaf {
                ZStack {
                    if raised { RailPaperShape().fill(RailPaper.shadow).offset(x: 3, y: 4) }
                    RailPaperShape().fill(fill ?? RailPaper.color(colorIndex))
                    RailPaperTexture(stock: stock).clipShape(RailPaperShape())
                    RailPaperShape().stroke(RailPaper.ink, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                }
            } else {
                RoundedRectangle(cornerRadius: radius).fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
            }
        }
    }
}
