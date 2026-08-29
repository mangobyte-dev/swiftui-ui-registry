import SwiftUIRegistryFoundations
import Testing

struct RegistryThemeTests {
    @Test func `Default metrics preserve the registry composition contract`() {
        let metrics = RegistryMetrics()

        #expect(metrics.compactSpacing == 8)
        #expect(metrics.standardSpacing == 16)
        #expect(metrics.sectionSpacing == 24)
        #expect(metrics.cardRadius == 16)
    }

    @Test func `A consumer can replace metrics without shared mutable state`() {
        var compact = RegistryTheme()
        compact.metrics = RegistryMetrics(
            compactSpacing: 4,
            standardSpacing: 12,
            sectionSpacing: 20,
            cardRadius: 12
        )
        let standard = RegistryTheme()

        #expect(compact.metrics.cardRadius == 12)
        #expect(standard.metrics.cardRadius == 16)
    }
}
