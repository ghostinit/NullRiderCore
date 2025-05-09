import SwiftUI

public struct LogView: View {
    @ObservedObject private var logger = Logger.shared
    
    private var injectToastOverlay: Bool
    public init(injectToastOverlay: Bool) {
        self.injectToastOverlay = injectToastOverlay
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                if logger.inMemoryLog.isNotEmpty {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(logger.inMemoryLog.indices.reversed(), id: \.self) { index in
                            Text(logger.inMemoryLog[index])
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundColor(color(for: logger.inMemoryLog[index]))
                                .padding(.horizontal)
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                } else {
                    Text("No in memory logs to show")
                }
            }
            .navigationTitle("Log Output")
            .toolbar {
                Button("Clear") {
                    logger.clearInMemoryLog()
                    ToastManager.shared.show(message: "In Memory Log Cleared", position: .top)

                }
            }
            if injectToastOverlay {
                ToastOverlay()
            }
        }
    }
}

private func color(for logLine: String) -> Color {
    if logLine.contains("[CRITICAL]") {
        return .red
    } else if logLine.contains("[ERROR]") {
        return .orange
    } else if logLine.contains("[WARNING]") {
        return .yellow
    } else if logLine.contains("[INFO]") {
        return .blue
    } else if logLine.contains("[DEBUG]") {
        return .gray
    } else {
        return .green // default fallback
    }
}


struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView(injectToastOverlay: false)
    }
}
