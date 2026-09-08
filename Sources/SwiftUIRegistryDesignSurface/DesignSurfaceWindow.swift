#if canImport(UIKit)
import Sharing
import SwiftUI
import SwiftUIRegistryFoundations
import UIKit

/// The tool's own window above the app: transparent, at the alert level so it
/// covers every tab, sheet, and cover, and taking only the touches that land
/// on its button or its panel. Everything else falls through to the app, so
/// the app stays live while a knob moves. The shape is seeFood's Design mode
/// (its ADR 0015), ported here in Stage 9.
@MainActor
final class DesignSurfaceWindow {
    static let shared = DesignSurfaceWindow()

    private var window: PassthroughWindow?
    /// The window's touchable regions in window points; a touch anywhere else
    /// reaches the app.
    var hitRects: [String: CGRect] = [:]

    private init() {}

    /// Installs the window over the first connected scene, once.
    func install() {
        guard window == nil,
              let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        else { return }
        let window = PassthroughWindow(windowScene: scene)
        // Above the alert level: the Liquid Glass tab bar sat over the card at
        // `.alert + 1` on iOS 27 (measured on the iPhone 17 simulator).
        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue + 100)
        window.backgroundColor = .clear
        let host = UIHostingController(rootView: DesignSurfaceOverlayRoot())
        host.view.backgroundColor = .clear
        window.rootViewController = host
        window.isHidden = false
        self.window = window
    }

    /// The overlay takes the key window while the panel is up, so its text
    /// fields receive the keyboard; the app's window gets it back on close.
    func setKey(_ key: Bool) {
        guard let window else { return }
        if key {
            window.makeKey()
        } else if let app = window.windowScene?.windows.first(where: { $0 !== window }) {
            app.makeKey()
        }
    }
}

/// A window whose hosting view claims every point, so hit testing is decided
/// here by the named regions instead.
private final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // A sheet the panel presents (Import) owns the whole window while it
        // is up; otherwise only the named regions take touches.
        if rootViewController?.presentedViewController != nil {
            return super.hitTest(point, with: event)
        }
        let rects = DesignSurfaceWindow.shared.hitRects
        guard rects.values.contains(where: { $0.contains(point) }) else { return nil }
        return super.hitTest(point, with: event)
    }
}

extension View {
    /// Names a region of the overlay that takes touches; its frame in the
    /// window is reported as it changes.
    func designSurfaceHitRegion(_ name: String) -> some View {
        onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { frame in
            DesignSurfaceWindow.shared.hitRects[name] = frame
        }
        .onDisappear {
            DesignSurfaceWindow.shared.hitRects[name] = nil
        }
    }
}

/// The overlay's content: the floating button, and the panel card while it
/// is up. Reads the tuned theme so its chrome follows the knobs.
private struct DesignSurfaceOverlayRoot: View {
    @Shared(.designTokens) private var tuning
    private let state = DesignSurfaceState.shared

    var body: some View {
        ZStack {
            // While Select is armed the card steps aside so every item on
            // the screen is tappable; it returns with the scope once picked.
            if state.isPresented && !state.selection.isSelecting {
                FloatingPanel {
                    TuningPanel(tuning: Binding($tuning), selection: selectionBinding) {
                        if let footer = state.presetsFooter { footer }
                    }
                }
            }
            if !state.hostOwnsTrigger {
                FloatingTuneButton()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .registryTheme(tuning.theme)
        .preferredColorScheme(tuning.preferredColorScheme)
        .onChange(of: state.isPresented) { _, presented in
            DesignSurfaceWindow.shared.setKey(presented)
            if !presented { DesignSurfaceWindow.shared.hitRects["panel"] = nil }
        }
    }

    private var selectionBinding: Binding<ItemSelection> {
        Binding(get: { state.selection }, set: { state.selection = $0 })
    }
}

/// The draggable button that opens the panel. It settles to the nearer side
/// after a drag and remembers its place.
private struct FloatingTuneButton: View {
    private let state = DesignSurfaceState.shared
    @AppStorage("designSurface.button.y") private var restingY = 0.72
    @AppStorage("designSurface.button.trailing") private var restingTrailing = true
    @State private var drag: CGSize = .zero
    @Environment(\.registryTheme) private var theme

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let inset: CGFloat = 20
            let diameter: CGFloat = 52
            let restX = restingTrailing ? size.width - inset - diameter / 2 : inset + diameter / 2
            let restY = min(max(restingY, 0.1), 0.9) * size.height
            Button {
                withAnimation(.snappy) { state.isPresented.toggle() }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3.weight(.semibold))
                    .frame(width: diameter, height: diameter)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Circle())
            .accessibilityLabel("Tune")
            .accessibilityIdentifier("designSurface.button")
            .shadow(radius: 8, y: 4)
            // Measured on the button itself: after `position` the view fills
            // the window, and a full-window region would swallow every touch.
            .designSurfaceHitRegion("button")
            .position(x: restX + drag.width, y: restY + drag.height)
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { drag = $0.translation }
                    .onEnded { value in
                        let x = restX + value.translation.width
                        let y = restY + value.translation.height
                        withAnimation(.snappy) {
                            restingTrailing = x > size.width / 2
                            restingY = Double(min(max(y / size.height, 0.1), 0.9))
                            drag = .zero
                        }
                    }
            )
        }
    }
}

private enum PanelMetrics {
    static let minimumSize = CGSize(width: 300, height: 260)
    static let columnWidth: CGFloat = 380
    static let snapDistance: CGFloat = 24
}

/// The panel as a floating card: a drag bar moves it, a corner grip resizes
/// it, a chevron collapses it to the button, and dragging it against the
/// trailing edge snaps it into a full-height side column. Its frame is
/// remembered per size class.
private struct FloatingPanel<Content: View>: View {
    @ViewBuilder let content: Content
    private let state = DesignSurfaceState.shared
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.registryTheme) private var theme
    @AppStorage("designSurface.panel.compact") private var compactFrame = ""
    @AppStorage("designSurface.panel.regular") private var regularFrame = ""
    @State private var frame: CGRect = .zero
    @State private var moveStart: CGPoint?
    @State private var sizeStart: CGSize?

    var body: some View {
        GeometryReader { proxy in
            let bounds = proxy.frame(in: .local)
            let safe = proxy.safeAreaInsets
            let area = CGRect(
                x: safe.leading, y: safe.top,
                width: bounds.width - safe.leading - safe.trailing,
                height: bounds.height - safe.top - safe.bottom)
            let current = frame == .zero ? defaultFrame(in: area) : frame
            VStack(spacing: 0) {
                dragBar(area: area, current: current)
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: theme.metrics.cardRadius, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: theme.metrics.cardRadius, style: .continuous))
            .overlay(alignment: .bottomTrailing) { grip(area: area, current: current) }
            .shadow(radius: 16, y: 8)
            .frame(width: current.width, height: current.height)
            .designSurfaceHitRegion("panel")
            .position(x: current.midX, y: current.midY)
            .onAppear {
                if frame == .zero { frame = restored(in: area) ?? defaultFrame(in: area) }
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    private func dragBar(area: CGRect, current: CGRect) -> some View {
        HStack {
            Capsule().fill(.secondary).frame(width: 36, height: 5)
            Spacer()
            Button {
                withAnimation(.snappy) { state.isPresented = false }
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Collapse the tuning panel")
        }
        .padding(.horizontal, theme.metrics.standardSpacing)
        .padding(.vertical, theme.metrics.compactSpacing)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 4, coordinateSpace: .global)
                .onChanged { value in
                    let start = moveStart ?? current.origin
                    moveStart = start
                    var moved = current
                    moved.origin = CGPoint(x: start.x + value.translation.width, y: start.y + value.translation.height)
                    frame = clamp(moved, in: area)
                }
                .onEnded { _ in
                    moveStart = nil
                    snapIfAtEdge(in: area)
                    remember()
                }
        )
    }

    private func grip(area: CGRect, current: CGRect) -> some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
            .padding(theme.metrics.compactSpacing)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("Resize the tuning panel")
            .gesture(
                DragGesture(minimumDistance: 4, coordinateSpace: .global)
                    .onChanged { value in
                        let start = sizeStart ?? current.size
                        sizeStart = start
                        var resized = current
                        resized.size = CGSize(
                            width: max(PanelMetrics.minimumSize.width, start.width + value.translation.width),
                            height: max(PanelMetrics.minimumSize.height, start.height + value.translation.height))
                        frame = clamp(resized, in: area)
                    }
                    .onEnded { _ in
                        sizeStart = nil
                        remember()
                    }
            )
    }

    private func defaultFrame(in area: CGRect) -> CGRect {
        if sizeClass == .regular {
            return CGRect(
                x: area.maxX - PanelMetrics.columnWidth, y: area.minY,
                width: PanelMetrics.columnWidth, height: area.height)
        }
        // Above the app's bottom bar by a tab bar's height, so the whole card
        // is reachable before the person moves it.
        let barAllowance: CGFloat = 92
        // Tall by default: the person shrinks it from the grip when the app
        // needs the room, and a taller card keeps a whole section in reach.
        let height = min(area.height * 0.72, 620)
        return CGRect(
            x: area.minX, y: area.maxY - barAllowance - height,
            width: area.width, height: height)
    }

    private func clamp(_ rect: CGRect, in area: CGRect) -> CGRect {
        var result = rect
        result.size.width = min(max(PanelMetrics.minimumSize.width, result.width), area.width)
        result.size.height = min(max(PanelMetrics.minimumSize.height, result.height), area.height)
        result.origin.x = min(max(area.minX, result.origin.x), area.maxX - result.width)
        result.origin.y = min(max(area.minY, result.origin.y), area.maxY - result.height)
        return result
    }

    /// Dragged against the trailing edge, the card becomes the side column.
    private func snapIfAtEdge(in area: CGRect) {
        guard area.maxX - frame.maxX < PanelMetrics.snapDistance, area.width > PanelMetrics.columnWidth * 1.5 else { return }
        withAnimation(.snappy) {
            frame = CGRect(
                x: area.maxX - PanelMetrics.columnWidth, y: area.minY,
                width: PanelMetrics.columnWidth, height: area.height)
        }
    }

    private func remember() {
        let text = [frame.minX, frame.minY, frame.width, frame.height].map { String(format: "%.1f", $0) }
            .joined(separator: ",")
        if sizeClass == .regular { regularFrame = text } else { compactFrame = text }
    }

    private func restored(in area: CGRect) -> CGRect? {
        let text = sizeClass == .regular ? regularFrame : compactFrame
        let parts = text.split(separator: ",").compactMap { Double($0) }
        guard parts.count == 4 else { return nil }
        return clamp(CGRect(x: parts[0], y: parts[1], width: parts[2], height: parts[3]), in: area)
    }
}
#endif
