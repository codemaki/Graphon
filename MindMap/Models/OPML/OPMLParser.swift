import Foundation

class OPMLParser: NSObject {
    private var document: OPMLDocument?
    private var currentElement: String = ""
    private var currentOutlineStack: [OPMLOutline] = []
    private var headElements: [String: String] = [:]

    func parse(data: Data) throws -> OPMLDocument {
        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse() else {
            throw OPMLError.parsingFailed(parser.parserError?.localizedDescription ?? "Unknown error")
        }

        guard let document = document else {
            throw OPMLError.invalidDocument
        }

        return document
    }

    func parse(string: String) throws -> OPMLDocument {
        guard let data = string.data(using: .utf8) else {
            throw OPMLError.invalidEncoding
        }
        return try parse(data: data)
    }
}

extension OPMLParser: XMLParserDelegate {
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName

        switch elementName {
        case "opml":
            let version = attributeDict["version"] ?? "2.0"
            document = OPMLDocument(
                version: version,
                head: OPMLHead(),
                body: OPMLBody()
            )

        case "outline":
            let outline = OPMLOutline(attributes: attributeDict, children: [])
            currentOutlineStack.append(outline)

        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Head 요소 내용 저장
        switch currentElement {
        case "title", "dateCreated", "dateModified", "ownerName", "ownerEmail",
             "ownerId", "docs", "expansionState", "vertScrollState",
             "windowTop", "windowLeft", "windowBottom", "windowRight":
            headElements[currentElement] = (headElements[currentElement] ?? "") + trimmed
        default:
            break
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        switch elementName {
        case "head":
            // Head 요소 파싱 완료
            if document != nil {
                document!.head = parseHead(from: headElements)
            }

        case "outline":
            guard let outline = currentOutlineStack.popLast() else { return }

            if currentOutlineStack.isEmpty {
                // Root outline
                document?.body.outlines.append(outline)
            } else {
                // Child outline
                var parent = currentOutlineStack.removeLast()
                parent.children.append(outline)
                currentOutlineStack.append(parent)
            }

        default:
            break
        }

        currentElement = ""
    }

    private func parseHead(from elements: [String: String]) -> OPMLHead {
        let dateFormatter = OPMLDateFormatter.shared

        return OPMLHead(
            title: elements["title"],
            dateCreated: elements["dateCreated"].flatMap { dateFormatter.date(from: $0) },
            dateModified: elements["dateModified"].flatMap { dateFormatter.date(from: $0) },
            ownerName: elements["ownerName"],
            ownerEmail: elements["ownerEmail"],
            ownerId: elements["ownerId"],
            docs: elements["docs"],
            expansionState: elements["expansionState"].flatMap { parseExpansionState($0) },
            vertScrollState: elements["vertScrollState"].flatMap { Int($0) },
            windowTop: elements["windowTop"].flatMap { Int($0) },
            windowLeft: elements["windowLeft"].flatMap { Int($0) },
            windowBottom: elements["windowBottom"].flatMap { Int($0) },
            windowRight: elements["windowRight"].flatMap { Int($0) }
        )
    }

    private func parseExpansionState(_ string: String) -> [Int]? {
        let components = string.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        return components.isEmpty ? nil : components
    }
}

// OPML Errors
enum OPMLError: LocalizedError {
    case parsingFailed(String)
    case invalidDocument
    case invalidEncoding

    var errorDescription: String? {
        switch self {
        case .parsingFailed(let message):
            return "OPML parsing failed: \(message)"
        case .invalidDocument:
            return "Invalid OPML document structure"
        case .invalidEncoding:
            return "Invalid text encoding"
        }
    }
}
