import Foundation

// OPML 2.0 Document Structure
struct OPMLDocument {
    var version: String
    var head: OPMLHead
    var body: OPMLBody

    init(version: String = "2.0", head: OPMLHead, body: OPMLBody) {
        self.version = version
        self.head = head
        self.body = body
    }
}

// OPML Head Element
struct OPMLHead {
    var title: String?
    var dateCreated: Date?
    var dateModified: Date?
    var ownerName: String?
    var ownerEmail: String?
    var ownerId: String?
    var docs: String?
    var expansionState: [Int]?
    var vertScrollState: Int?
    var windowTop: Int?
    var windowLeft: Int?
    var windowBottom: Int?
    var windowRight: Int?

    init(
        title: String? = nil,
        dateCreated: Date? = nil,
        dateModified: Date? = nil,
        ownerName: String? = nil,
        ownerEmail: String? = nil,
        ownerId: String? = nil,
        docs: String? = nil,
        expansionState: [Int]? = nil,
        vertScrollState: Int? = nil,
        windowTop: Int? = nil,
        windowLeft: Int? = nil,
        windowBottom: Int? = nil,
        windowRight: Int? = nil
    ) {
        self.title = title
        self.dateCreated = dateCreated ?? Date()
        self.dateModified = dateModified ?? Date()
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.ownerId = ownerId
        self.docs = docs
        self.expansionState = expansionState
        self.vertScrollState = vertScrollState
        self.windowTop = windowTop
        self.windowLeft = windowLeft
        self.windowBottom = windowBottom
        self.windowRight = windowRight
    }
}

// OPML Body Element
struct OPMLBody {
    var outlines: [OPMLOutline]

    init(outlines: [OPMLOutline] = []) {
        self.outlines = outlines
    }
}

// OPML Outline Element
struct OPMLOutline {
    var attributes: [String: String]
    var children: [OPMLOutline]

    init(attributes: [String: String] = [:], children: [OPMLOutline] = []) {
        self.attributes = attributes
        self.children = children
    }

    // Common attribute accessors
    var text: String? {
        get { attributes["text"] }
        set { attributes["text"] = newValue }
    }

    var type: String? {
        get { attributes["type"] }
        set { attributes["type"] = newValue }
    }

    var isComment: Bool {
        get { attributes["isComment"] == "true" }
        set { attributes["isComment"] = newValue ? "true" : "false" }
    }

    var isBreakpoint: Bool {
        get { attributes["isBreakpoint"] == "true" }
        set { attributes["isBreakpoint"] = newValue ? "true" : "false" }
    }

    var created: Date? {
        get {
            guard let dateString = attributes["created"] else { return nil }
            return OPMLDateFormatter.shared.date(from: dateString)
        }
        set {
            if let date = newValue {
                attributes["created"] = OPMLDateFormatter.shared.string(from: date)
            } else {
                attributes.removeValue(forKey: "created")
            }
        }
    }
}

// OPML Date Formatter (RFC 822)
class OPMLDateFormatter {
    static let shared = OPMLDateFormatter()

    private let dateFormatter: DateFormatter
    private let iso8601Formatter: ISO8601DateFormatter

    private init() {
        // RFC 822 format
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        // ISO 8601 fallback
        iso8601Formatter = ISO8601DateFormatter()
    }

    func string(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    func date(from string: String) -> Date? {
        // Try RFC 822 first
        if let date = dateFormatter.date(from: string) {
            return date
        }
        // Try ISO 8601 as fallback
        return iso8601Formatter.date(from: string)
    }
}
