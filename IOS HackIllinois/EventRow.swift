//
//  EventRow.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/16/24.
//

import SwiftUI
import Foundation

struct EventRow: View {
    let event: Event
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.headline)
                Text(event.info)
                    .font(.subheadline)
                    
                Text("Start: \(formatDate(from: event.startTime))")
                Text("End: \(formatDate(from: event.endTime))")
            }

            Spacer()

            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundColor(isFavorite ? .yellow : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical)
    }

    func formatDate(from date: Date) -> String {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            components.year = 2024 // Set the year to 2024

            if let newDate = calendar.date(from: components) {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current // ensures correct time zone
                formatter.dateFormat = "MMM d, yyyy h:mm a"
                return formatter.string(from: newDate)
            }
            return "Invalid date"
        }
}
