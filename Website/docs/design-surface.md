# Design surface

The design surface is a tool for tuning a running app on the device. It ships as a second package product, `SwiftUIRegistryDesignSurface`, and puts its own window over your whole app: a draggable Tune button, and a floating, movable, resizable panel that moves every foundation token live, selects the item you tap, and exports the result as a preset code or as the Swift to paste. The app stays live underneath on every tab, sheet, and cover. A release build returns your content unchanged.

![The floating card over the Showcase on iPhone, with the selected card outlined](/images/design-surface/iphone-card-light.png)

![The panel as a side column over the Showcase on iPad, with the selected buttons outlined](/images/design-surface/ipad-column-light.png)

## Add it

Add the product to the target that holds your scene root, import it, and apply `designSurface()` inside the theme call, so the tuned theme is the nearer one while tuning and the app's theme is the only one shipped:

```swift
import SwiftUIRegistryDesignSurface
import SwiftUIRegistryFoundations

ContentView()
    .designSurface()
    .registryTheme(.app)
```

Every installed item already carries `registryItem(_:)`, the tag the surface selects by, and a screen names itself with `registryScreen(_:)` so the panel can title its list. Items installed before 0.3.0 gain the tag through `swiftui-registry install <item> --update`.

## The panel

- **Tune** is a draggable button that settles to a side and remembers its place. A hold on it offers the outlines and the design guides: an 8 point grid, 24 point lines, and the 16 and 24 point margins.
- **The card** has a drag bar to move it, a corner grip to resize it, and a chevron to collapse it. It may hang off the leading, trailing, and bottom edges while its grab strip stays inside the safe area, and it never goes above the top, where the strip would be unreachable. On an iPad a drag against the trailing edge snaps it into a full-height column. Its frame is remembered per size class and re-clamped on rotation.
- **On this screen** lists the registry items on the screen behind the card, one row per item with its count; a row selects, and a switch outlines every item with its name.
- **Select** arms the next tap: the innermost tagged item under the tap is selected, and the panel scopes to the tokens that reach it, so a designer moves the knobs that change what they tapped and nothing else. All tokens brings the whole theme back. A tap on nothing clears the selection.
- **Presets, Export, Import**: the seven presets are one tap away; the preset code and the exact `RegistryTheme(...)` initializer leave through the copy actions; Import reads a code or an initializer back into the knobs.
- **Environment** switches preview the app in dark appearance, at larger text sizes, and right to left, without touching the theme.

The tool's own chrome is drawn from fixed system values, never the tuned theme, so tuning the app never restyles the tool, and its motion is off under Reduce Motion.

## Your own tokens and knobs

An app with its own design tokens hands them to the same panel. Conform the token value to `TokenDocument`: a shipped value, a file name, pages of `.number`, `.choice`, and `.color` knobs, and an `apply()` the surface calls after every change. Per-item knobs are numbers an item reads through the environment:

```swift
ContentView()
    .designSurface(
        tokens: MyTokens.self,
        knobs: ["button": [ItemKnob("padding", in: 0...32, shipped: 12)]]
    )
    .registryTheme(.app)
```

Inside an item: `environment.registryKnob("button", "padding", default: 12)`. The tuned tokens persist as `registry-tokens.json` and the knobs as `design-knobs.json` in the app's Documents directory; only a knob that moved is written, and a file that fails to decode leaves the shipped values in place and is logged once.

## An app that paints items from its own tokens

The host overload compiles in every configuration, so a team can review on TestFlight:

```swift
ContentView()
    .designSurface(
        enabled: designMode,
        tunesRegistryTheme: false,
        itemTitle: { name in MyPieces.title(for: name) },
        page: { name in MyPieces.page(for: name) },
        panelEnvironment: { panel in panel.environment(\.myTokens, tokens) }
    ) { chain in
        MyPanelSections(chain: chain)
    }
    .registryTheme(myTheme)
```

`enabled` is the app's own switch, `tunesRegistryTheme: false` drops the theme sections, `panel` adds the app's sections under the screen and the selection, `page` pushes the app's own page when a pick lands on an item it has one for, `panelEnvironment` wraps the panel's stack so pushed pages read the app's environment, and `itemTitle` names rows and outlines. `chain` lists every tagged item under the last pick, innermost first, so the app can offer the row around a button as well as the button. `designSurface(isPresented:)` lets the app own the trigger instead of the floating button.

## Where the result goes

The preset code the panel shows is the one every registry tool reads: `swiftui-registry preset decode <code>` prints its knobs, `preset apply <code> --destination <app>` writes `RegistryTheme+App.swift`, and the [Create](/create/) page opens it in the browser. Copy Swift gives the initializer directly. Either way the shipped theme is one value at the scene root, and the tool is gone from a release build.

## Known limitations

- The tool's window installs over the first connected scene; a second window of the same app on iPad is not covered.
- Items installed from 0.1.0 or 0.2.0 carry no `registryItem(_:)` tag until they are updated, so Select and the outlines find nothing in them.
