## Amazon Location Service Workshop - iOS

Location data is a vital ingredient in today's applications, enabling capabilities ranging from asset tracking to location-based marketing.

With Amazon Location Service, you can easily add capabilities such as maps, points of interest, geocoding, routing, geofences, and tracking to applications. You retain control of your location data with Amazon Location, so you can combine proprietary data with data from the service. Amazon Location provides cost-effective location-based services (LBS) using high-quality data from global, trusted providers Esri and HERE Technologies.

## Architecture Overview
<img src="/images/architecture.png"/> 

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

### Mobile Clients – AWS Amplify

#### Project download and configuration

1.	Follow the instructions [in this link](https://docs.amplify.aws/start/getting-started/installation/q/integration/ios) to install Amplify and configure the CLI.
2.	Clone this code repository

```
git clone git@github.com:rochabr/AmazonLocationDemoiOS.git
```

3.	Switch to the project's folder

```
cd AmazonLocationDemoiOS
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
pod install –repo-update
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

#### Modify your plist files

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

3.	Open the file *info.plist* inside the folder *muster-point-client*. Change the value of the key *TrackerName* and *GeofencesName* to the Tracker name and Geofence collection name created on **Setting up Amazon Location Services**.
	
4.	Open the file **LocationManager.swift* and replace the placeholders below with you Amazon Location tracker name and select the correct regions from the enum *AWSRegionType*.

```swift
let locationManager = CLLocationManager()
    let locationTracker = AWSLocationTracker(trackerName: <YOUR-TRACKER-NAME>,
                                             region: AWSRegionType.<YOUR-REGION>,
                                             credentialsProvider: AWSMobileClient.default())
```

#### Add search capabilities to the iOS app
Add search function
Update variables on mapview
Update variables on contextview
	
### Create the Amazon EventBridge rule

The last piece we need to configure is how we should act when the user crosses a Geofence and generates an **ENTER** or **EXIT** event.

1.	Open the Amazon EventBridge console at https://console.aws.amazon.com/events/
2.	Choose *Create rule*. 
3.	Enter a Name for the rule, and, optionally, a description. 
4.	Under *Define pattern*, choose *Event pattern*. 
5.	Under *Event matching pattern*, choose *Pre-defined pattern by service*. 
6.	In *Service provider*, select *AWS*. Then, in *Service name*, select *Amazon Location Service*. Finally, in *Event type*, select *Location Geofence Event*
7.	Scroll down to *Select targets*, set the target as *Lambda Function*, and set the function you created using the Amplify CLI. If you are following this guide, it should be called **musterPointLocationFunction-dev**.
8.	Click on *Create*. 


	
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

