//
//  ContentView.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/15/24.
//
//
import SwiftUI
///

struct ContentView: View {
    //@State allows view to modify values of private vars in view
    @State private var events: [Event] = []
    @State private var errorMessage: String?
    @State private var isLoading = true
    @State private var selectedEvent: Event? = nil // track the selected event
    //@AppStorage writes data to UserDefaults
    @AppStorage("favoriteEvents") private var favoriteEventIDsString: String = "" // store favorite event IDs as a comma-separated string

    var favoriteEventIDs: Set<String> {
        get {  //convert favorite eventIds into set by splitting at commas
            Set(favoriteEventIDsString.split(separator: ",").map { String($0) })
        }
        set { //convert set back to string
            favoriteEventIDsString = newValue.joined(separator: ",")
        }
    }

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad { //ipad view
            // Use NavigationSplitView for iPad to get the sidebar and detail layout
            NavigationSplitView { //sidebar
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
                    NavigationLink(destination: FavoritesView( //favorites tab
                        favoriteEvents: events.filter { favoriteEventIDs.contains($0.id) }, //only list events marked as favorites
                        toggleFavorite: toggleFavorite
                    )) {
                        Text("Favorites")
                    }
                }
            } detail: {
                if let selectedEvent = selectedEvent {
                    EventDetailView(event: selectedEvent)
                } else {
                    Text("Select an event to see details") //if no event selected
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                fetchEvents()
            }
        } else {
            // use regular NavigationView for iphone, no splitview
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
            favorites.remove(event.id) //unfavorite
        } else {
            favorites.insert(event.id) //favorite
        }

        // update new set of ids in string form
        favoriteEventIDsString = favorites.joined(separator: ",")
    }

    func fetchEvents() { //HTP GET request using HackIllinois API url
        //url is API endpoint to return event data
        guard let url = URL(string: "https://adonix.hackillinois.org/event/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        //sending get request to url
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Failed to load events: \(error.localizedDescription)"
                    isLoading = false
                }
                return
            }
            
           //after request, check if data returned by API
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data found"
                    isLoading = false
                }
                return
            }
            //decode data into Swift object into EventContainer, array of event objects
            do {
                let decodedResponse = try JSONDecoder().decode(EventContainer.self, from: data)
                DispatchQueue.main.async {
                    //UI updates must be dispatched back to main threat after data decoded
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
