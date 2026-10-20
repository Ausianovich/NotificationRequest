//
//  NotificationRequestStyle.swift
//  NotificationRequest
//
//  Created by Kanstantsin Ausianovich on 20/10/2026.
//

import SwiftUI

public struct NotificationRequestStyle {
    public var tint: Color
    public var appIcon: Image
    public var detentHeight: CGFloat
    
    init(tint: Color, appIcon: Image, detentHeight: CGFloat) {
        self.tint = tint
        self.appIcon = appIcon
        self.detentHeight = detentHeight
    }
    
    public static var `default`: NotificationRequestStyle {
        NotificationRequestStyle(tint: .accentColor, appIcon: .init(.testIcon), detentHeight: 450.0)
    }
}
