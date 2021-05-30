# Sluggo-iOS
This repository will hold the source code for the iOS client for the Sluggo
issue tracker. It is currently beign developed for CSE 115A at UCSC, and will
eventually expand into a fully maintained frontend for the Sluggo project.


## About Sluggo
Sluggo is an open source Issue Tracker for companies, teams, and more. The software is selfhosted, and decentralized in a way that any team can spin up their own instance in minutes! The program started within CSE 183 Spring quarter 2020, and has since had multiple rewrites and expansions. From the [Single Page Application built in Vue](https://github.com/Slugbotics/Sluggo-SPA) as a web based front end, to the [Django REST Application](https://github.com/Slugbotics/Sluggo-API) as the backend, there have also been other expansions such as a [Slack Extension](https://github.com/Slugbotics/Sluggo-Slack) and now an iOS app.

## Installing the API:
*Note: If you are using the SPA, the login process is simpler*
1) Before using the Sluggo iOS application, make sure to install the backend API following the instructions on the [repository here](https://github.com/Slugbotics/Sluggo-API).
2) After completing the installation process, proceed to the admin dashboard (default `127.0.0.8:8000/admin`) and sign on with your super user account that you just created.
3) In this page, you will be able to create a record for your Team by selecting `Team` on the admin page, and hitting the `Add Team` button in the top right. Just give the team a name and hit save.
4) Finally, after creating your team go through the same process and create a `Member` record for yourself on the Member page through the `Add Member` button on your top right. Set you user role as admin, select your team, and fill out any optional fields such as pronouns or Bio, then hit save.


## SwiftLint
The development of Sluggo uses SwiftLint to standardize all changes and coding styles, if you are contributing to Sluggo, please follow the installation instructions for SwiftLint [here](https://github.com/realm/SwiftLint).

## Installing the Application
*Note: Once the app is placed on the App Store, the installation process is much simpler*
1) Clone this repository on a Mac device with Xcode installed.
    - Preferably this is on the same device as the API. Otherwise, you must have the API acessable on your network with a public IP.
3) Open the repository in Xcode, and select build.
4) After this, your app is ready to run, configure your device and then select Run.
    - If you have an apple device you would like to test on, follow [Apple's instruction on running apps on your phone](https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator-or-on-a-device).
    - Otherwise you may use one of the built in simulators on XCode

## Running the App
1) When launching the app for the first time, fill in your user name and password for your sluggo instance.
2) Your Sluggo instance is the url of the API, make sure to have the entire path listed for example: `http://127.0.0.1:8000/`
3) You will be dropped in the team select page, where you may choose any team your account is apart of. Once you have picked one the homepage will appear. Feel free to poke around!


