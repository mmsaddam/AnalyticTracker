//
//  AnyAnalytics.swift
//  AnalyticsTracker
//
//  Created by Muzahidul Islam on 16/9/20.
//  Copyright © 2020 Muzahidul Islam. All rights reserved.
//

import Foundation


final class AnyAnalytics {
    
    private var defaultParameters: AnalyticsParameters = [:]
    private var trackers: [String : AnalyticTracker] = [:]
    
    private let queue: DispatchQueue
    
    static let shared: AnyAnalytics = AnyAnalytics()
    
    init(_ configuration: Configuration = Configuration()) {
        queue = DispatchQueue(label: "com.muzahid.text", qos: configuration.qos, attributes: .concurrent)
        defaultParameters = configuration.extraParameters ?? [:]
    }
    
    func setDefaultParameters(_ parameteres: AnalyticsParameters) {
        defaultParameters = parameteres
    }
    
    func addParameters(_ parameters: AnalyticsParameters?) {
        if let totalPrameters = merge(parameters: defaultParameters, withExtraParameters: parameters) {
            defaultParameters = totalPrameters
        }
    }
    
    func addTracker(_ tracker: AnalyticTracker) {
        trackers[tracker.id.value] = tracker
    }
    
    func track(_ event: EventConvertible) {
        
        let trackableAllParameters = merge(parameters: defaultParameters, withExtraParameters: event.parameters)
        
        let trackerEvent = getAnalyticEvent(from: event.name, parameters: trackableAllParameters)
        
        let existingTrackers = trackers.values
        
        queue.async {
            for tracker in existingTrackers {
                guard tracker.isEnabled && self.shouldldFireEvent(event, toTracker: tracker) else { continue }
                tracker.track(trackerEvent)
            }
        }
        
    }
    
    private func shouldldFireEvent(_ event: EventConvertible, toTracker tracker: AnalyticTracker) -> Bool {
        event.trackers.map { $0.value }.contains(tracker.id.value)
    }
    
    private func getAnalyticEvent(from name: String, parameters: AnalyticsParameters?) -> AnalyticsEvent {
        return AnalyticsEvent(name: name, prarameters: parameters)
    }
    
    private func convertEvent(from event: EventConvertible) -> AnalyticsEvent {
        return AnalyticsEvent(name: event.name, prarameters: event.parameters)
    }
    
    private func merge(parameters: AnalyticsParameters?,
                       withExtraParameters extra: AnalyticsParameters?) -> AnalyticsParameters? {
        
        switch (parameters, extra) {
        case (var parameters?, let extra?):
            parameters.merge(extra, uniquingKeysWith: { _, new in new })
            return parameters
        default:
            return parameters ?? extra
        }
    }
    
}
