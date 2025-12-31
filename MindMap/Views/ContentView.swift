import SwiftUI
import SwiftData

struct ContentView: View {
    @Binding var document: MindMapDocument
    @Environment(\.modelContext) private var modelContext
    @Query private var nodes: [MindMapNode]

    @State private var selectedNode: MindMapNode?
    @State private var viewportOffset: CGSize = .zero
    @State private var viewportScale: CGFloat = 1.0
    @State private var isInitialized = false

    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var syncTask: Task<Void, Never>?

    var body: some View {
        let _ = print("🔄 ContentView.body called - nodes: \(nodes.count), selected: \(selectedNode?.text ?? "nil")")

        GeometryReader { geometry in
            ZStack {
                // Background
                #if os(macOS)
                Color(nsColor: .controlBackgroundColor)
                    .ignoresSafeArea()
                #else
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                #endif

                // Mind Map Canvas
                MindMapCanvasView(
                    nodes: nodes,
                    selectedNode: $selectedNode,
                    offset: $viewportOffset,
                    scale: $viewportScale
                )
            }
            .toolbar {
                ToolbarItemGroup {
                    Button(action: addRootNode) {
                        Label("Add Root Node", systemImage: "plus.circle")
                    }

                    Button(action: addChildNode) {
                        Label("Add Child", systemImage: "arrow.down.circle")
                    }
                    .disabled(selectedNode == nil)

                    Divider()

                    Button(action: zoomIn) {
                        Label("Zoom In", systemImage: "plus.magnifyingglass")
                    }

                    Button(action: zoomOut) {
                        Label("Zoom Out", systemImage: "minus.magnifyingglass")
                    }

                    Button(action: resetView) {
                        Label("Reset View", systemImage: "arrow.counterclockwise")
                    }

                    Divider()

                    Button(action: { showingImporter = true }) {
                        Label("Open OPML", systemImage: "folder")
                    }

                    Button(action: {
                        syncToDocument()

                        // 디버그: 실제 저장될 내용 확인
                        let generator = OPMLGenerator()
                        let xml = generator.generate(from: document.opmlDocument)
                        print("💾 Saving XML:")
                        print(xml)

                        showingExporter = true
                    }) {
                        Label("Save OPML", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .onAppear {
                loadFromDocument()
            }
            .onChange(of: nodes.count) { _, _ in
                // 노드 추가/삭제 시 자동 동기화 (debounced)
                if isInitialized {
                    debouncedSync()
                }
            }
            .fileExporter(
                isPresented: $showingExporter,
                document: document,
                contentType: .opml,
                defaultFilename: "MindMap.opml"
            ) { result in
                switch result {
                case .success(let url):
                    print("Saved to: \(url)")
                case .failure(let error):
                    print("Error saving: \(error)")
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.opml],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    loadFromURL(url)
                case .failure(let error):
                    print("Error loading: \(error)")
                }
            }
        }
    }

    private func addRootNode() {
        let newNode = MindMapNode(text: "New Idea", position: .zero)
        modelContext.insert(newNode)
        try? modelContext.save()
        debouncedSync()
    }

    private func addChildNode() {
        guard let parent = selectedNode else { return }
        let newNode = MindMapNode(
            text: "New Child",
            position: CGPoint(x: parent.x, y: parent.y + 100),
            parent: parent
        )
        modelContext.insert(newNode)
        try? modelContext.save()
        debouncedSync()
    }

    // Debounced sync to prevent excessive syncing
    private func debouncedSync() {
        syncTask?.cancel()
        syncTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초 대기
            if !Task.isCancelled {
                await MainActor.run {
                    syncToDocument()
                }
            }
        }
    }

    private func zoomIn() {
        viewportScale = min(viewportScale * 1.2, 3.0)
    }

    private func zoomOut() {
        viewportScale = max(viewportScale / 1.2, 0.3)
    }

    private func resetView() {
        viewportOffset = .zero
        viewportScale = 1.0
    }

    // OPML document에서 노드 로드
    private func loadFromDocument() {
        guard !isInitialized else { return }
        isInitialized = true

        // 기존 노드 모두 삭제
        for node in nodes {
            modelContext.delete(node)
        }

        // OPML document에서 노드 생성
        for outline in document.opmlDocument.body.outlines {
            let node = MindMapNode.fromOPMLOutline(outline)
            modelContext.insert(node)
        }

        try? modelContext.save()
    }

    // 노드들을 OPML document로 동기화
    private func syncToDocument() {
        // 루트 노드들만 가져오기 (parent가 nil인 노드)
        let rootNodes = nodes.filter { $0.parent == nil }

        print("🔄 Syncing to document: \(rootNodes.count) root nodes")

        // OPML outline으로 변환
        let outlines = rootNodes.map { $0.toOPMLOutline() }

        // Document 업데이트
        document.opmlDocument.body.outlines = outlines
        document.opmlDocument.head.dateModified = Date()

        if let title = document.opmlDocument.head.title {
            print("📄 Document title: \(title)")
        }
        print("📊 Outlines count: \(outlines.count)")

        try? modelContext.save()
    }

    // URL에서 OPML 파일 로드
    private func loadFromURL(_ url: URL) {
        do {
            // 파일 읽기 권한 요청
            guard url.startAccessingSecurityScopedResource() else {
                print("Could not access file")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            let data = try Data(contentsOf: url)
            let parser = OPMLParser()
            let loadedDocument = try parser.parse(data: data)

            // 기존 노드 모두 삭제
            for node in nodes {
                modelContext.delete(node)
            }

            // 새 document로 교체
            document.opmlDocument = loadedDocument

            // OPML document에서 노드 생성
            for outline in loadedDocument.body.outlines {
                let node = MindMapNode.fromOPMLOutline(outline)
                modelContext.insert(node)
            }

            try? modelContext.save()

        } catch {
            print("Error loading OPML: \(error)")
        }
    }
}

#Preview {
    @Previewable @State var document = MindMapDocument()
    ContentView(document: .constant(document))
        .modelContainer(for: MindMapNode.self, inMemory: true)
}
