ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: format format-check

format:
	swift format format --in-place --recursive "$(ROOT)/Sources/RegistryKit" "$(ROOT)/Sources/SwiftUIRegistryCLI" "$(ROOT)/Tests/RegistryKitTests"

format-check:
	swift format lint --strict --recursive "$(ROOT)/Sources/RegistryKit" "$(ROOT)/Sources/SwiftUIRegistryCLI" "$(ROOT)/Tests/RegistryKitTests"
