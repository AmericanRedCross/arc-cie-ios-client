# Cash In Emergencies

Welcome to the Cash in Emergencies app source code.

The app is designed to be a tool for the American Red Cross to distribute cash during emergency situations. The requirement for distributing cash is to follow certain guidelines outlined in documents served by a Document Management System.

## DMSSDK
The `DMSSDK` is attached a submodule of this repository. The `DMSSDK` is the brain of the project that deals with loading the app content structure into models and provides various convenience methods.

## Usage

Clone this repository ensuring that you initialise the DMSSDK submodule.   
For example: `git submodule update --init --recursive`

Open the project in Xcode 9 or greater.

In the info.plist please set `DMSSDKBaseURL` to be your DMS API URL. For example `https://subdomain.domain.com/api/`

Optionally you may set the `GoogleTrackingId` key to enable tracking of Google Analytics events.

Optionally you may set the API key for Fabric to enable crash reporting to your own Fabrics account

The main entry point to the application is the `Main.storyboard`.

The `workflow` section of the app is the main feature, which displays a multi-nested structure of `Directory`s with related documents attached to those directories. These contain the tools and documents necessary for ARC to follow the procedure and protocol to distribute cash in an emergency.

Each feature of the app is split into its own directory. The core view controllers can be found under the `View Controllers` folder of the repository.

## Pre-requisites

This project requires the [DMSDK](https://github.com/3sidedcube/dmssdk-ios-framework/) to function, this can be located in the `DMSSDK` folder.

Xcode 9.0 or higher is required to run this project

The app is built to support iOS 10.0 and greater

## License
This project is released under the BSD 3-Clause License. See [LICENSE](LICENSE) for details.
