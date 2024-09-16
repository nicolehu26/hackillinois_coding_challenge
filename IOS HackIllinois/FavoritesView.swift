//
//  FavoritesView.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/16/24.
//

import SwiftUI
// MARK: - FavoritesView

struct FavoritesView: View {
    let favoriteEvents: [Event]
    let toggleFavorite: (Event) -> Void

    var body: some View {
        VStack {
            if favoriteEvents.isEmpty {
                Text("No favorite events")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(favoriteEvents) { event in
                    EventRow(
                        event: event,
                        isFavorite: true,
                        onFavoriteToggle: {
                            toggleFavorite(event)  // unfavorite the event
                        }
                    )
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Favorite Events")
            }
        }
    }
}

