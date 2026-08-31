import SwiftUIRegistryFoundations
import Testing

struct RegistryThemeTests {
    @Test func `Default metrics preserve the registry composition contract`() {
        let metrics = RegistryMetrics()

        #expect(metrics.compactSpacing == 8)
        #expect(metrics.standardSpacing == 16)
        #expect(metrics.sectionSpacing == 24)
        #expect(metrics.controlHorizontalPadding == 12)
        #expect(metrics.borderWidth == 1)
        #expect(metrics.emphasizedBorderWidth == 2)
        #expect(metrics.controlRadius == 8)
        #expect(metrics.cardRadius == 16)
        #expect(RegistryMetrics.minimumHitSize == 44)
    }

    @Test func `A consumer can replace metrics without shared mutable state`() {
        var compact = RegistryTheme(disabledOpacity: 0.4)
        compact.metrics = RegistryMetrics(
            compactSpacing: 4,
            standardSpacing: 12,
            sectionSpacing: 20,
            controlHorizontalPadding: 10,
            borderWidth: 0.5,
            emphasizedBorderWidth: 1.5,
            controlRadius: 6,
            cardRadius: 12
        )
        let standard = RegistryTheme()

        #expect(compact.disabledOpacity == 0.4)
        #expect(compact.metrics.controlHorizontalPadding == 10)
        #expect(compact.metrics.borderWidth == 0.5)
        #expect(compact.metrics.emphasizedBorderWidth == 1.5)
        #expect(compact.metrics.controlRadius == 6)
        #expect(compact.metrics.cardRadius == 12)
        #expect(standard.disabledOpacity == 0.5)
        #expect(standard.metrics.controlHorizontalPadding == 12)
        #expect(standard.metrics.borderWidth == 1)
        #expect(standard.metrics.emphasizedBorderWidth == 2)
        #expect(standard.metrics.controlRadius == 8)
        #expect(standard.metrics.cardRadius == 16)
    }
}
