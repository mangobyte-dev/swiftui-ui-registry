import SwiftUI

/// Maps every registry item name to its live demo. Each demo compiles the
/// item's real `usage` snippet against the installed source, so a snippet
/// that stops compiling fails the Showcase build. The UI suite walks the
/// manifest and fails on any name without a demo.
enum ItemDemos {
    @MainActor
    static func demo(for name: String) -> AnyView? {
        switch name {
        // Components
        case "badge": AnyView(BadgeDemo())
        case "button": AnyView(ButtonDemo())
        case "button-group": AnyView(ButtonGroupDemo())
        case "card": AnyView(CardDemo())
        case "checkbox": AnyView(CheckboxDemo())
        case "input": AnyView(InputDemo())
        case "label": AnyView(LabelDemo())
        case "macro-progress": AnyView(MacroProgressDemo())
        case "metric-card": AnyView(MetricCardDemo())
        case "progress": AnyView(ProgressDemo())
        case "select": AnyView(SelectDemo())
        case "separator": AnyView(SeparatorDemo())
        case "spinner": AnyView(SpinnerDemo())
        case "textarea": AnyView(TextareaDemo())
        case "toggle": AnyView(ToggleDemo())
        case "toggle-group": AnyView(ToggleGroupDemo())
        case "transaction-row": AnyView(TransactionRowDemo())
        case "alert": AnyView(AlertDemo())
        case "avatar": AnyView(AvatarDemo())
        case "skeleton": AnyView(SkeletonDemo())
        case "empty": AnyView(EmptyDemo())
        case "accordion": AnyView(AccordionDemo())
        case "item": AnyView(ItemDemo())
        case "input-group": AnyView(InputGroupDemo())
        case "kbd": AnyView(KeycapDemo())
        case "command": AnyView(CommandPaletteDemo())
        // Blocks
        case "finance-overview": AnyView(FinanceDemo())
        case "nutrition-overview": AnyView(NutritionDemo())
        case "auth-form": AnyView(AuthenticationDemo())
        case "settings-section": AnyView(SettingsDemo())
        case "activity-feed": AnyView(ActivityFeedDemo())
        case "command-search": AnyView(CommandSearchDemo())
        // Recipes
        case "aspect-ratio": AnyView(AspectRatioRecipe())
        case "direction": AnyView(DirectionRecipe())
        case "native-select": AnyView(NativeSelectRecipe())
        case "radio-group": AnyView(RadioGroupRecipe())
        case "slider": AnyView(SliderRecipe())
        case "switch": AnyView(SwitchRecipe())
        case "tabs": AnyView(TabsRecipe())
        case "alert-dialog": AnyView(AlertDialogRecipe())
        case "calendar": AnyView(CalendarRecipe())
        case "collapsible": AnyView(CollapsibleRecipe())
        case "context-menu": AnyView(ContextMenuRecipe())
        case "dialog": AnyView(DialogRecipe())
        case "drawer": AnyView(DrawerRecipe())
        case "dropdown-menu": AnyView(DropdownMenuRecipe())
        case "popover": AnyView(PopoverRecipe())
        case "scroll-area": AnyView(ScrollAreaRecipe())
        case "sidebar": AnyView(SidebarRecipe())
        case "tooltip": AnyView(TooltipRecipe())
        // Not a registry item: the tuning preview, captured per preset for the website's Themes page
        case "theme-preview": AnyView(TuningPreview())
        default: nil
        }
    }
}

