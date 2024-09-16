//
//  Models.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/16/24.
//
import SwiftUI

public struct Event: Codable, Identifiable, Hashable {
    //Codable works with serializatoin and deserialization of JSONs, Encodable, Decodable, CodingKeys
    //Identifiable ensures Event struct has unique id
    //Hashable allows struct to be used in Set for FavoritesView tab
    internal enum CodingKeys: String, CodingKey { //map JSON keys from API to property names in event, decoding
        case id = "eventId" //maps JSON key "eventID" to id
        case startTime
        case endTime
        case eventType
        case info = "description"
        case locations
        case name
        case sponsor
        case points
        case isAsync
        case mapImageUrl
        case isPro
    }
//store actual data for Event object
    public let id: String
    public let startTime: Date //Codable parses Data objects from string representation in API
    public let endTime: Date
    public let eventType: String
    public let info: String
    public let locations: [Location] //can have multiple locations
    public let name: String
    public let sponsor: String? //optional, only if event has sponsor
    public let points: Int
    public let isAsync: Bool
    public let mapImageUrl: String?
    public let isPro: Bool?
    
    public func hash(into hasher: inout Hasher) { //hashable implementation allows Event to be used in hashed collections like Set
            hasher.combine(id)
        }

        // conformance to Equatable (required by Hashable)
        public static func ==(lhs: Event, rhs: Event) -> Bool { //check if Event instances are equal if have same id
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

// Event Container for API Response
public struct EventContainer: Decodable { //wraps array of Event objects, decodes API response
    public let events: [Event]
}

// Preview
struct ContentView_Previews: PreviewProvider { //generate previews in XCode
    static var previews: some View {
        ContentView()
    }
}
