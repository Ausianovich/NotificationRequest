//
//  SwiftUIView.swift
//  NotificationRequest
//
//  Created by Kanstantsin Ausianovich on 09/10/2026.
//

import SwiftUI
import NotificationRequest
import ComposableArchitecture

extension View {
    
//    @preconcurrency @MainActor
//    private func notificationRequest<Item: StoreOf<NotificationRequestFeature>, ID: Hashable> (
//        item: Binding<Item?>,
//        id: KeyPath<Item, ID>,
//        onDismiss: (() -> Void)? = nil
//    ) -> some View {
//        sheet(item: item, id: id, onDismiss: onDismiss) { item in
//            let config = NotificationPermissionConfig.preview
//            
//            return NotificationRequestView(store: item.wrappedValue,
//                                    config: config,
//                                    primaryAction: {},
//                                    secondaryAction: {})
//        }
//    }
//    
//    public func notificationRequest<Item: StoreOf<NotificationRequestFeature>> (
//      item: Binding<Item?>,
//      onDismiss: (() -> Void)? = nil) -> some View {
//        notificationRequest(item: item, id: \.id, onDismiss: onDismiss)
//    }
//    
//    @_disfavoredOverload
//    public func notificationRequest<Item, ID: Hashable, Content: View>(
//        item: Binding<Item?>,
//        id: KeyPath<Item, ID>,
//        onDismiss: (() -> Void)? = nil,
//        @ViewBuilder content: @escaping (Binding<Item>) -> Content
//    ) -> some View {
//        sheet(item: item[id: id], onDismiss: onDismiss) { item in
////            content(Binding(unwrapping: item, default: $0.initialValue))
//            
//            let config = NotificationPermissionConfig.preview
//            return NotificationRequestView(store: item.wrappedValue,
//                                           config: config,
//                                           primaryAction: {},
//                                           secondaryAction: {})
//        }
//    }
}
