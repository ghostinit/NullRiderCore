import SwiftUI

/// A reusable toast view that can be displayed at the top or bottom of the screen.
public struct ToastView: View {
    public enum Position {
        case top, middle, bottom
    }

    public let message: String
    public let position: Position
    public let isAnimated: Bool
    public let duration: Double

    public init(message: String, position: Position = .bottom, isAnimated: Bool = true, duration: Double = 2.5) {
        self.message = message
        self.position = position
        self.isAnimated = isAnimated
        self.duration = duration
    }

    @State private var show: Bool = false

    public var body: some View {
        VStack {
//            Spacer().frame(height: 50)
//            if position == .top && show {
//                toastContent
//            }
//            Spacer()
//            if position == .middle && show {
//                toastContent
//            }
//            Spacer()
//            if position == .bottom && show {
//                toastContent
//            }
//            Spacer().frame(height: 50)
            switch position {
            case .top:
                Spacer().frame(height: 50)
                if show {
                    toastContent
                }
                Spacer()
            case .middle:
                Spacer()
                if show {
                    toastContent
                }
                Spacer()
            case .bottom:
                Spacer()
                if show {
                    toastContent
                }
                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            withAnimation(isAnimated ? .easeInOut(duration: 0.3) : .none) {
                show = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(isAnimated ? .easeInOut(duration: 0.3) : .none) {
                    show = false
                }
            }
        }
        .padding(.horizontal)
    }

    private var toastContent: some View {
        Text(message)
            .font(.headline)
            .foregroundColor(.white)
            .padding(5)
            .background(Color.gray.opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 4)
            .transition(.move(edge: position == .top ? .top : .bottom).combined(with: .opacity))
    }
}

// MARK: - Preview
#Preview {
    ToastView(message: "This is a toast message!", position: .top)
        .background(Color.gray.opacity(0.2))
        .edgesIgnoringSafeArea(.all)
}
