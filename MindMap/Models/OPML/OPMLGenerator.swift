import Foundation

class OPMLGenerator {
    private let dateFormatter = OPMLDateFormatter.shared
    private var indentLevel = 0
    private let indentString = "  "

    func generate(from document: OPMLDocument) -> String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<opml version=\"\(document.version)\">\n"

        // Head
        xml += generateHead(document.head)

        // Body
        xml += generateBody(document.body)

        xml += "</opml>"
        return xml
    }

    private func generateHead(_ head: OPMLHead) -> String {
        var xml = indent() + "<head>\n"
        indentLevel += 1

        if let title = head.title {
            xml += indent() + "<title>\(escapeXML(title))</title>\n"
        }
        if let dateCreated = head.dateCreated {
            xml += indent() + "<dateCreated>\(dateFormatter.string(from: dateCreated))</dateCreated>\n"
        }
        if let dateModified = head.dateModified {
            xml += indent() + "<dateModified>\(dateFormatter.string(from: dateModified))</dateModified>\n"
        }
        if let ownerName = head.ownerName {
            xml += indent() + "<ownerName>\(escapeXML(ownerName))</ownerName>\n"
        }
        if let ownerEmail = head.ownerEmail {
            xml += indent() + "<ownerEmail>\(escapeXML(ownerEmail))</ownerEmail>\n"
        }
        if let ownerId = head.ownerId {
            xml += indent() + "<ownerId>\(escapeXML(ownerId))</ownerId>\n"
        }
        if let docs = head.docs {
            xml += indent() + "<docs>\(escapeXML(docs))</docs>\n"
        }
        if let expansionState = head.expansionState {
            let stateString = expansionState.map { String($0) }.joined(separator: ", ")
            xml += indent() + "<expansionState>\(stateString)</expansionState>\n"
        }
        if let vertScrollState = head.vertScrollState {
            xml += indent() + "<vertScrollState>\(vertScrollState)</vertScrollState>\n"
        }
        if let windowTop = head.windowTop {
            xml += indent() + "<windowTop>\(windowTop)</windowTop>\n"
        }
        if let windowLeft = head.windowLeft {
            xml += indent() + "<windowLeft>\(windowLeft)</windowLeft>\n"
        }
        if let windowBottom = head.windowBottom {
            xml += indent() + "<windowBottom>\(windowBottom)</windowBottom>\n"
        }
        if let windowRight = head.windowRight {
            xml += indent() + "<windowRight>\(windowRight)</windowRight>\n"
        }

        indentLevel -= 1
        xml += indent() + "</head>\n"
        return xml
    }

    private func generateBody(_ body: OPMLBody) -> String {
        var xml = indent() + "<body>\n"
        indentLevel += 1

        for outline in body.outlines {
            xml += generateOutline(outline)
        }

        indentLevel -= 1
        xml += indent() + "</body>\n"
        return xml
    }

    private func generateOutline(_ outline: OPMLOutline) -> String {
        let hasChildren = !outline.children.isEmpty

        var xml = indent() + "<outline"

        // Sort attributes for consistent output (text first, then others alphabetically)
        let sortedAttributes = outline.attributes.sorted { a, b in
            if a.key == "text" { return true }
            if b.key == "text" { return false }
            return a.key < b.key
        }

        for (key, value) in sortedAttributes {
            xml += " \(key)=\"\(escapeXML(value))\""
        }

        if hasChildren {
            xml += ">\n"
            indentLevel += 1

            for child in outline.children {
                xml += generateOutline(child)
            }

            indentLevel -= 1
            xml += indent() + "</outline>\n"
        } else {
            xml += " />\n"
        }

        return xml
    }

    private func indent() -> String {
        String(repeating: indentString, count: indentLevel)
    }

    private func escapeXML(_ string: String) -> String {
        var result = string
        result = result.replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        result = result.replacingOccurrences(of: "'", with: "&apos;")
        return result
    }
}
