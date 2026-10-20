//
//  NotificationRequestClient.swift
//  NotificationRequest
//
//  Created by Kanstantsin Ausianovich on 20/10/2026.
//

import Dependencies
import DependenciesMacros
import UserNotifications

@DependencyClient
public struct NotificationRequestClient: TestDependencyKey, Sendable {
    public var requestAuthorization: @Sendable () async throws -> Bool
    public var currentAuthorization: @Sendable () async throws -> Status
    
    public static let testValue: NotificationRequestClient = Self()
    
    public enum Status {
        case notDetermined
        case denied
        case authorized
        case provisional
        case ephemeral
        
        init(_ status: UNAuthorizationStatus) {
            switch status {
            case .notDetermined: self = .notDetermined
            case .denied: self = .denied
            case .authorized: self = .authorized
            case .provisional: self = .provisional
            case .ephemeral: self = .ephemeral
            @unknown default:
                self = .denied
            }
        }
    }
}

extension DependencyValues {
    var notificationClient: NotificationRequestClient {
        get { self[NotificationRequestClient.self] }
        set { self[NotificationRequestClient.self] = newValue }
    }
}

extension NotificationRequestClient: DependencyKey {
    public static var liveValue: NotificationRequestClient {
        Self {
            let center = UNUserNotificationCenter.current()
            return try await center.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
        } currentAuthorization: {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            return Status(settings.authorizationStatus)
        }
    }
}


