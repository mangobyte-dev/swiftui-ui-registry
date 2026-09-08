#if canImport(UIKit)
import CoreGraphics

/// Which registry item the surface is tuning: `item` is the selected item's
/// name, or `nil` for the whole theme, and `isSelecting` is the arming state
/// while the next tap picks an item.
public struct ItemSelection: Equatable, Sendable {
    public var item: String?
    public var isSelecting: Bool

    public init(item: String? = nil, isSelecting: Bool = false) {
        self.item = item
        self.isSelecting = isSelecting
    }

    /// The item under a tap, the innermost of the tagged frames that contain
    /// the point: a button inside a block is the button, not the block. Ties
    /// (equal areas) keep the first reported, which is the outer one in
    /// preference order, so an item that fills its container exactly still
    /// resolves to the container's child only when the child is smaller.
    public static func pick(_ frames: [(name: String, frame: CGRect)], at point: CGPoint) -> String? {
        frames
            .filter { $0.frame.contains(point) }
            .min { $0.frame.width * $0.frame.height < $1.frame.width * $1.frame.height }?
            .name
    }
}
#endif
