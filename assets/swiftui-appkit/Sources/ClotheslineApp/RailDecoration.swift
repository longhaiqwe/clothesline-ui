import SwiftUI

struct ClotheslineShape: Shape {
    var edge: ScreenEdge = .top
    func path(in rect: CGRect) -> Path {
        var path = Path()
        func point(_ along: CGFloat, _ inset: CGFloat) -> CGPoint {
            switch edge {
            case .top: return CGPoint(x: along, y: inset)
            case .bottom: return CGPoint(x: along, y: rect.height - inset)
            case .left: return CGPoint(x: inset, y: along)
            case .right: return CGPoint(x: rect.width - inset, y: along)
            }
        }
        let length = edge.vertical ? rect.height : rect.width
        path.move(to: point(-10, 12))
        path.addQuadCurve(to: point(length + 10, 12), control: point(length / 2, 58))
        return path
    }
}

struct WoodenPeg: View {
    @Environment(\.railStyle) private var style
    var body: some View {
        Group {
            if style == .looseleaf {
                RoundedRectangle(cornerRadius: 3).fill(RailPaper.canvas)
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(RailPaper.ink, lineWidth: 1.5))
            } else { woodenFill }
        }
        .frame(width: 11, height: 29)
        .overlay(Rectangle().fill(.black.opacity(0.25)).frame(width: 9, height: 2))
        .shadow(color: .black.opacity(style == .looseleaf ? 0 : 0.33), radius: 1, y: 1)
        .accessibilityHidden(true)
    }
    private var woodenFill: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(LinearGradient(colors: [
                Color(red: 0.66, green: 0.42, blue: 0.23),
                Color(red: 0.88, green: 0.70, blue: 0.45),
                Color(red: 0.66, green: 0.42, blue: 0.23)
            ], startPoint: .leading, endPoint: .trailing))

    }
}

