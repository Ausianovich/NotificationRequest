

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
        public init() {}
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

