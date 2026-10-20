

import Foundation
import ComposableArchitecture
import DependenciesMacros
import UserNotifications

@Reducer
public struct NotificationRequestFeature : Sendable {
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.notificationClient) var notificationClient
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public var configuration: NotificationRequestFeature.Configuration
        
        public init(configuration: NotificationRequestFeature.Configuration) {
            self.configuration = configuration
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)
        
        public enum View {
            case tapEnableNotifications
            case tapMaybeLater
        }
        
        public enum Delegate {
            case userResponse(Bool)
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case .view(let viewAction):
                switch viewAction {
                case .tapEnableNotifications:
                    return .run { send in
                        let response = try await notificationClient.requestAuthorization()
                        await send(.delegate(.userResponse(response)))
                        await self.dismiss()
                    }
                case .tapMaybeLater:
                    return .run { send in
                        await send(.delegate(.userResponse(false)))
                        await self.dismiss()
                    }
                }
            }
        }
    }
}

//MARK: - Extension: NotificationRequestFeature
public extension NotificationRequestFeature {
    
    struct Configuration: Equatable {
        public var title: LocalizedStringResource
        public var description: LocalizedStringResource
        public var primaryButtonTitle: LocalizedStringResource
        public var secondaryButtonTitle: LocalizedStringResource
        public var showsSecondaryButton: Bool
        
        public var topNotification: NotificationContent = .default
        public var centerNotification: NotificationContent = .default
        public var bottomNotification: NotificationContent = .default
        
        public init(title: LocalizedStringResource,
             description: LocalizedStringResource,
             primaryButtonTitle: LocalizedStringResource,
             secondaryButtonTitle: LocalizedStringResource,
             showsSecondaryButton: Bool,
             content: InlineArray<3, NotificationContent>? = nil) {
            
            self.title = title
            self.description = description
            self.primaryButtonTitle = primaryButtonTitle
            self.secondaryButtonTitle = secondaryButtonTitle
            self.showsSecondaryButton = showsSecondaryButton
            
            if let content {
                topNotification = content[0]
                centerNotification = content[1]
                bottomNotification = content[2]
            }
        }
        
        public static var `default`: Configuration {
            Configuration(title: LocalizedStringResource("default.title", bundle: #bundle),
                 description: LocalizedStringResource("default.description", bundle: #bundle),
                 primaryButtonTitle: LocalizedStringResource("default.primary_button_title", bundle: #bundle),
                 secondaryButtonTitle: LocalizedStringResource("default.secondary_button_title", bundle: #bundle),
                 showsSecondaryButton: true)
        }
        
        public struct NotificationContent: Equatable {
            public var title: LocalizedStringResource
            public var caption: LocalizedStringResource
            
            public init(title: LocalizedStringResource, caption: LocalizedStringResource) {
                self.title = title
                self.caption = caption
            }
            
            public static var `default`: NotificationContent {
                NotificationContent(title: LocalizedStringResource("default.notification_content_title", bundle: #bundle),
                                    caption: LocalizedStringResource("default.notification_content_caption", bundle: #bundle))
            }
        }
    }
}
