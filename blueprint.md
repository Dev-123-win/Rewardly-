# Rewardly: App Blueprint

## Overview

Rewardly is a Flutter-based mobile application that allows users to earn points by watching rewarded ads. These points can then be exchanged for real-world rewards. The app is designed with a clean, modern interface and leverages Firebase for authentication, data storage, and administration.

## Key Features

- **User Authentication**: Secure sign-up and login functionality using Firebase Authentication.
- **Rewarded Ads**: Integration with Google Mobile Ads to allow users to watch ads and earn points.
- **Point System**: A simple point-based system where users accumulate points for each ad watched.
- **Withdrawal System**: Users can request withdrawals of their earned points.
- **Withdrawal History**: Users can view a history of their past withdrawal requests, including the status of each request (pending, approved, or denied).
- **Admin Panel**: A dedicated screen for administrators to review and manage pending withdrawal requests.
- **Admin Withdrawal History**: Administrators can view a complete history of all withdrawal requests, including those that have been approved or denied.

## Technical Implementation

- **Frontend**: The app is built with Flutter, providing a cross-platform solution for both Android and iOS.
- **Backend**: Firebase is used for all backend services, including:
    - **Authentication**: Manages user accounts and secures access to the app.
    - **Cloud Firestore**: Stores user data, including points and withdrawal requests.
- **Routing**: The app uses the `go_router` package for declarative navigation, ensuring a clean and organized routing structure.
- **State Management**: The `provider` package is used for simple, efficient state management.
- **Theming**: A custom theme is implemented with support for both light and dark modes, providing a consistent and visually appealing user experience.

## Current Status

The application is in a stable state with all major features implemented. The codebase has been thoroughly analyzed and all errors and warnings have been resolved. The next steps will involve further testing, bug fixing, and the addition of new features as required.
