//
//  ContentView.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/15/24.
//
//
import SwiftUI
import MapKit
///

struct ContentView: View {
    @State private var events: [Event] = []
    @State private var errorMessage: String?
    @State private var isLoading = true
    @State private var selectedEvent: Event? = nil // Track the selected event
    @AppStorage("favoriteEvents") private var favoriteEventIDsString: String = "" // store favorite event IDs as a comma-separated string

    var favoriteEventIDs: Set<String> {
        get {
            Set(favoriteEventIDsString.split(separator: ",").map { String($0) })
        }
        set {
            favoriteEventIDsString = newValue.joined(separator: ",")
        }
    }

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Use NavigationSplitView for iPad to get the sidebar and detail layout
            NavigationSplitView {
                List(events, selection: $selectedEvent) { event in
                    NavigationLink(value: event) {
                        EventRow(
                            event: event,
                            isFavorite: favoriteEventIDs.contains(event.id),
                            onFavoriteToggle: {
                                toggleFavorite(for: event)
                            }
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("HackIllinois Events")
                .toolbar {
                    NavigationLink(destination: FavoritesView(
                        favoriteEvents: events.filter { favoriteEventIDs.contains($0.id) },
                        toggleFavorite: toggleFavorite
                    )) {
                        Text("Favorites")
                    }
                }
            } detail: {
                if let selectedEvent = selectedEvent {
                    EventDetailView(event: selectedEvent)
                } else {
                    Text("Select an event to see details")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                fetchEvents()
            }
        } else {
            // use regular NavigationView for iPhone and smaller devices
            NavigationView {
                List(events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventRow(
                            event: event,
                            isFavorite: favoriteEventIDs.contains(event.id),
                            onFavoriteToggle: {
                                toggleFavorite(for: event)
                            }
                        )
                    }
                }
                .navigationTitle("HackIllinois Events")
                .toolbar {
                    NavigationLink(destination: FavoritesView(
                        favoriteEvents: events.filter { favoriteEventIDs.contains($0.id) },
                        toggleFavorite: toggleFavorite
                    )) {
                        Text("Favorites")
                    }
                }
            }
            .onAppear {
                fetchEvents()
            }
        }
    }

    func toggleFavorite(for event: Event) {
        var favorites = favoriteEventIDs

        if favorites.contains(event.id) {
            favorites.remove(event.id)
        } else {
            favorites.insert(event.id)
        }

        // update the backing AppStorage value directly
        favoriteEventIDsString = favorites.joined(separator: ",")
    }

    func fetchEvents() {
        guard let url = URL(string: "https://adonix.hackillinois.org/event/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Failed to load events: \(error.localizedDescription)"
                    isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data found"
                    isLoading = false
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(EventContainer.self, from: data)
                DispatchQueue.main.async {
                    events = decodedResponse.events
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }.resume()
    }
}
