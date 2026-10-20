//
//  View+NotificationRequest.swift
//  NotificationRequest
//
//  Created by Kanstantsin Ausianovich on 20/10/2026.
//

import SwiftUI
import NotificationCenter

import ComposableArchitecture

import NotificationRequest

extension View {
    @ContentBuilder
    public func notificationRequest(_ store: Binding<StoreOf<NotificationRequestFeature>?>, style: NotificationRequestStyle = .default) -> some View {
        sheet(item: store) { store in
            NotificationRequestView(store: store, style: style)
        }
    }
}
