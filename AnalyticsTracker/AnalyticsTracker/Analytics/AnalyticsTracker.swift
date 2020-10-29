//
//  AnalyticsTracker.swift
//  AnalyticsTracker
//
//  Created by Muzahidul Islam on 16/9/20.
//  Copyright © 2020 Muzahidul Islam. All rights reserved.
//

import Foundation

typealias AnalyticsParameters = [String : Any]

protocol TrackerID {
    var value: String { get }
}

enum TrackerError: Error {
    case notEnable
    case didNotRegsiter
}

protocol AnalyticTracker {
    var id: TrackerID { get set }
    var isEnabled: Bool { get set }
    var name: String { get set }
    func track(_ event: AnalyticsEvent)
    func handle(error: TrackerError)
}

extension AnalyticTracker {
    func handle(error: TrackerError) {}
}

