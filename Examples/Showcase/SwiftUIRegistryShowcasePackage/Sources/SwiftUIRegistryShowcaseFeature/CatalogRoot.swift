import SwiftUI
import SwiftUIRegistryFoundations

/// The browsable catalog: one tab per item kind, with the tuning panel kept
/// beside it rather than on a tab of its own: a trailing column on a regular
/// width and, on iPhone, a sheet the catalog stays interactive under, plus
/// the accent strip above the tab bar. The tuned theme is applied once here,
/// so every screen below inherits it, which is exactly how a consuming app
/// adopts the registry.
///
/// The column is a plain sibling, not `inspector(isPresented:)`: measured on
/// iOS 27, that modifier on the tab's navigation stack stopped the auth
/// form's Return key from moving focus even while nothing was presented.
struct CatalogRoot: View {
    let arguments: LaunchArguments
    @State private var tuning: ThemeTuning
    @State private var isTuning = false
    @Environment(\.horizontalSizeClass) private var sizeClass

    init(arguments: LaunchArguments) {
        self.arguments = arguments
        _tuning = State(initialValue: ThemeTuning.initial(for: arguments))
    }

    var body: some View {
        HStack(spacing: 0) {
            TabView {
                Tab("Components", systemImage: "square.grid.2x2") {
                    CatalogList(kind: "component", title: "Components")
                }
                Tab("Blocks", systemImage: "rectangle.3.group") {
                    CatalogList(kind: "block", title: "Blocks")
                }
                Tab("Recipes", systemImage: "text.book.closed") {
                    CatalogList(kind: "recipe", title: "Recipes")
                }
            }
            .tabViewBottomAccessory {
                TuningAccessory(tuning: $tuning, isTuning: $isTuning)
            }
            .sheet(isPresented: sizeClass == .compact ? $isTuning : .constant(false)) {
                TuningPanel(tuning: $tuning)
                    .presentationDetents([.medium, .large])
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            }
            if sizeClass == .regular && isTuning {
                Divider()
                TuningPanel(tuning: $tuning)
                    .frame(width: 380)
                    .transition(.move(edge: .trailing))
            }
        }
        .registryTheme(tuning.theme)
        .preferredColorScheme(tuning.preferredColorScheme)
        .transformEnvironment(\.layoutDirection) { direction in
            if tuning.rightToLeft { direction = .rightToLeft }
        }
        .transformEnvironment(\.dynamicTypeSize) { size in
            if let tuned = tuning.dynamicTypeSize { size = tuned }
        }
        .onChange(of: tuning) { _, updated in
            updated.persist()
        }
    }
}

/// One kind of item as a searchable list that pushes the item's detail.
struct CatalogList: View {
    let kind: String
    let title: String

    @State private var query = ""

    private var entries: [CatalogEntry] {
        let all = RegistryCatalogManifest.entries(ofKind: kind)
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return all }
        return all.filter { entry in
            entry.name.localizedCaseInsensitiveContains(trimmed)
                || entry.description.localizedCaseInsensitiveContains(trimmed)
                || entry.tags.contains { $0.localizedCaseInsensitiveContains(trimmed) }
        }
    }

    var body: some View {
        NavigationStack {
            List(entries) { entry in
                NavigationLink(value: entry) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.name)
                            .font(.body.weight(.semibold))
                        Text(entry.description)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 2)
                }
                .accessibilityIdentifier("catalog.item.\(entry.name)")
            }
            .navigationTitle(title)
            .navigationDestination(for: CatalogEntry.self) { entry in
                ItemDetailScreen(entry: entry)
            }
            .searchable(text: $query, prompt: "Search \(title.lowercased())")
        }
    }
}

/// Description, live demo, install command, usage snippet, and details for one item.
struct ItemDetailScreen: View {
    let entry: CatalogEntry
    @Environment(\.registryTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.metrics.sectionSpacing) {
                Text(entry.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ItemDemoView(name: entry.name)

                if entry.kind == "recipe" {
                    Text("Nothing to install. Copy the snippet.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    DetailSection("Install") {
                        CodeBlock(
                            "swiftui-registry install \(entry.name) --destination Sources/YourFeature/Components"
                        )
                    }
                }

                DetailSection("Usage") {
                    CodeBlock(entry.usage)
                }

                DetailSection("Details") {
                    VStack(alignment: .leading, spacing: theme.metrics.compactSpacing) {
                        LabeledContent("Kind", value: entry.kind)
                        LabeledContent("Version", value: entry.version)
                        LabeledContent(
                            "Dependencies",
                            value: entry.dependencies.isEmpty ? "none" : entry.dependencies.joined(separator: ", ")
                        )
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: 792)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailSection<Content: View>: View {
    @Environment(\.registryTheme) private var theme
    let title: LocalizedStringResource
    let content: Content

    init(_ title: LocalizedStringResource, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.compactSpacing) {
            Text(title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            content
        }
    }
}

/// Monospaced code on the registry surface with a copy action.
struct CodeBlock: View {
    @Environment(\.registryTheme) private var theme
    let code: String

    init(_ code: String) {
        self.code = code
    }

    var body: some View {
        // Wrapping text, not a horizontal scroll view: long lines wrap at
        // large text sizes, and a hosted scroll view inside a pushed screen
        // crashed with NaN bounds under right-to-left plus accessibility size.
        Text(code)
            .font(.footnote.monospaced())
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.metrics.standardSpacing)
            .padding(.trailing, 40)
            .registrySurface()
        .overlay(alignment: .topTrailing) {
            CopyButton("Copy code", text: code)
                .labelStyle(.iconOnly)
                .buttonStyle(.registryGhost)
                .controlSize(.small)
                .background(.regularMaterial, in: Circle())
                .padding(theme.metrics.compactSpacing / 2)
        }
    }
}

/// Renders the demo registered for an item, or a loud placeholder the UI
/// tests assert never appears.
struct ItemDemoView: View {
    let name: String

    var body: some View {
        if let demo = ItemDemos.demo(for: name) {
            demo
        } else {
            ContentUnavailableView(
                "No demo for \(name)",
                systemImage: "exclamationmark.triangle",
                description: Text("Register one in ItemDemos.swift.")
            )
            .registryEmptyState()
        }
    }
}
