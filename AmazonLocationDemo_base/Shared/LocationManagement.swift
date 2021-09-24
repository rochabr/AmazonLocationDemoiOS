//
//  LocationManager.swift
//  AmazonLocationDemo
//
//  Created by Rocha Silva, Fernando on 2021-09-23.
//

import CoreLocation

class LocationManagement: NSObject, ObservableObject, CLLocationManagerDelegate {
let locationManager = CLLocationManager()

override init() {
  super.init()
  requestUserLocation()
}

func requestUserLocation() {
  // Set delegate before requesting for authorization
  locationManager.delegate = self
  // You can request for `WhenInUse` or `Always` depending on your use case
  locationManager.requestWhenInUseAuthorization()
}

func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedWhenInUse:
        print("Received authorization of user location, requesting for location")
        locationManager.startUpdatingLocation()
    default:
        print("Failed to authorize")
    }
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      print("Got locations: \(locations)")
}

// Error handling is required as part of developing using CLLocation
func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      if let clErr = error as? CLError {
          switch clErr {
          case CLError.locationUnknown:
              print("location unknown")
          case CLError.denied:
              print("denied")
          default:
              print("other Core Location error")
          }
      } else {
          print("other error:", error.localizedDescription)
      }
  }
}
