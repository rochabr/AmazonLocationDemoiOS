//
//  MapView.swift
//  AmazonLocationDemo
//
//  Created by Rocha Silva, Fernando on 2021-09-23.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    
    @Binding var centerCoordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true

        mapView.delegate = context.coordinator

        return mapView
    }

    func updateUIView(_ view: MKMapView, context _: Context) {
        print("updating")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }

        func mapView(_ mapView: MKMapView, didUpdate _: MKUserLocation) {
            mapView.userTrackingMode = .follow
        }
    }
}
