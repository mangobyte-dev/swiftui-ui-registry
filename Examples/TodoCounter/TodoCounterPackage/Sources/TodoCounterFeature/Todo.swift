import Foundation

/// One task. The feature owns the value; the view only renders it.
public struct Todo: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var isDone: Bool

    public init(id: UUID, title: String, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
}
