//
//  ContentView.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/15/24.
//
//
import SwiftUI
import Combine
import CoreLocation
import MapKit
////import SwiftUI
///

struct ContentView: View {
    @State private var events: [Event] = []
    @State private var errorMessage: String?
    @State private var isLoading = true
    @State private var selectedEvent: Event? = nil // Track the selected event
    @AppStorage("favoriteEvents") private var favoriteEventIDsString: String = "" // Store favorite event IDs as a comma-separated string

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
                    NavigationLink(destination: FavoritesView(favoriteEvents: events.filter { favoriteEventIDs.contains($0.id) })) {
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
            // Use regular NavigationView for iPhone and smaller devices
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
                    NavigationLink(destination: FavoritesView(favoriteEvents: events.filter { favoriteEventIDs.contains($0.id) })) {
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

        // Update the backing AppStorage value directly
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
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter.string(from: date)
    }
}

struct EventDetailView: View {
    let event: Event
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Display the event name in the body instead of the navigation title to prevent truncation
                Text(event.name)
                    .font(.title)
                    .bold()
                    .lineLimit(nil) // Allow unlimited lines
                    .fixedSize(horizontal: false, vertical: true) // Prevent truncation
                
                Text(event.info)
                    .font(.body)
                    .padding(.vertical)
                    .lineLimit(nil) // Allow unlimited lines
                    .fixedSize(horizontal: false, vertical: true) // Prevent truncation
                
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
            .padding(.horizontal, horizontalSizeClass == .regular ? 50 : 20) // Add horizontal padding for iPad (regular size class)
            .padding(.vertical)
        }
        .navigationTitle(event.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func formatDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter.string(from: date)
    }
}
// MARK: - FavoritesView
struct FavoritesView: View {
    let favoriteEvents: [Event]

    var body: some View {
        VStack {
            if favoriteEvents.isEmpty {
                Text("No favorite events")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(favoriteEvents) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventRow(
                            event: event,
                            isFavorite: true,
                            onFavoriteToggle: {}
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Favorite Events")
            }
        }
    }
}

// MARK: - MapView for Google Maps Integration
struct MapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        view.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        view.setRegion(region, animated: true)
    }
}

// MARK: - Event Model
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

        // Conformance to Equatable (required by Hashable)
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
