import SwiftUI
import Combine

private struct ToastRequest {
    let message: String
    let position: ToastView.Position
    let animated: Bool
    let duration: Double
}

public class ToastManager: @unchecked Sendable, ObservableObject {
    public static let shared = ToastManager()

    @Published public var message: String? = nil
    //@Published public var toastID = UUID()
    public var position: ToastView.Position = .bottom
    public var isAnimated: Bool = true

    private var isShowingToast = false
    private var queue: [ToastRequest] = []

    private init() {}

    public func show(
        message: String,
        position: ToastView.Position = .bottom,
        animated: Bool = true,
        duration: Double = 2.5
    ) {
        let request = ToastRequest(message: message, position: position, animated: animated, duration: duration)

        if isShowingToast {
            queue.append(request)
            print("Toast showing, appending to queue")
        } else {
            showNextToast(request)
            print("Showing the toast right off")
        }
    }

    private func showNextToast(_ request: ToastRequest) {
        isShowingToast = true
        self.message = request.message
        //self.toastID = UUID() // Force update
        self.position = request.position
        self.isAnimated = request.animated

        DispatchQueue.main.asyncAfter(deadline: .now() + request.duration + 0.5) {
            self.message = nil
            self.isShowingToast = false

            if !self.queue.isEmpty {
                print("Toast Queue is not empty, pushing next toast")
                let next = self.queue.removeFirst()
                
                // ⏳ Delay before showing next toast
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showNextToast(next)
                }
            } else {
                print("Toast Queue is empty")
            }
        }
    }
}

