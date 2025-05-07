import SwiftUI

/// A customizable button that adapts to the current theme style.
public struct ThemedButton: View {
    public let title: String
    public let action: () -> Void
    public var theme: AppTheme

    public init(_ title: String, theme: AppTheme, action: @escaping () -> Void) {
        self.title = title
        self.theme = theme
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeManager.accent(for: theme))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

/// A secondary button with a bordered style.
public struct ThemedSecondaryButton: View {
    public let title: String
    public let action: () -> Void
    public var theme: AppTheme

    public init(_ title: String, theme: AppTheme, action: @escaping () -> Void) {
        self.title = title
        self.theme = theme
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.medium)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                .foregroundColor(ThemeManager.accent(for: theme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeManager.accent(for: theme), lineWidth: 2)
                )
        }
    }
}

/// A styled text element that adapts to the theme.
public struct ThemedText: View {
    public let content: String
    public var theme: AppTheme

    public init(_ content: String, theme: AppTheme) {
        self.content = content
        self.theme = theme
    }

    public var body: some View {
        Text(content)
            .foregroundColor(ThemeManager.primaryText(for: theme))
    }
}

/// A toggle that matches the theme styling.
public struct ThemedToggle: View {
    public let label: String
    @Binding public var isOn: Bool
    public var theme: AppTheme

    public init(_ label: String, isOn: Binding<Bool>, theme: AppTheme) {
        self.label = label
        self._isOn = isOn
        self.theme = theme
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .foregroundColor(ThemeManager.primaryText(for: theme))
        }
        .tint(ThemeManager.accent(for: theme))
    }
}

/// A stylized card container with padding and rounded corners.
public struct ThemedCard<Content: View>: View {
    public var theme: AppTheme
    public let content: () -> Content

    public init(theme: AppTheme, @ViewBuilder content: @escaping () -> Content) {
        self.theme = theme
        self.content = content
    }

    public var body: some View {
        content()
            .padding()
            .background(ThemeManager.secondaryBackground(for: theme))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

/// A themed picker that applies custom styling to the selection UI.
public struct ThemedPicker<T: Hashable & CustomStringConvertible>: View {
    public let label: String
    @Binding public var selection: T
    public let options: [T]
    public var theme: AppTheme

    public init(_ label: String, selection: Binding<T>, options: [T], theme: AppTheme) {
        self.label = label
        self._selection = selection
        self.options = options
        self.theme = theme
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .foregroundColor(ThemeManager.secondaryText(for: theme))
                .font(.caption)
            Picker(selection: $selection, label: Text(label)) {
                ForEach(options, id: \ .self) { option in
                    Text(option.description.capitalized).tag(option)
                }
            }
            .pickerStyle(.menu)
            .padding(10)
            .background(ThemeManager.secondaryBackground(for: theme))
            .cornerRadius(10)
        }
    }
}

//// MARK: - Preview
//#Preview {
//    VStack(spacing: 16) {
//        ThemedButton("Primary", theme: .nullrider) { }
//        ThemedSecondaryButton("Secondary", theme: .nullrider) { }
//        ThemedText("Hello, themed world!", theme: .nullrider)
//        ThemedToggle("Enable feature", isOn: .constant(true), theme: .nullrider)
//        ThemedCard(theme: .nullrider) {
//            Text("Inside a card")
//        }
//        ThemedPicker("Log Level", selection: .constant(LogLevel.debug), options: LogLevel.allCases, theme: .nullrider)
//    }
//    .padding()
//    .background(ThemeManager.primaryBackground(for: .nullrider))
//}
