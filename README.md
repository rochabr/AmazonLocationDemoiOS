## Amazon Location Service Workshop - iOS

Location data is a vital ingredient in today's applications, enabling capabilities ranging from asset tracking to location-based marketing.

With Amazon Location Service, you can easily add capabilities such as maps, points of interest, geocoding, routing, geofences, and tracking to applications. You retain control of your location data with Amazon Location, so you can combine proprietary data with data from the service. Amazon Location provides cost-effective location-based services (LBS) using high-quality data from global, trusted providers Esri and HERE Technologies.

## Architecture Overview
<img src="/support/architecture.png"/> 

## Stack
- **Front-end** - SwiftUI, iOS 12+, AWS Amplify for authentication/authorization, AWS SDK for Amazon Location Service APIs
- **Backend** - Amazon Location Service, Amazon EventBridge, Amazon Cognito, Amazon SNS

## Deploying the solution

### Prerequisites

For this walkthrough, you should have the following prerequisites: 

*	An AWS account
*	A MacOS operating system
*	XCode version 11.4 or later
*	Node.js v12.x or later 
*	npm v5.x or later
*	git v2.14.1 or later
*	Cocoapods

### Setting up Amazon Location Services

Let's start by creating a Place Index. Place indexes are used to perform geocoding and reverse-geocoding actions on Amazon Location. We will use it to search for places of interest on our application.
1.	Open the Amazon Location Service console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose *Place indexes*.
3.	Choose *Create place index*.
4.	Fill out the following boxes:
	1. Name – Enter a name for the place index resource. For example, _ExamplePlaceIndex_. Maximum 100 characters. Valid entries include alphanumeric characters, hyphens, periods, and underscores.
	2. Description – Enter an optional description.
5.	Under Data providers, choose an available data provider to use with your place index resource.
6.	Under Data storage options, specify if you intend to store search results from your place index resource.
7.	Under Pricing Plan, choose answers that best fit how you intend to use your place index resource.
8.	(Optional) Under Tags, enter a tag Key and Value. This adds a tag your new place index resource. For more information, see Tagging your resources.
9.	Choose *Create place index*.

The next step of our solution consists of creating a new tracker and geofence collection on Amazon Location Services. Let’s start with the geofence collection:

1.	Open the Amazon Location console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose *Geofence collections*. 
3.	Choose *Create geofence collection*. 
4.	Fill out the following boxes:
    1. Name – Enter a unique name. For example, iOSWorkshopGeofenceCollection. 
    2. Description – Enter an optional description. 
5.	Choose *Create geofence collection*. 

You will now add the geofences that represent your places of interest. These geofences are created using GeoJSON files. You can use tools, such as [geojson.io](https://geojson.io), at no charge, to draw your geofences graphically and save the output GeoJSON file. With the file ready, we can populate our collection:
1.	Open the Amazon Location console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose *Geofence collections*. 
3.	From the Geofence collections list, select the name link for the target geofence collection. 
4.	Under *Geofences*, choose *Create geofences*. 
5.	In the *Add geofences* window, drag and drop your GeoJSON into the window. 
6.	Choose *Add geofences*. 

Our next step is to create a Tracker. This tracker will be used on the iOS client to detect any changes in position that the user generates. These changes are pushed back to Amazon Location Services, which analyzes the position against the geofence collection, previously created. If an ENTER or EXIT events are detected, Amazon EventBridge is triggered.
1.	Open the Amazon Location console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose *Trackers*. 
3.	Choose *Create tracker*. 
4.	Fill out the following boxes:
    1. Name – Enter a unique name.
    2. Description – Enter an optional description. 
5.	Choose *Create tracker*. 


Now that you have a geofence collection and a tracker, you can link them together so that location updates are automatically evaluated against all of your geofences. When device positions are evaluated against geofences, events are generated. We will come back later to to set an action to these events. Let’s link a tracker resource to a geofence collection, first.

1.	Open the Amazon Location console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose Trackers. 
3.	Under *Device trackers*, select the name link of the target tracker. 
4.	Under *Linked Geofence Collections*, choose *Link Geofence Collection*. 
5.	In the *Linked Geofence Collection* window, select a geofence collection from the dropdown menu.
6.	Choose *Link*. 
After you link the tracker resource, it will be assigned an **Active** status. Take note of your **Geofence collection** and **Tracker** names.

### Create the Amazon EventBridge rule

The last piece we need to configure is how we should act when the user crosses a Geofence and generates an **ENTER** or **EXIT** event.

1.	Open the Amazon EventBridge console at https://console.aws.amazon.com/events/
2.	Choose *Create rule*. 
3.	Enter a Name for the rule, and, optionally, a description. 
4.	Under *Define pattern*, choose *Event pattern*. 
5.	Under *Event matching pattern*, choose *Pre-defined pattern by service*. 
6.	In *Service provider*, select *AWS*. Then, in *Service name*, select *Amazon Location Service*. Finally, in *Event type*, select *Location Geofence Event*
7.	Scroll down to *Select targets*, set the target as *CloudWatch log group*, and choose a name for your log group. 
8.	Click on *Create*. 

### Mobile Clients – AWS Amplify

#### Project download and configuration

1.	Follow the instructions [in this link](https://docs.amplify.aws/start/getting-started/installation/q/integration/ios) to install Amplify and configure the CLI.
2.	Clone this code repository

```
git clone git@github.com:rochabr/AmazonLocationDemoiOS.git
```

3.	Switch to the project's folder

```
cd AmazonLocationDemoiOS_base
```

4.	Initialize your project with the CocoaPods package manager by running the following command:

```
pod init 
```

5.	A new file named Podfile will be created. This file is used to describe your project’s packages dependency.

6.	Open the Podfile in a file editor, and add  Amplify and Amazon Location as pod dependencies. When you’re done, your Podfile will look similar to this example:

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'AmazonLocationDemo (iOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AmazonLocationDemo (iOS)
  pod 'AWSLocation' 
  pod 'AWSMobileClient'
end

target 'AmazonLocationDemo (macOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AmazonLocationDemo (macOS)

end
```

4.	Run the following command to install the **AWS Location SDK**:

```
pod install --repo-update
```

4.	Open your project by running on the terminal:

```
xed .
```

#### Init the Amplify project

1.	Initialize the Amplify project by opening a terminal and running:

```
amplify init
```

2.	Enter the following when prompted:

```
? Enter a name for the project
    AmazonLocationDemo
? Enter a name for the environment
    dev
? Choose your default editor:
    Xcode (Mac OS only)
? Choose the type of app that you're building
    ios
Using default provider  awscloudformation
? Select the authentication method you want to use:
    AWS Profile
? Please choose the profile you want to use
    Default
```

Upon successfully running amplify init, you should see two new created files in your project directory: amplifyconfiguration.json and awsconfiguration.json. If the files are not there, they need to be manually moved to your XCode project folder. This is required so that Amplify libraries know how to reach your provisioned backend resources. Make sure that the file target is point to your client projects.

#### Add the Amplify categories

Now that the Amplify project was created, we will add the categories that will complement the project.

1.	Add the authentication category by opening a terminal and running:

```
amplify add auth
```

2.	Enter the following when prompted:

```
? Do you want to use the default authentication and security configuration?
Default configuration
? How do you want users to be able to sign in? 
Username
? Do you want to configure advanced settings? 
No, I am done.
```

3.	Push the changes to the backend by running:

```
amplify push
```

With the auth category configured, we can now configure the Identity Pool to allow unauthenticated access.

#### Configure unauthenticated and authenticated users to allow access to Amazon Location

1.	Navigate to the root of your project and run the following command:

```
amplify console auth
```

2.	Select Identity Pool from *Which console?* when prompted.
3.	You will be navigated to the Amazon Cognito console. Click on *Edit identity pool* in the top right corner of the page.
4.	Open the drop down for *Unauthenticated identities*, choose *Enable access to unauthenticated identities*, and then press *Save Changes*.
5.	Click on *Edit identity pool once more*. Make a note of the name of the Unauthenticated role. For example, *amplify-<project_name>-<env_name>-<id>-unauthRole*.
6.	Open the AWS Identity and Access Management (IAM) console to manage roles.
7.	In the Search field, enter the name of your unauthRole noted above and click on it.
8.	Click *+Add inline policy*, then click on the JSON tab.
9.	Fill in the [ARN] placeholder with the ARN of your tracker which you noted above and replace the contents of the policy with the below.

```json
{
   "Version": "2012-10-17",
   "Statement": [
       {
            "Effect": "Allow",
            "Action": "geo:SearchPlaceIndexForText",
            "Resource": "[ARN]"
        },
        {
            "Effect": "Allow",
            "Action": "geo:BatchUpdateDevicePosition",
            "Resource": "[ARN]"
        }
   ]
}
```

#### Modify your plist files and initiaize the mobile client

Now we have all Amplify categories configured in our project, let’s take a look at the code that is collecting the geofences and tracking the user’s movement. 

1.	Open your project by running on the terminal:

```
xed .
```

2.	Open awsconfiguration.json and add the following lines to the end of the file:

```json
"Location": {
    "Default": {
        "Region": "<REGION ie: us-west-2>"
    }
}
```

3.	Modify *AmazonLocationDemoApp.swift* with the code below to initialize the *AWSMobileClient* SDK with the configuration from *awsconfiguration.json*

```swift
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
```

4.	Build and run the app. 

#### Add search capabilities to the iOS app

1. Add an import statement for *AWSLocation*:

```swift
import AWSLocation
```	
	
2.	On *ContentView.swift*, add the array that will hold the search results at the beginning of the *MapView* struct and pass the array as an argument to the MapView:
	
```swift
@State private var searchLocations = [MKPointAnnotation]()
```	

```swift
MapView(centerCoordinate: $centerCoordinate, searchLocations: searchLocations)
```
	
2.	Add the *searchForLocation* function replacing *<INDEX_NAME>* with the PlaceIndex name that was created by you:
	
```swift
func searchForLocation(search: String){
	//setting bias position to user's location
	let biasPosition = [NSNumber(value: centerCoordinate.longitude), NSNumber(value: centerCoordinate.latitude)]

	//Creating the search request
	let request = AWSLocationSearchPlaceIndexForTextRequest()!
	request.text = search //Search text
	request.indexName = "<INDEX_NAME>" //Index name
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
```
	
3.	On *MapView.Swift* add another reference to the array that will hold the search results:

```swift
var searchLocations: [MKPointAnnotation]
```
4.	Change the *updateUIView* to add the search result markers to the map:

```swift
func updateUIView(_ view: MKMapView, context _: Context) {
	print("updating")
	
	//Add markers to map
	if searchLocations.count != view.annotations.count {
	    view.removeAnnotations(view.annotations)
	    view.addAnnotations(searchLocations)
	}
}
```
	
5.	Build and run the app. Search for a location(ie: Starbucks). The pins should be populated on the map.
	
#### Add tracking capabilities to the iOS app

The below steps describe how you can pass device location to the tracker resource you have created with Amazon Location Service:

1.	Add the following imports to the LocationManagement.swift file:

```swift	
import AWSLocation
import AWSMobileClient
```
	
2.	Create an instance of AWSLocationTracker, and add conformance to AWSLocationTrackerDelegate, updating the tracker name and the region with your own values:

```swift
class LocationManagement: NSObject, 
                          ObservableObject, 
                          CLLocationManagerDelegate, 
                          AWSLocationTrackerDelegate {  // Add AWSLocationTrackerDelegate conformance
    let locationTracker = AWSLocationTracker(trackerName: "<TRACKER_NAME>",
                                            region: AWSRegionType.<REGION_NAME>,
                                            credentialsProvider: AWSMobileClient.default())
}
```
	
By conforming to AWSLocationTrackerDelegate, the requestUserLocation method will be added. You can leave this empty for now, as in the following example:

```swift
func requestLocation() {
}
```

3.	Start tracking the device’s location with AWSLocationTracker. Inside locationManagerDidChangeAuthorization(_) add the following code in the authorized status scenario:

```swift
case .authorizedWhenInUse:
    print("Received authorization of user location, requesting for location")
    let result = locationTracker.startTracking(
        delegate: self,
        options: TrackerOptions(
            customDeviceId: "12345",
            retrieveLocationFrequency: TimeInterval(10),
            emitLocationFrequency: TimeInterval(30)))
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
```
	
Note: Make sure to update the customDeviceId to an assigned deviceId or remove the parameter to have a random device ID assigned for this device. The assigned deviceId will be persisted across app restarts.

Note: The example configures the tracking to retrieve location data every 10 seconds and send the location updates to Amazon Location Service every 30 seconds. The default values are 30 seconds for retrieveLocationFrequency and 300 seconds for emitLocationFrequency.

Note: startTracking should be called after the user has authorized the app to retrieve device location data. Make sure to remove the call to startUpdatingLocation() as that will continuously retrieve a stream of location updates, rather than tracking the location at an interval.

4.	Update the body of requestLocation method by calling locationManager.requestLocation(), as in the following example:

```swift
class LocationManagement: NSObject, ObservableObject, CLLocationManagerDelegate, AWSLocationTrackerDelegate  { 
  // ...
  func requestLocation() {
    locationManager.requestLocation()
  }
  // ...
}
```
	
Note: requestLocation will be called on the retrieveLocationFrequency interval.

5.	When your app retrieves location updates, pass the data for location tracking to update your tracker and continue performing your app logic, as in the following example:

```swift
class LocationManagement: NSObject, ObservableObject, CLLocationManagerDelegate, AWSLocationTrackerDelegate  { 
  // ...
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("Got locations: \(locations)")
    locationTracker.interceptLocationsRetrieved(locations)
  }
  // ...
}
```
	
6.	(Optional) Listen for tracking events to be notified when the tracker sends data to Amazon Location Service and when the tracker has stopped. The following example shows how this can be implemented:

```swift
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
```
	
7.	Pass onTrackingEvent to startTracking()

```swift
let result = locationTracker.startTracking(
                delegate: self,
                options: TrackerOptions(
                    customDeviceId: "12345",
                    retrieveLocationFrequency: TimeInterval(30),
                    emitLocationFrequency: TimeInterval(120)),
                listener: onTrackingEvent)
```
	
Note: onDataPublished will be triggered for each successful call to Amazon Location Service. The trackingPublishedEvent payload contains the request containing locations sent and the successful response from the service.

Note: onDataPublicationError will be triggered for each attempt made to send location data to Amazon Location Service and had failed with an error.

Note: onStop will be triggered when the tracker has been started and stopTracking was called.

8.	(Optional) To debug your app, you can enable verbose logging during development, when the app starts up:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  // Override point for customization after application launch.
  AWSDDLog.sharedInstance.logLevel = .verbose
  AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
  
  //...
  return true
}
```
	
9.	You have now successfully set up AWSLocationTracker in your app. Build an run the app. Check the log group created on CloudWatch for geofencing updates.

10.	Stop tracking: When you want to prevent the tracker from continuing to store and emit location data, call the following method:

```swift
func stopTracking() {
    locationTracker.stopTracking()
}
```
	
11.	Tracking status: You can also check if the tracker is currently tracking by calling the following method:

```swift
func isTracking() -> Bool {
    locationTracker.isTracking()
}
```
	
### Cleaning up

#### Delete Amplify resources
1.	On the terminal, navigate to your project folder and run the following command:

```
amplify delete
```

2.	Select yes, when prompted.

#### Delete Amazon Location Services resources

1.	Open the Amazon Location console at https://console.aws.amazon.com/location/
2.	In the left navigation pane, choose *Geofence collections*. 
3.	Select the Geofence collection you created and click *Delete geofence collection*
4.	Type *delete* in the field and press *Delete*.
5.	In the left navigation pane, choose *Trackers*
6.	Select the Tracker you created and click *Delete tracker*
7.	Type delete in the field and press *Delete*.

#### Delete Amazon Event Bridge resources
1.	Open the Amazon EventBridge console at https://console.aws.amazon.com/events/
2.	Navigate to *Events* -> *Rules*
3.	Select the rule you want to delete.
4.	Click *Delete*.
5.	Click *Delete*, again, when prompted.


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

