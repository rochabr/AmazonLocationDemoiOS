//
//  ContentView.swift
//  Shared
//
//  Created by Rocha Silva, Fernando on 2021-09-23.
//

import SwiftUI
import MapKit
import AWSLocation

struct ContentView: View {
    
    @State private var locationSearch: String = ""
    @State private var isEditing = false
    
    let locationManagement = LocationManagement()
    @State private var centerCoordinate = CLLocationCoordinate2D()
    
    //Annotation array
    @State private var searchLocations = [MKPointAnnotation]()
        
    var body: some View {
        VStack {
            MapView(centerCoordinate: $centerCoordinate, searchLocations: searchLocations)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                TextField(
                    "Search for a location",
                     text: $locationSearch
                ) { isEditing in
                    self.isEditing = isEditing
                } onCommit: {
                    searchForLocation(search: locationSearch)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .border(Color(UIColor.separator))
                
            }
            .padding()
        }
    }
    
    func searchForLocation(search: String){
        //setting bias to downtown Vancouver
        let biasPosition = [NSNumber(value: centerCoordinate.longitude), NSNumber(value: centerCoordinate.latitude)]
        
        //Creating the search request
        let request = AWSLocationSearchPlaceIndexForTextRequest()!
        request.text = search //Search text
        request.indexName = "MyHereIndex" //Index name
        request.biasPosition = biasPosition //Adding bias to filter the results to a region
        request.maxResults = 10 //setting maximum results to 10
        
        //API Call
        let result = AWSLocation.default().searchPlaceIndex(forText: request)
        result.continueWith { (task) -> Any? in
            if let error = task.error {
                print("error \(error)")
            } else if let taskResult = task.result {
                print("taskResult \(taskResult)")
                var searchLocations = [MKPointAnnotation]()
                for result in taskResult.results! {
                    let lon = (result.place?.geometry?.point![0]) as! Double
                    let lat = (result.place?.geometry?.point![1]) as! Double
                    
                    //Creating new Annotation based on the search response
                    let newLocation = MKPointAnnotation()
                    newLocation.title = result.place?.label
                    newLocation.subtitle = result.place?.addressNumber
                    newLocation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    searchLocations.append(newLocation)
                }
                
                //Updating array
                self.searchLocations = searchLocations
            }
            return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

