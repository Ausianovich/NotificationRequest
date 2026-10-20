//
//  File.swift
//  NotificationRequest
//
//  Created by Kanstantsin Ausianovich on 09/10/2026.
//

import Foundation
import ComposableArchitecture
import NotificationRequest

@Reducer
struct MainPresenterFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var notificationRequest: NotificationRequestFeature.State?
    }
    
    enum Action: ViewAction {
        case notificationRequest(PresentationAction<NotificationRequestFeature.Action>)
        case view(View)
        
        enum View {
            case tapPresentNotificationRequest
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.tapPresentNotificationRequest):
                state.notificationRequest = NotificationRequestFeature.State()
                return .none
            case .view:
                return .none
            case .notificationRequest:
                return .none
            }
        }
        .ifLet(\.$notificationRequest, action: \.notificationRequest) {
            NotificationRequestFeature()
        }
    }
}
