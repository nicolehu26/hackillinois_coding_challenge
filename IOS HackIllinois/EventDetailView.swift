//
//  EventDetailView.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/16/24.
//

import SwiftUI
import CoreLocation


struct EventDetailView: View {
    let event: Event
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // display the event name in the body instead of the navigation title to prevent truncation
                Text(event.name)
                    .font(.title)
                    .bold()
                    .lineLimit(nil) // allow unlimited lines
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(event.info)
                    .font(.body)
                    .padding(.vertical)
                    .lineLimit(nil) // allow unlimited lines
                    .fixedSize(horizontal: false, vertical: true) // prevent truncation
                
                if let sponsor = event.sponsor, !sponsor.isEmpty {
                    Text("Sponsored by: \(sponsor)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Text("Event Type: \(event.eventType)")
                Text("Start: \(formatDate(from: event.startTime))")
                Text("End: \(formatDate(from: event.endTime))")
                
                // Displaying Location using Map
                ForEach(event.locations, id: \.name) { location in
                    Text("Location: \(location.name)")
                    MapView(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.vertical)
                }
            }
            .padding(.horizontal, horizontalSizeClass == .regular ? 50 : 20) // add horizontal padding for iPad (regular size class)
            .padding(.vertical)
        }
        .navigationTitle(event.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func formatDate(from date: Date) -> String {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            components.year = 2024 // Set the year to 2024

            if let newDate = calendar.date(from: components) {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                formatter.dateFormat = "MMM d, yyyy h:mm a"
                return formatter.string(from: newDate)
            }
            return "Invalid date"
        }
}
