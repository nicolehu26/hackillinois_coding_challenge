//
//  MapView.swift
//  IOS HackIllinois
//
//  Created by Nicole Hu on 9/16/24.
//


import SwiftUI
import MapKit

struct MapView: UIViewRepresentable { //allows MapView to be used in SwiftUI app
    var coordinate: CLLocationCoordinate2D //latitude and longitude
    
    func makeUIView(context: Context) -> MKMapView { //called once to create instance to display
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let annotation = MKPointAnnotation() //creates marker
        annotation.coordinate = coordinate
        view.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500, //size of map displayed
            longitudinalMeters: 500
        )
        view.setRegion(region, animated: true)
    }
}

