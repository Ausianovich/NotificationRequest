# Agent Guide: Integrating NotificationRequest

Use this guide when adding NotificationRequest to a TCA and SwiftUI application. Keep changes limited to the integration requested by the user.

## What the package does

NotificationRequest provides a pre-permission UI and a TCA feature that requests notification authorization from `UNUserNotificationCenter`.

The system authorization applies to both remote (push) and local notifications. The package does not:

- Register the application with APNs.
- Handle or upload an APNs device token.
- Configure notification delegates.
- Schedule local notifications.
- Open the application's notification settings after a denial.

Implement those responsibilities in the host application only when the user requests them.

## Supported integration

The package requires:

- Swift 6.4 or newer.
- iOS 26 or newer, or macOS 26 or newer.
- The Composable Architecture 1.26.2 or newer.
- Dependencies 1.17.1 or newer.

For the complete flow, add the `NotificationRequestUI` product to the application target. Import the modules explicitly where their APIs are used:

```swift
import ComposableArchitecture
import NotificationRequest
import NotificationRequestUI
import SwiftUI
```

Do not copy `NotificationRequestFeature` or its view into the host application. Integrate the package as a presented child feature.

## Required TCA integration

### 1. Add presentation state

Add `NotificationRequestFeature.State?` to the presenting feature with `@Presents`:

```swift
@ObservableState
struct State: Equatable {
    @Presents var notificationRequest: NotificationRequestFeature.State?
}
```

Use modern TCA presentation APIs. Do not use the legacy `@PresentationState` wrapper.

### 2. Add the presentation action

Add a `PresentationAction` case to the parent action:

```swift
enum Action {
    case notificationRequest(
        PresentationAction<NotificationRequestFeature.Action>
    )
    case notificationsButtonTapped
}
```

Name the action that starts the flow after the actual user interaction in the host application.

### 3. Present the request from the reducer

Set the optional child state when the host application decides to show the pre-permission flow:

```swift
case .notificationsButtonTapped:
    state.notificationRequest = NotificationRequestFeature.State(
        configuration: .default
    )
    return .none
```

Do not call `UNUserNotificationCenter.requestAuthorization` separately for the same interaction. The child feature performs that request after the user taps its primary button.

Before presenting automatically, the host application may check its own product rules and persisted onboarding state. Do not repeatedly show the pre-permission UI without an explicit product requirement.

### 4. Handle the delegate result

Handle the child's delegate action in the parent reducer:

```swift
case let .notificationRequest(
    .presented(.delegate(.userResponse(isAuthorized)))
):
    if isAuthorized {
        // Continue the host application's notification setup.
    }
    return .none

case .notificationRequest:
    return .none
```

The result has these semantics:

- `true`: the system authorization request returned success.
- `false`: the system request returned false, or the user selected “Maybe later.”

Do not interpret `false` as proof that system authorization was denied, because the user may only have declined the package's pre-permission prompt.

If the application needs to distinguish detailed authorization states, implement that requirement deliberately rather than inferring it from the delegate Boolean.

For push notifications, APNs registration belongs in the host application's authorized branch or existing notification service. Do not add APNs registration for a local-notification-only application.

### 5. Attach the child reducer

Apply the package reducer modifier after the parent's core reducer:

```swift
var body: some ReducerOf<Self> {
    Reduce { state, action in
        // Parent logic
    }
    .notificationRequest(
        \.$notificationRequest,
        action: \.notificationRequest
    )
}
```

Use this modifier exactly once for a given child state. Do not also add a separate `ifLet` with `NotificationRequestFeature()`, because the package modifier already does that composition.

## Required SwiftUI integration

The presenting view needs a bindable parent store:

```swift
struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        Button("Enable notifications") {
            store.send(.notificationsButtonTapped)
        }
        .notificationRequest(
            $store.scope(
                state: \.notificationRequest,
                action: \.notificationRequest
            )
        )
    }
}
```

Attach `notificationRequest(_:style:)` to a stable container in the presenting screen. Pass the binding produced by `$store.scope(state:action:)`; do not manually construct a `Binding` and do not present a second sheet for the same state.

The package controls dismissal after either choice and disables interactive dismissal. Do not clear the child state from the view. Let TCA presentation handling manage its lifecycle.

Use modern observable TCA stores. Do not introduce `ViewStore`, `WithViewStore`, or legacy store-based sheet APIs.

## Configuration

Prefer `.default` unless the product requires custom copy:

```swift
let configuration = NotificationRequestFeature.Configuration(
    title: "Stay up to date",
    description: "Enable notifications for important activity and reminders.",
    primaryButtonTitle: "Enable notifications",
    secondaryButtonTitle: "Maybe later",
    showsSecondaryButton: true
)
```

All copy uses `LocalizedStringResource`. Use the host application's String Catalog for production localization instead of hard-coded user-facing strings.

The configuration can receive exactly three notification preview items:

```swift
let configuration = NotificationRequestFeature.Configuration(
    title: "Stay up to date",
    description: "Enable notifications for important activity and reminders.",
    primaryButtonTitle: "Enable notifications",
    secondaryButtonTitle: "Maybe later",
    showsSecondaryButton: true,
    content: [
        .init(title: "New activity", caption: "Something needs your attention."),
        .init(title: "Reminder", caption: "Your scheduled event starts soon."),
        .init(title: "Update", caption: "There is something new to review.")
    ]
)
```

Keep preview copy short enough for the package's single-line notification cards.

Set `showsSecondaryButton` to `false` only when the product intentionally requires a single-action pre-permission screen. A secondary title is still required by the current initializer.

## Styling

Pass a `NotificationRequestStyle` through the SwiftUI modifier:

```swift
var notificationStyle: NotificationRequestStyle {
    var style = NotificationRequestStyle.default
    style.tint = .indigo
    style.appIcon = Image("AppIconPreview")
    return style
}
```

```swift
.notificationRequest(
    $store.scope(
        state: \.notificationRequest,
        action: \.notificationRequest
    ),
    style: notificationStyle
)
```

Start from `.default` because the current style initializer is not public.

The current presentation uses a fixed sheet height. Do not claim that changing `detentHeight` affects the UI unless the implementation has been updated to consume that property.

## Integration checklist

Before considering an integration complete, verify that:

- The application target links `NotificationRequestUI`.
- The parent state uses `@Presents`.
- The parent action uses `PresentationAction<NotificationRequestFeature.Action>`.
- The parent reducer handles the delegate response.
- The parent reducer applies `.notificationRequest(_:action:)` once.
- The SwiftUI view scopes a bindable optional store into `.notificationRequest(_:style:)`.
- User-facing copy is localized.
- Push registration or local scheduling is kept outside this package.
- No second system authorization request is made for the same flow.

Build the host application after integration. If compiler diagnostics disagree with this guide, inspect the package's current public declarations before changing application architecture.
