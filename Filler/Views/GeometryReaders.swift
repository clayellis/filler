import SwiftUI

private struct ReaderKey: PreferenceKey {
    // GeometryReader uses a default value of 10.
    static var defaultValue: CGFloat { 10 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct WidthReader<Content: View>: View {
    @State private var width: CGFloat = ReaderKey.defaultValue
    let alignment: Alignment
    let content: (CGFloat) -> Content

    init(alignment: Alignment = .center, content: @escaping (CGFloat) -> Content) {
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        content(width)
            .frame(maxWidth: .infinity, alignment: alignment)
            .background(GeometryReader { proxy in
                Color.clear.preference(key: ReaderKey.self, value: proxy.size.width)
            })
            .onPreferenceChange(ReaderKey.self) { width = $0 }
    }
}

struct HeightReader<Content: View>: View {
    @State private var height: CGFloat = ReaderKey.defaultValue
    let alignment: Alignment
    let content: (CGFloat) -> Content

    init(alignment: Alignment = .center, content: @escaping (CGFloat) -> Content) {
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        content(height)
            .frame(maxHeight: .infinity, alignment: alignment)
            .background(GeometryReader { proxy in
                Color.clear.preference(key: ReaderKey.self, value: proxy.size.height)
            })
            .onPreferenceChange(ReaderKey.self) { height = $0 }
    }
}

extension CGSize {
    var area: CGFloat {
        width * height
    }
}

private struct SizeReaderKey: PreferenceKey {
    // GeometryReader uses a default value of 10.
    static var defaultValue: CGSize { .init(width: 10, height: 10) }

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        if next.area > value.area {
            value = next
        }
    }
}

struct SizeReader<Content: View>: View {
    @State private var size: CGSize = SizeReaderKey.defaultValue
    let alignment: Alignment
    let content: (CGSize) -> Content

    init(alignment: Alignment = .center, content: @escaping (CGSize) -> Content) {
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        content(size)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .background(GeometryReader {
                Color.clear.preference(key: SizeReaderKey.self, value: $0.size)
            })
            .onPreferenceChange(SizeReaderKey.self) { size = $0 }
    }
}
