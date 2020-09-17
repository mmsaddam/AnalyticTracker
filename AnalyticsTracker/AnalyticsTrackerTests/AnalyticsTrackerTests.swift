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
        
        let configuration = Configuration(qos: .default, extraParameters: defaultParameters)
        
        let analytics = AnyAnalytics(configuration)
        
        var mocTracker = FaceBookMockTracker()
        
        let trackerExpectation = expectation(description: "MocTrackerExpectation")
        
        mocTracker.trackInvocationClosure = { trackerEvent in
            let isEqualEventAndDefault = self.isEqual(lhs: defaultParameters, rhs: trackerEvent.prarameters ?? [:])
            XCTAssertTrue(isEqualEventAndDefault)
            trackerExpectation.fulfill()
        }
        analytics.addTracker(mocTracker)
        
        var firebaseMocTracker = FirebaseMocTracker()
        
        let anotherTrackerExpectation = expectation(description: "AnotherTrackerExpectation")
        
        firebaseMocTracker.trackInvocationClosure = { trackerEvent in
            let isEqualEventAndDefault = self.isEqual(lhs: defaultParameters, rhs: trackerEvent.prarameters ?? [:])
            XCTAssertTrue(isEqualEventAndDefault)
            anotherTrackerExpectation.fulfill()
        }
        analytics.addTracker(firebaseMocTracker)
        
        let mocEvent = MocEvent.login
        
        analytics.track(mocEvent)
        
        wait(for: [trackerExpectation, anotherTrackerExpectation], timeout: 1)
    }
    
    func testAddExtraParametes() {
        let defaultParameters = [
            "OS Version" : "1.0.0",
            "Device ID" : "12345678"
        ]
        
        let configuration = Configuration(qos: .default, extraParameters: defaultParameters)
        
        let analytics = AnyAnalytics(configuration)
        
        let extraParamaters = [
            "Device Token": "43480fnsdlflsd",
            "data": "434930flsdfjsldf"
        ]
        
        analytics.addParameters(extraParamaters)
        
        var firebaseMocTracker = FirebaseMocTracker()
        
        let mocExpectation = expectation(description: "mocExpectation")
        
        let mergedParametes = merge(parameters: defaultParameters, withExtraParameters: extraParamaters)
        
        firebaseMocTracker.trackInvocationClosure = { [mergedParametes] trackerEvent in
            XCTAssertTrue(self.isEqual(lhs: trackerEvent.prarameters ?? [:], rhs: mergedParametes ?? [:]))
            mocExpectation.fulfill()
        }
        
        analytics.addTracker(firebaseMocTracker)
        
        let mocEvent = MocEvent.login
        analytics.track(mocEvent)
        
        wait(for: [mocExpectation], timeout: 2)
    }
    
    func testCustomEvent() {
        let customParameters = ["username" : "saddam", "password" : "1234"]
        
        let analytics = AnyAnalytics()
        var firebaseMockTracker = FirebaseMocTracker()
         let mocExpectation = expectation(description: "mocExpectation")
        firebaseMockTracker.trackInvocationClosure = { trackerEvent in
            XCTAssertTrue(self.isEqual(lhs: customParameters, rhs: trackerEvent.prarameters ?? [:]), "custom prameter is nit equal to event parameeter")
                mocExpectation.fulfill()
        }
        analytics.addTracker(firebaseMockTracker)
        
        let customEvent = MocEvent.custom(customParameters)
    
        analytics.track(customEvent)
        
        wait(for: [mocExpectation], timeout: 2)
    }
    
}

extension AnalyticsTrackerTests {
    private func isEqual(lhs: AnalyticsEvent, rhs: AnalyticsEvent) -> Bool {
        return lhs.name == rhs.name && lhs.prarameters?.count == rhs.prarameters?.count
    }
    
    private func isEqual(lhs: AnalyticsParameters, rhs: AnalyticsParameters) -> Bool {
        return lhs.count == rhs.count
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

