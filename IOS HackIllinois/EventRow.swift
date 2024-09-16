//
//  EventRow.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/16/24.
//

import SwiftUI

struct EventRow: View {
    let event: Event
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void

    var body: some View {
        HStack { //puts event details and favorites button side by side
            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.headline)
                Text(event.info)
                    .font(.subheadline)
                    
                Text("Start: \(formatDate(from: event.startTime))")
                Text("End: \(formatDate(from: event.endTime))")
            }

            Spacer() //needed to make favorite button to far right of row

            Button(action: onFavoriteToggle) { //when pressed, onFavorite toggle closure triggered
                Image(systemName: isFavorite ? "star.fill" : "star") //fill in star if pressed
                    .foregroundColor(isFavorite ? .yellow : .gray) //pressed will be yellow, otherwise gray
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical)
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
