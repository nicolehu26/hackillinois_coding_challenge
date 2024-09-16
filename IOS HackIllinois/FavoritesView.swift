//
//  FavoritesView.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/16/24.
//

import SwiftUI

struct FavoritesView: View {
    let favoriteEvents: [Event] //array of Event objects
    let toggleFavorite: (Event) -> Void //toggle to unfavorite, passed as closure bc need to connect to other parts of app

    var body: some View {
        VStack {
            if favoriteEvents.isEmpty { //if are no favorite events, empty
                Text("No favorite events")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(favoriteEvents) { event in //otherwise display list of events
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventRow(
                            event: event,
                            isFavorite: true,
                            onFavoriteToggle: {
                                toggleFavorite(event)  // unfavorite the event
                            }
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Favorite Events")
            }
        }
    }
}

