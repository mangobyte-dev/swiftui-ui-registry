# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Stack

Swift 6.2 package sources compiled with the installed Xcode 27 toolchain, with iOS 18 as the deployment floor

## Users

Inferred: professional Apple-platform developers and coding agents composing product-quality SwiftUI screens inside existing app architectures

## Product Purpose

Test whether native-first, source-owned product UI can be discovered through a registry, copied into an app, customized, and compiled without adopting an application architecture

## Positioning

The project owns product-level composition and distribution. It leaves controls, navigation, platform adaptation, state management, and persistence to SwiftUI and the consuming app

## Capabilities and Constraints

- Version 0 is iOS and iPadOS focused
- Shared foundations may remain a narrow Swift package
- Product components and blocks are source-owned registry items
- No mandatory state-management, persistence, backend, or third-party UI dependency
- Registry metadata must remain useful without an MCP server or proprietary service
- Discovery and update decisions must remain deterministic and inspectable

## Evidence on Hand

The finance and nutrition showcases, installer tests, search tests, iOS 18 UI tests, and current-runtime screenshots provide version-0 evidence. No brand assets, user research, or production app data were supplied, so examples use clearly illustrative content

## Product Principles

- Native SwiftUI first
- Progressive adoption
- Source ownership above stable foundations
- Architecture-neutral inputs and actions
- Compile-verified, accessible, and agent-legible artifacts

## Accessibility & Inclusion

Dynamic Type, VoiceOver semantics, semantic color, Reduce Motion compatibility, localization, and right-to-left layout are design requirements. Version 0 has runtime Dynamic Type, right-to-left layout, and semantic accessibility evidence; physical-device assistive-technology testing remains outside the current evidence
