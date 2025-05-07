import SwiftUI

public struct ToastOverlay: View {
    @ObservedObject private var toastManager = ToastManager.shared
    @State private var show: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            if let message = toastManager.message, show {
                ToastView(
                    message: message,
                    position: toastManager.position,
                    isAnimated: toastManager.isAnimated
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            show = false
                            toastManager.message = nil
                        }
                    }
                }
            }
        }
        .onReceive(toastManager.$message) { newMessage in
            if newMessage != nil {
                withAnimation {
                    show = true
                }
            }
        }
        .allowsHitTesting(false) // Let taps pass through
    }
}
