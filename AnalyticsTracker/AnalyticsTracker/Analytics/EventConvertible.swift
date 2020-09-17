//
//  EventConvertible.swift
//  AnalyticsTracker
//
//  Created by Muzahidul Islam on 16/9/20.
//  Copyright © 2020 Muzahidul Islam. All rights reserved.
//

import Foundation

protocol EventConvertible {
    var name: String { get }
    var parameters: AnalyticsParameters { get }
    var trackers: [TrackerID] { get }
}
