//
//  Models.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/16/24.
//
import SwiftUI
import Foundation
public struct Event: Codable, Identifiable, Hashable {
    internal enum CodingKeys: String, CodingKey {
        case id = "eventId"
        case endTime
        case eventType
        case info = "description"
        case locations
        case name
        case sponsor
        case startTime
        case points
        case isAsync
        case mapImageUrl
        case displayOnStaffCheckIn
        case isPro
    }

    public let id: String
    public let endTime: Date
    public let eventType: String
    public let info: String
    public let locations: [Location]
    public let name: String
    public let sponsor: String?
    public let startTime: Date
    public let points: Int
    public let isAsync: Bool
    public let mapImageUrl: String?
    public let displayOnStaffCheckIn: Bool?
    public let isPro: Bool?
    
    public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        // conformance to Equatable (required by Hashable)
        public static func ==(lhs: Event, rhs: Event) -> Bool {
            return lhs.id == rhs.id
        }
}

public struct Location: Codable {
    internal enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case name = "description"
    }

    public let latitude: Double
    public let longitude: Double
    public let name: String
}

// MARK: - Event Container for API Response
public struct EventContainer: Decodable {
    public let events: [Event]
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
