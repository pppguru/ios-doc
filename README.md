ios-IMYD
========

`master`: [![Build Status](https://www.bitrise.io/app/2314bdf5f25f8939.svg?token=53tcR05Y9McWdhyAJloxtA&branch=master)](https://www.bitrise.io/app/2314bdf5f25f8939)

`qa`: [![Build Status](https://www.bitrise.io/app/2314bdf5f25f8939.svg?token=53tcR05Y9McWdhyAJloxtA&branch=qa)](https://www.bitrise.io/app/2314bdf5f25f8939)

Getting started with the IM Your Doc iOS App Source Code
--------------------------------------------------------

Pre-requisites: recent version of Mac OS with XCode installed

At the the terminal prompt, clone this repo onto your local machine:

    git clone https://github.com/IMYourDoc/iOS-IMYD.git

Make sure you have the Cocoapods you need:
    
cd iOS-IMYD
    pod repo update
    pod install

Open the project in Xcode:

    open IMYourDoc.xcworkspace

You may then build, run, and modify the code as usual in XCode.

When your modifications are ready (meaning they build successfully and all automated tests pass) you can commit the changes to this repository from within Xcode.  From the menus choose Source Control --> Commit.  A diff viewer will appear to illustrate the changes you've made.   Enter a brief commit message that explains your changes, select "Push to remote" then "Commit <n> Files and Push."

*Remember to check that the build completes without errors before committing code changes!*

Continuous Deployment
---------------------

All commits to the `master` branch on Github will trigger:
- QA environment build and deployment via bitrise.io email notification to everyone on ios@imyourdoc.com
- PROD environment build and deployment via TestFlight to whomever is signed up as IMYD TestFlight "Internal Testers"
