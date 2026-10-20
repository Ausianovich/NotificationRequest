//
//  File.swift
//  NotificationRequest
//
//  Created by Kanstantsin Ausianovich on 20/10/2026.
//

#if DEBUG && os(iOS)

import SwiftUI
import Foundation
import ComposableArchitecture
import NotificationRequest

@Reducer
struct SamplePresenterFeature {
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
                state.notificationRequest = NotificationRequestFeature.State(configuration: .default)
                return .none
            case .view:
                return .none
            case .notificationRequest:
                return .none
            }
        }
        .notificationRequest(\.$notificationRequest, action: \.notificationRequest)
    }
}


@ViewAction(for: SamplePresenterFeature.self)
struct SamplePresenter: View {
    @Bindable var store: StoreOf<SamplePresenterFeature> = .init(initialState: SamplePresenterFeature.State(), reducer: { SamplePresenterFeature() })
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    send(.tapPresentNotificationRequest)
                } label: {
                    Text("Present request")
                }
            }
        }
        .notificationRequest($store.scope(\.notificationRequest, action: \.notificationRequest))
    }
}

#Preview {
    SamplePresenter()
}

#endif
