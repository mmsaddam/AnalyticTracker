//
//  Configuration.swift
//  AnalyticsTracker
//
//  Created by Muzahidul Islam on 16/9/20.
//  Copyright © 2020 Muzahidul Islam. All rights reserved.
//

import Foundation

struct Configuration {
    let qos: DispatchQoS
    let extraParameters: AnalyticsParameters?
    
    init(qos: DispatchQoS = .default, extraParameters: AnalyticsParameters? = nil) {
        self.qos = qos
        self.extraParameters = extraParameters
    }
}
