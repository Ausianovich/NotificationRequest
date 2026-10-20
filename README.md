# NotificationRequest

NotificationRequest is a Swift package built with [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and [Dependencies](https://github.com/pointfreeco/swift-dependencies). It provides a reusable, testable flow for explaining the value of notifications before asking the user to authorize push and local notifications.

The package presents a customizable pre-permission sheet and, after the user confirms, requests notification authorization through `UNUserNotificationCenter`.

> Notification authorization is shared by remote (push) and local notifications. This package requests that authorization. Registering with APNs, uploading a device token, and scheduling notification content remain the responsibility of the host application.

## Requirements

- Swift 6.4+
- iOS 26+
- macOS 26+
- The Composable Architecture 1.26.2+
- Dependencies 1.17.1+

## Products

The package exposes two library products:

- `NotificationRequest` contains the feature domain, reducer integration, and notification dependency.
- `NotificationRequestUI` contains the SwiftUI presentation and includes the core target as a product dependency.

Use `NotificationRequestUI` when you want the complete TCA and SwiftUI flow. Use `NotificationRequest` when you only need the domain and dependency layer.

## Architecture

NotificationRequest is split into three layers.

### Feature domain

`NotificationRequestFeature` is a TCA reducer with:

- `State`, which owns a `Configuration`.
- View actions for enabling notifications or postponing the decision.
- A delegate action, `userResponse(Bool)`, which reports the user's result to the parent feature.
- A dismissal dependency that closes the presentation after either choice.

When the user taps the primary button, the reducer requests system authorization and sends the result to its parent. When the user taps the secondary button, it sends `false` without displaying the system authorization prompt.

### Dependency layer

`NotificationRequestClient` wraps `UNUserNotificationCenter` with two async operations:

- `requestAuthorization()` requests alert, sound, badge, and provisional authorization.
- `currentAuthorization()` returns a package-level authorization status.

The live implementation uses the system notification center. Because the client is modeled with Dependencies, its behavior can be replaced with deterministic values in package tests and previews.

### Presentation layer

`NotificationRequestUI` provides:

- A SwiftUI sheet with an animated notification preview.
- `View.notificationRequest(_:style:)` for presenting the feature from a scoped optional store.
- `Reducer.notificationRequest(_:action:)` for attaching the child reducer to a parent presentation domain.
- `NotificationRequestStyle` for presentation styling.
- `NotificationRequestFeature.Configuration` for localized copy and preview notification content.

## Installation

Add this repository as a Swift Package dependency in Xcode, then add the `NotificationRequestUI` product to your application target.

Import the modules where needed:

```swift
import ComposableArchitecture
import NotificationRequest
import NotificationRequestUI
import SwiftUI
```

## TCA integration

### 1. Add presentation state

Add optional presentation state for `NotificationRequestFeature` to the parent feature:

```swift
@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var notificationRequest: NotificationRequestFeature.State?
    }

    enum Action {
        case notificationRequest(
            PresentationAction<NotificationRequestFeature.Action>
        )
        case notificationsButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .notificationsButtonTapped:
                state.notificationRequest = NotificationRequestFeature.State(
                    configuration: .default
                )
                return .none

            case let .notificationRequest(
                .presented(.delegate(.userResponse(isAuthorized)))
            ):
                // Continue your app-specific flow.
                // For push notifications, register with APNs when appropriate.
                return .none

            case .notificationRequest:
                return .none
            }
        }
        .notificationRequest(
            \.$notificationRequest,
            action: \.notificationRequest
        )
    }
}
```

Setting `notificationRequest` to a non-`nil` value presents the flow. The reducer modifier scopes `NotificationRequestFeature` into the parent and automatically handles its presentation lifecycle.

### 2. Provide custom copy

Use `.default` for the built-in localized configuration, or create your own:

```swift
let configuration = NotificationRequestFeature.Configuration(
    title: "Stay up to date",
    description: "Enable notifications for important activity and reminders.",
    primaryButtonTitle: "Enable notifications",
    secondaryButtonTitle: "Maybe later",
    showsSecondaryButton: true
)

state.notificationRequest = NotificationRequestFeature.State(
    configuration: configuration
)
```

The configuration accepts `LocalizedStringResource` values, so copy can come from the host application's String Catalog.

You can also supply exactly three notification preview items:

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

## SwiftUI integration

Create a bindable parent store and attach the view modifier to the screen that should present the sheet:

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

The modifier presents `NotificationRequestView` as a sheet whenever the scoped child store is available. The child dismisses itself after the user enables notifications or chooses “Maybe later.”

## Handling the result

The `Bool` in `userResponse(Bool)` is the result returned by the authorization request:

- `true` means the system accepted the requested notification authorization.
- `false` means the request was declined or the user selected “Maybe later.”

Internally, `NotificationRequestClient` also models `notDetermined`, `denied`, `authorized`, `provisional`, and `ephemeral` authorization states.
