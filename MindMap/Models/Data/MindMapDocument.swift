import SwiftUI
import UniformTypeIdentifiers

struct MindMapDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.opml] }

    var opmlDocument: OPMLDocument

    init() {
        self.opmlDocument = OPMLDocument(
            head: OPMLHead(title: "New Mind Map"),
            body: OPMLBody(outlines: [])
        )
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let parser = OPMLParser()
        self.opmlDocument = try parser.parse(data: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let generator = OPMLGenerator()
        let xmlString = generator.generate(from: opmlDocument)

        guard let data = xmlString.data(using: .utf8) else {
            throw CocoaError(.fileWriteUnknown)
        }

        return FileWrapper(regularFileWithContents: data)
    }
}
