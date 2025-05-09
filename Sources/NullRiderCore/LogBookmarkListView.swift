//
//  LogBookmarkListView.swift
//  BasePackage
//
//  Created by Adam Lyon on 4/22/25.
//

import SwiftUI
import SwiftData

public struct LogBookmarkListView: View {
    @Query(sort: [SortDescriptor(\UserLogBookmark.savedAt, order: .reverse)]) private var bookmarks: [UserLogBookmark]
    @Environment(\.modelContext) private var modelContext
    
    public init() {}
    
    public var body: some View {
        List {
            ForEach(bookmarks) { bookmark in
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookmark.line)
                        .font(.body)
                        .foregroundColor(color(for: bookmark.severity))
                    Text("\(bookmark.file):\(bookmark.lineNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let note = bookmark.note {
                        Text(note)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Text(bookmark.savedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 6)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(bookmarks[index])
                }
            }
        }
        .navigationTitle("Saved Bookmarks")
    }

    private func color(for severity: LogLevel) -> Color {
        switch severity {
        case .debug: return .gray
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .critical: return .purple
        }
    }
}

#Preview {
    NavigationStack {
        LogBookmarkListView()
            .modelContainer(for: UserLogBookmark.self, inMemory: true)
    }
}
