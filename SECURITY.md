# Security policy

## Reporting a vulnerability

Report suspected vulnerabilities privately through [GitHub Security Advisories](https://github.com/mangobyte-dev/swiftui-ui-registry/security/advisories/new). Do not open a public issue. Include reproduction steps, the affected files or commands, the impact, and any suggested fix

You will get an acknowledgement within 7 days and a fix or a decision within 30 days. Coordinated disclosure is welcome once a fix has shipped

## Supported versions

The latest release tag (`0.3.0`) and the `main` branch are supported. Earlier tags (`0.1.0`, `0.2.0`) are not

## What is in scope

- The installer and its update path (`swiftui-registry install`, `Sources/RegistryKit/Installer.swift`): path traversal, symlink escapes, receipt tampering, and anything that lets a registry item write outside the chosen destination
- The validator, search, preset, MCP, and generator commands of the `swiftui-registry` tool under `Sources/`
- Registry source under `Registry/sources/` that could compromise a consuming app
- The website under `Website/` and its deployment configuration
- The Showcase app and its UI tests

## How the project defends itself

- Registry items are plain Swift source copied by a tool that refuses unsafe paths and never edits project files; consumers review the source they install
- Every commit is scanned for secrets with gitleaks before it is pushed; the history contains none
- Website dependencies are audited with `npm audit` and updated by Dependabot; the site is a static export with no server code, served with restrictive security headers
- Workflows run with read-only tokens and pin every action to a commit hash

## Out of scope

- Vulnerabilities in Apple frameworks, Xcode, Python, Node, or third-party packages that are not exploitable through this repository
- Findings that require a compromised developer machine or a modified clone
