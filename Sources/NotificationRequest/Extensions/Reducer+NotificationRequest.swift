//
//  Reducer+NotificationRequest.swift
//  NotificationRequest
//
//  Created by Kanstantsin Ausianovich on 20/10/2026.
//

import ComposableArchitecture

extension Reducer {
    public func notificationRequest(_ state: WritableKeyPath<State, PresentationState<NotificationRequestFeature.State>>, action: CaseKeyPath<Action, PresentationAction<NotificationRequestFeature.Action>>) -> some ReducerOf<Self> {
        self.ifLet(state, action: action) { NotificationRequestFeature() }
    }
}
