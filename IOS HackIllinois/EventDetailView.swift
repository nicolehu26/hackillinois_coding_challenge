//
//  EventDetailView.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/16/24.
//

import SwiftUI
import CoreLocation //for CLLocationCoordinate2D

//EventDetailView to display info about single event once clicked
struct EventDetailView: View {
    let event: Event //stores event object
    @Environment(\.horizontalSizeClass) var horizontalSizeClass //detects size class of current device's display for iphone vs ipad
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // display the event name in the body instead of the navigation title to prevent truncation
                Text(event.name)
                    .font(.title)
                    .bold()
                    .lineLimit(nil) // allow unlimited lines
                    .fixedSize(horizontal: false, vertical: true) //expand vertically and not horizontally
                
                Text(event.info) //description
                    .font(.body)
                    .padding(.vertical)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let sponsor = event.sponsor, !sponsor.isEmpty { //only show if sponsor is not empty
                    Text("Sponsored by: \(sponsor)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Text("Event Type: \(event.eventType)")
                Text("Start: \(formatDate(from: event.startTime))")
                //convert Date object to string
                Text("End: \(formatDate(from: event.endTime))")
                
                // displaying Location using Map, loop through each location in events.location array and create new view for each one
                ForEach(event.locations, id: \.name) { location in
                    Text("Location: \(location.name)")
                    MapView(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                        .frame(height: 200)
                        .cornerRadius(10) //round corners
                        .padding(.vertical)
                }
            }
            .padding(.horizontal, horizontalSizeClass == .regular ? 50 : 20) // add more horizontal padding for ipad, otherwise for iphone
            .padding(.vertical)
        }
        .navigationTitle(event.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    //UNIX timestamp is # of secs from Jan 1 1970
    func formatDate(from date: Date) -> String { //converts Date object to string
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            components.year = 2024 // Set the year to 2024

            if let newDate = calendar.date(from: components) { //new Date object with modified date
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy h:mm a" //abbreviate month, day, year, hour, min, am/pm
                return formatter.string(from: newDate)
            }
            return "Invalid date"
        }
}
