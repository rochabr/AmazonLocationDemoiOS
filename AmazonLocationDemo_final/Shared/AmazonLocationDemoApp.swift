//
//  AmazonLocationDemoApp.swift
//  Shared
//
//  Created by Rocha Silva, Fernando on 2021-09-23.
//

import SwiftUI
import AWSMobileClient

@main
struct AmazonLocationDemoApp: App {
    
    init() {
        configureAWSMobileClient()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    func configureAWSMobileClient() {
        AWSMobileClient.default().initialize { (userState, error) in
                if let userState = userState {
                    print("UserState: \(userState.rawValue)")
                } else if let error = error {
                    print("error: \(error.localizedDescription)")
                }
            }
        }
}
