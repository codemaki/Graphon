import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct MindMapApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MindMapNode.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        print("🗄️ ModelContainer initialized (CloudKit enabled)")

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MindMapRootView()
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .importExport) {
                Button("Open OPML...") {
                    // 툴바 버튼을 통해 처리
                }
                .keyboardShortcut("o", modifiers: [.command])

                Button("Save OPML...") {
                    // 툴바 버튼을 통해 처리
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
        }
    }
}

// Document를 State로 관리하는 래퍼 뷰
struct MindMapRootView: View {
    @State private var document = MindMapDocument()

    var body: some View {
        ContentView(document: $document)
    }
}

// OPML 파일 타입 정의
extension UTType {
    static var opml: UTType {
        UTType(importedAs: "org.opml.opml")
    }
}
