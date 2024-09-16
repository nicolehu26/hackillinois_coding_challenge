//
//  IOS_HackIllinoisTests.swift
//  IOS HackIllinoisTests
//
//  Created by Nicole Hu on 9/15/24.
//
//
//import XCTest
//@testable import IOS_HackIllinois
//
//final class IOS_HackIllinoisTests: XCTestCase {
//
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}

import XCTest
@testable import IOS_HackIllinois

final class IOS_HackIllinoisTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEventDecoding() throws {
        // Given: A sample JSON string that simulates the API response
        let jsonString = """
        {
            "events": [
                {
                    "eventId": "abc123",
                    "name": "Test Event",
                    "description": "This is a test event.",
                    "startTime": 1708754880,
                    "endTime": 1708754940,
                    "locations": [
                        {
                            "description": "Siebel Center",
                            "latitude": 40.1138,
                            "longitude": -88.2249
                        }
                    ],
                    "sponsor": "HackIllinois",
                    "eventType": "WORKSHOP",
                    "points": 10,
                    "isAsync": false,
                    "mapImageUrl": "https://someurl.com/map.png"
                }
            ]
        }
        """
        
        // When: We decode the JSON
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        let eventContainer = try decoder.decode(EventContainer.self, from: data)
        
        // Then: Check that the event was decoded properly
        XCTAssertEqual(eventContainer.events.count, 1)
        let event = eventContainer.events.first!
        
        XCTAssertEqual(event.id, "abc123")
        XCTAssertEqual(event.name, "Test Event")
        XCTAssertEqual(event.info, "This is a test event.")
        XCTAssertEqual(event.eventType, "WORKSHOP")
        XCTAssertEqual(event.locations.count, 1)
        XCTAssertEqual(event.locations.first?.name, "Siebel Center")
    }

    // Performance test example
    func testPerformanceExample() throws {
        self.measure {
            // Measure the time of the decoding function
            let jsonString = """
            {
                "events": [
                    {
                        "eventId": "abc123",
                        "name": "Test Event",
                        "description": "This is a test event.",
                        "startTime": 1708754880,
                        "endTime": 1708754940,
                        "locations": [
                            {
                                "description": "Siebel Center",
                                "latitude": 40.1138,
                                "longitude": -88.2249
                            }
                        ],
                        "sponsor": "HackIllinois",
                        "eventType": "WORKSHOP",
                        "points": 10,
                        "isAsync": false,
                        "mapImageUrl": "https://someurl.com/map.png"
                    }
                ]
            }
            """
            
            let data = jsonString.data(using: .utf8)!
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                _ = try decoder.decode(EventContainer.self, from: data)
            } catch {
                XCTFail("Decoding failed")
            }
        }
    }
    
    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

}
