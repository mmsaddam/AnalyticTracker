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
    case facebook
    case firebase
}

fileprivate enum MocEvent: EventConvertible {
    case login
    case logout
    case custom(AnalyticsParameters)
    
    var name: String {
        switch self {
        case .login:
            return "login"
        case .logout:
            return "logout"
        case .custom:
            return "custom"
            
        }
    }
    
    var parameters: AnalyticsParameters {
        switch self {
        case .login, .logout:
            return [:]
        case .custom(let parameters):
            return parameters
        }
        
    }
    
    var trackers: [String] {
        return MocTrackerType.allCases.compactMap { $0.rawValue }
    }
}

fileprivate struct FaceBookMockTracker: AnalyticTracker {
    var id: String = MocTrackerType.facebook.rawValue
    var isEnabled: Bool = true
    var name: String = "FaceBookMockTracker"
    var trackInvocationClosure: ((AnalyticsEvent) -> Void)?
    
    func track(_ event: AnalyticsEvent) {
        print("Fire event at \(name) with Name: \(event.name), Parameters: \(event.prarameters ?? [:])")
        trackInvocationClosure?(event)
    }
}


fileprivate struct FirebaseMocTracker: AnalyticTracker {
    var id: String = MocTrackerType.firebase.rawValue
    var isEnabled: Bool = true
    var name: String = "FirebaseMocTracker"
    var trackInvocationClosure: ((AnalyticsEvent) -> Void)?
    
    func track(_ event: AnalyticsEvent) {
        print("fire event at \(name) with event: \(event.prarameters ?? [:])")
        trackInvocationClosure?(event)
    }
}



final class AnalyticsTrackerTests: XCTestCase {
    
    func testMockTracker() {
        var tracker = FaceBookMockTracker()
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
    
    func testTrackerWithDefaultParameters() {
        
        let defaultParameters = [
            "OS Version" : "1.0.0",
            "Device ID" : "12345678"
        ]
        
        let defaultParameterCount = defaultParameters.count
        
        let configuration = Configuration(qos: .default, extraParameters: defaultParameters)
        
        let analytics = AnyAnalytics(configuration)
        
        var mocTracker = FaceBookMockTracker()
        
        let trackerExpectation = expectation(description: "MocTrackerExpectation")
        
        mocTracker.trackInvocationClosure = { trackerEvent in
            let eventParameterCount = trackerEvent.prarameters?.count ?? 0
            XCTAssertEqual(defaultParameterCount, eventParameterCount)
            trackerExpectation.fulfill()
        }
        analytics.addTracker(mocTracker, id: MocTrackerType.facebook.rawValue)
        
        var anotherTracker = FirebaseMocTracker()
        
        let anotherTrackerExpectation = expectation(description: "AnotherTrackerExpectation")
        
        anotherTracker.trackInvocationClosure = { trackerEvent in
            let eventParameterCount = trackerEvent.prarameters?.count ?? 0
            XCTAssertEqual(defaultParameterCount, eventParameterCount)
            anotherTrackerExpectation.fulfill()
        }
        analytics.addTracker(anotherTracker, id: MocTrackerType.firebase.rawValue)
        
        let mocEvent = MocEvent.login
        
        analytics.track(mocEvent)
        
        wait(for: [trackerExpectation, anotherTrackerExpectation], timeout: 1)
    }
    
    func testAddExtraParametes() {
        <#function body#>
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
