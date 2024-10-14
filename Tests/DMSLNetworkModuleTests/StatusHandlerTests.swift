//
//  StatusHandlerTests.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-13.
//
//
import XCTest
import Alamofire
@testable import DMSLNetworkModule

// MARK: - StatusHandlerTests
final class StatusHandlerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset StatusHandler before each test to ensure clean state
        StatusHandler.shared.resetRules()
    }

    override func tearDown() {
        super.tearDown()
        // Reset StatusHandler after each test
        StatusHandler.shared.resetRules()
    }

    // MARK: - Test Adding a Rule
    func testAddRule() {
        let rule = StatusHandlerRule(statusCode: 404, urlPattern: "/notfound") { _ in
            print("Handled 404")
        }

        StatusHandler.shared.addRule(rule)

        // Check if the rule is added
        XCTAssertEqual(StatusHandler.shared.rulesCount, 1, "There should be exactly one rule added.")
    }

    // MARK: - Test Process Status Code with Matching Rule
    func testProcessStatusCode_MatchingRule() {
        let expectation = self.expectation(description: "Handler for matching rule should be called.")
        let matchingURL = "https://example.com/notfound"

        let rule = StatusHandlerRule(statusCode: 404, urlPattern: "/notfound") { url in
            XCTAssertEqual(url, matchingURL, "Handler should receive the correct URL.")
            expectation.fulfill() // Mark expectation fulfilled
        }

        StatusHandler.shared.addRule(rule)

        // Process a status code with matching URL pattern
        StatusHandler.shared.processStatusCode(statusCode: 404, for: matchingURL)

        // Ensure the expectation was fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - Test Process Status Code with No Matching Rule
    func testProcessStatusCode_NoMatchingRule() {
        let unmatchedURL = "https://example.com/other"
        let expectation = self.expectation(description: "No rule should match")
        expectation.isInverted = true // This should not be fulfilled

        let rule = StatusHandlerRule(statusCode: 404, urlPattern: "/notfound") { _ in
            expectation.fulfill() // This shouldn't happen
        }

        StatusHandler.shared.addRule(rule)

        // Process with a URL that doesn't match
        StatusHandler.shared.processStatusCode(statusCode: 200, for: unmatchedURL)

        // Ensure the inverted expectation is not fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - Test Reset Rules
    func testResetRules() {
        // Add a rule first
        let rule = StatusHandlerRule(statusCode: 404, urlPattern: "/notfound") { _ in
            print("Handled 404")
        }

        StatusHandler.shared.addRule(rule)
        XCTAssertEqual(StatusHandler.shared.rulesCount, 1, "There should be one rule before resetting.")

        // Now reset rules and check if the count is zero
        StatusHandler.shared.resetRules()
        XCTAssertEqual(StatusHandler.shared.rulesCount, 0, "There should be no rules after resetting.")
    }

    // MARK: - Test Rules Count
    func testRulesCount() {
        // Initially, the rules count should be zero
        XCTAssertEqual(StatusHandler.shared.rulesCount, 0, "Initially, there should be no rules.")

        // Add a rule
        let rule = StatusHandlerRule(statusCode: 404, urlPattern: "/notfound") { _ in
            print("Handled 404")
        }

        StatusHandler.shared.addRule(rule)

        // After adding, the rules count should be one
        XCTAssertEqual(StatusHandler.shared.rulesCount, 1, "There should be one rule after adding.")

        // Add another rule and check again
        let rule2 = StatusHandlerRule(statusCode: 500, urlPattern: "/servererror") { _ in
            print("Handled 500")
        }

        StatusHandler.shared.addRule(rule2)

        XCTAssertEqual(StatusHandler.shared.rulesCount, 2, "There should be two rules after adding a second rule.")
    }
}
