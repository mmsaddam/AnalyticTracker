//
//  AnalyticsTrackerTests.swift
//  AnalyticsTrackerTests
//
//  Created by Muzahidul Islam on 16/9/20.
//  Copyright © 2020 Muzahidul Islam. All rights reserved.
//

import XCTest
@testable import AnalyticsTracker

fileprivate enum MocTrackerType: String, CaseIterable {
    case fb
    case google
}

fileprivate enum MocEvent: EventConvertible {
    case login
    case logout
    
    var name: String {
        return "MocEvent"
    }
    
    var parameters: AnalyticsParameters {
        return [:]
    }
    
    var trackers: [String] {
        return MocTrackerType.allCases.compactMap { $0.rawValue }
    }
}

fileprivate struct FBMockTracker: AnalyticTracker {
    var id: String = MocTrackerType.fb.rawValue
    var isEnabled: Bool = true
    var name: String = "FBMockTracker"
    var trackInvocationClosure: ((AnalyticsEvent) -> Void)?
    
    func track(_ event: AnalyticsEvent) {
        print("fire event at \(name) with event: \(event.prarameters ?? [:])")
        trackInvocationClosure?(event)
    }
}


fileprivate struct GoogleMockTracker: AnalyticTracker {
    var id: String = MocTrackerType.google.rawValue
    var isEnabled: Bool = true
    var name: String = "GoogleMockTracker"
    var trackInvocationClosure: ((AnalyticsEvent) -> Void)?
    
    func track(_ event: AnalyticsEvent) {
        print("fire event at \(name) with event: \(event.prarameters ?? [:])")
        trackInvocationClosure?(event)
    }
}



final class AnalyticsTrackerTests: XCTestCase {
    
    func testMockTracker() {
        var tracker = FBMockTracker()
        let eventParameters = ["userName" : "mmsaddam", "passworkd" : "1234"]
        
        let loginEvent = AnalyticsEvent(name: "login", prarameters: eventParameters)
        let trackerExpectation  = expectation(description: "Mock tracker testing")
        
        defer {
            wait(for: [trackerExpectation], timeout: 1)
        }
        tracker.trackInvocationClosure = { trackerEvent in
            XCTAssert(self.isEqual(lhs: trackerEvent, rhs: loginEvent), "Two event is not equal")
            trackerExpectation.fulfill()
        }
        tracker.track(loginEvent)
        
    }
    
    
    
    
}

extension AnalyticsTrackerTests {
    private func isEqual(lhs: AnalyticsEvent, rhs: AnalyticsEvent) -> Bool {
        return lhs.name == rhs.name && lhs.prarameters?.count == rhs.prarameters?.count
    }
    
    private func isEqual(lhs: AnalyticsParameters, rhs: AnalyticsParameters) -> Bool {
        return lhs as AnyObject === rhs as AnyObject
    }
}
