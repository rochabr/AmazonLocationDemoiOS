//
//  ContentView.swift
//  Shared
//
//  Created by Rocha Silva, Fernando on 2021-09-23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var locationSearch: String = ""
    @State private var isEditing = false
    
    let locationManagement = LocationManagement()
    @State private var centerCoordinate = CLLocationCoordinate2D()
        
    var body: some View {
        VStack {
            MapView()
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
        print(search)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

