//
//  LocationManager.swift
//  AmazonLocationDemo
//
//  Created by Rocha Silva, Fernando on 2021-09-23.
//

import CoreLocation
import AWSLocation
import AWSMobileClient

class LocationManagement: NSObject,
                          ObservableObject,
                          CLLocationManagerDelegate,
                          AWSLocationTrackerDelegate {
    
    
    // Add AWSLocationTrackerDelegate conformance
    let locationTracker = AWSLocationTracker(trackerName: "AmazonLocationDemoTracker",
                                             region: AWSRegionType.USWest2,
                                             credentialsProvider: AWSMobileClient.default())
    
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
            let result = locationTracker.startTracking(
                            delegate: self,
                            options: TrackerOptions(
                                customDeviceId: "12345",
                                retrieveLocationFrequency: TimeInterval(10),
                                emitLocationFrequency: TimeInterval(30)),
                            listener: onTrackingEvent)
            switch result {
            case .success:
                print("Tracking started successfully")
            case .failure(let trackingError):
                switch trackingError.errorType {
                case .invalidTrackerName, .trackerAlreadyStarted, .unauthorized:
                    print("onFailedToStart \(trackingError)")
                case .serviceError(let serviceError):
                    print("onFailedToStart serviceError: \(serviceError)")
                }
            }
        default:
            print("Failed to authorize")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got locations: \(locations)")
        locationTracker.interceptLocationsRetrieved(locations)
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
    
    func onTrackingEvent(event: TrackingListener) {
        switch event {
        case .onDataPublished(let trackingPublishedEvent):
            print("onDataPublished: \(trackingPublishedEvent)")
        case .onDataPublicationError(let error):
            switch error.errorType {
            case .invalidTrackerName, .trackerAlreadyStarted, .unauthorized:
                print("onDataPublicationError \(error)")
            case .serviceError(let serviceError):
                print("onDataPublicationError serviceError: \(serviceError)")
            }
        case .onStop:
            print("tracker stopped")
        }
    }
    
    //Amazon Location Delegate
    func requestLocation() {
        locationManager.startUpdatingLocation()
    }
    
    //Stop tracking
    func stopTracking() {
        locationTracker.stopTracking()
    }
    
    //tracking status
    func isTracking() -> Bool {
        locationTracker.isTracking()
    }
}

