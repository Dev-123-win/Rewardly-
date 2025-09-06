# Project Blueprint

## Overview

This document outlines the architecture, features, and design of the Rewardly application. Rewardly is a mobile application that allows users to earn points by completing tasks, such as watching ads and checking in daily. Users can then redeem their points for rewards.

The architecture has been **fully optimized** to be scalable and cost-effective, with a focus on minimizing Firestore usage to support up to 10,000 daily active users within the Firebase free "Spark" plan.

## Core Optimization Strategy: Single Document Listener

The foundation of the app's efficiency is a global `UserDataProvider`.

1.  **Single Real-time Listener:** On app start, after a user logs in, the app attaches **one single, persistent real-time listener** (`.snapshots()`) to their document in the `users/{userId}` collection.
2.  **In-Memory Caching:** This user data is cached in the `UserDataProvider`.
3.  **Zero-Read Access:** All parts of the app (Home screen, Check-in, Watch & Earn, etc.) read user data (points, streak) directly from this in-memory cache, **not** from Firestore. This reduces dozens of potential reads per session down to just **one**.
4.  **Client-Side Logic:** All business logic (calculating streaks, ad cooldowns) is performed on the client, with actions validated on the backend by Firestore Security Rules.

## Features

### Implemented

*   **Authentication:** Users can sign up and log in.
*   **Optimized Home Screen:** Displays the user's points and streak from the global `UserDataProvider` with zero reads.
*   **Optimized Daily Check-in:**
    *   Reads streak and last check-in data from the in-memory cache.
    *   Performs a **single batched write** to update the user's profile and create a check-in record.
    *   Efficiently queries only the visible month's check-in markers.
*   **Optimized Watch & Earn:**
    *   Manages ad cooldowns and daily limits entirely on the client-side, based on data from the global provider.
    *   Performs a **single atomic write** to grant points and update ad-watching timestamps.
*   **Theme Toggle:** Users can switch between light and dark mode.

### Current Plan

All core optimizations for handling 10,000 DAU on the free tier are **complete**. The app is now ready for deployment.

## Design

*   **UI/UX:** The application uses a modern and clean design, with a focus on user experience. The UI is animated to make it more engaging.
*   **Theme:** The application supports both light and dark mode.
*   **Routing:** The application uses the `go_router` package for navigation.

## Architecture

*   **State Management:** The application uses the `provider` package for state management, centered around the global `UserDataProvider`.
*   **Backend:** The application uses Firebase for authentication and as a backend.

### Firestore Data Modeling

*   **`users/{userId}` Collection:** The single source of truth for all frequently accessed data.
    *   `points`: (number)
    *   `streak`: (number)
    *   `lastCheckIn`: (timestamp)
    *   `tier`: (string)
    *   `referralsCount`: (number)
    *   `lastAdWatchedTimestamp`: (timestamp)
    *   `adsWatchedToday`: (number)

*   **`daily_check_ins/{checkInId}` Collection:** Stores individual check-in records for the calendar view.

## Security

### Firestore Security Rules

Since most logic is client-side, the Firestore rules are the ultimate source of truth and security.

*   **Own Data Only:** Users can only read and write their own documents.
*   **Transactional Validation:** All write operations are heavily scrutinized to prevent cheating.
    *   **Check-in:** Rules validate that a `streak` is only incremented by 1 and that `points` are increased by a valid, calculated amount.
    *   **Watch & Earn:** Rules enforce the 30-second cooldown between ads and ensure points are only incremented by the correct reward amount.
    *   **Timestamps:** All time-based updates (`lastCheckIn`, `lastAdWatchedTimestamp`) are forced to use the secure `request.time` server timestamp.

## Deployment

### Android App Signing

To release the Android app, it must be digitally signed with a key. This ensures that you are the authentic developer of the app and that your app hasn't been tampered with.

#### Generating a Keystore

A private signing key was generated using the `keytool` command:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

This created a `upload-keystore.jks` file in the `android/app` directory.

#### Configuring Gradle for Release Builds

To automate the signing process, a `key.properties` file was created in the `android` directory (and added to `.gitignore` to keep it out of version control):

```
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=upload
storeFile=app/upload-keystore.jks
```

The `android/app/build.gradle.kts` file was configured to read these properties and use them to sign the release build.

#### Building the Release APK

With the signing configuration in place, the release APK was built using the following command:

```bash
flutter build apk --release
```

This generated a signed APK at `build/app/outputs/flutter-apk/app-release.apk`.
