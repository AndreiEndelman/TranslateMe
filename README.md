# Project 6 - TranslationMe

Submitted by: Your Name Here

TranslationMe is an iOS translation app that uses the MyMemory API to translate text and stores translation history with Firestore (with a local fallback when Firebase is not configured).

Time spent: X hours spent in total

## Required Features

The following **required** functionality is completed:

- [x] App opens to a translation home screen with input, translate button, and output area
- [x] User can translate from one language to another with MyMemory API
- [x] Translation history is stored and displayed
- [x] Translation history can be erased

## Stretch Features

The following **stretch** features are implemented:

- [x] Multiple language choices
- [x] Additional UI polish (sectioned layout, loading state, error alerts)

## Video Walkthrough

Add your Loom or screen recording link here.

## Notes

Describe any challenges encountered while building the app.

## Setup Instructions

1. Open `Untitled Project 2.xcodeproj` in Xcode.
2. Add Firebase via Swift Package Manager (`https://github.com/firebase/firebase-ios-sdk`).
3. Add products:
   - `FirebaseCore`
   - `FirebaseFirestore`
4. Add your `GoogleService-Info.plist` file to the `MyApp` target.
5. Build and run.

If Firebase is not configured, the app still runs and stores history locally using `UserDefaults`.
