import Foundation
import SwiftData

@Model
final class MindMapNode {
    var id: UUID
    var text: String
    var x: Double
    var y: Double
    var createdAt: Date
    var modifiedAt: Date

    // Relationships
    var parent: MindMapNode?
    @Relationship(deleteRule: .cascade, inverse: \MindMapNode.parent)
    var children: [MindMapNode]

    // Visual properties
    var colorHex: String?
    var fontSize: Double
    var isCollapsed: Bool

    // OPML attributes
    var opmlAttributes: [String: String]

    init(
        text: String,
        position: CGPoint,
        parent: MindMapNode? = nil,
        colorHex: String? = nil,
        fontSize: Double = 14.0
    ) {
        self.id = UUID()
        self.text = text
        self.x = position.x
        self.y = position.y
        self.parent = parent
        self.children = []
        self.colorHex = colorHex
        self.fontSize = fontSize
        self.isCollapsed = false
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.opmlAttributes = [:]
    }

    var position: CGPoint {
        get { CGPoint(x: x, y: y) }
        set {
            x = newValue.x
            y = newValue.y
            modifiedAt = Date()
        }
    }

    func addChild(_ child: MindMapNode) {
        children.append(child)
        child.parent = self
        modifiedAt = Date()
    }

    func removeChild(_ child: MindMapNode) {
        children.removeAll { $0.id == child.id }
        modifiedAt = Date()
    }

    // OPML 변환을 위한 메서드
    func toOPMLOutline() -> OPMLOutline {
        var attributes = opmlAttributes
        attributes["text"] = text
        attributes["_position_x"] = String(x)
        attributes["_position_y"] = String(y)
        if let color = colorHex {
            attributes["_color"] = color
        }
        attributes["_fontSize"] = String(fontSize)
        attributes["_collapsed"] = String(isCollapsed)

        return OPMLOutline(
            attributes: attributes,
            children: children.map { $0.toOPMLOutline() }
        )
    }

    static func fromOPMLOutline(_ outline: OPMLOutline, parent: MindMapNode? = nil) -> MindMapNode {
        let text = outline.attributes["text"] ?? "Untitled"
        let x = Double(outline.attributes["_position_x"] ?? "0") ?? 0
        let y = Double(outline.attributes["_position_y"] ?? "0") ?? 0
        let colorHex = outline.attributes["_color"]
        let fontSize = Double(outline.attributes["_fontSize"] ?? "14") ?? 14

        let node = MindMapNode(
            text: text,
            position: CGPoint(x: x, y: y),
            parent: parent,
            colorHex: colorHex,
            fontSize: fontSize
        )

        if let collapsed = outline.attributes["_collapsed"] {
            node.isCollapsed = collapsed == "true"
        }

        // OPML 속성 저장 (커스텀 속성 제외)
        var opmlAttrs = outline.attributes
        opmlAttrs.removeValue(forKey: "text")
        opmlAttrs.removeValue(forKey: "_position_x")
        opmlAttrs.removeValue(forKey: "_position_y")
        opmlAttrs.removeValue(forKey: "_color")
        opmlAttrs.removeValue(forKey: "_fontSize")
        opmlAttrs.removeValue(forKey: "_collapsed")
        node.opmlAttributes = opmlAttrs

        // 자식 노드 처리
        for childOutline in outline.children {
            let child = MindMapNode.fromOPMLOutline(childOutline, parent: node)
            node.children.append(child)
        }

        return node
    }
}

// CGPoint extension for convenience
extension CGPoint {
    static var zero: CGPoint {
        CGPoint(x: 0, y: 0)
    }
}
