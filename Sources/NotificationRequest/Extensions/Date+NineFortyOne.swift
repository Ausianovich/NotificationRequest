//
//  Date+NineFortyOne.swift
//  NotificationRequest
//
//  Created by Kanstantsin Ausianovich on 20/10/2026.
//

import Foundation

public extension Date {
    static var nineFortyOne: Date {
        let dateCompont = DateComponents(year: 2026, month: 1, day: 1, hour: 9, minute: 41)
        return Calendar.current.date(from: dateCompont)!
    }
}
