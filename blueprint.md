# Rewardly App Blueprint

## Overview

Rewardly is a mobile application designed to help businesses create and manage customer loyalty programs. The app allows users to earn points for purchases, redeem rewards, and receive personalized offers. It also includes features for social sharing and referrals.

## Style and Design

The app will adhere to Material Design 3 principles, with a modern and clean aesthetic. The color scheme will be based on a primary color of deep purple, with a vibrant and energetic look and feel. The typography will be based on the Oswald, Roboto, and Open Sans font families, and the app will use a variety of font sizes to create a clear visual hierarchy. The app will also make use of modern, interactive iconography, and UI components such as buttons, text fields, and cards will have a soft, deep shadow to create a sense of depth.

## Features

### Implemented

*   **Authentication:** Users can sign in with Google or create an account with email and password.
*   **Home Screen:** Displays the user's current point balance and a list of available rewards.
*   **Rewards Screen:** Displays a list of available rewards and allows users to redeem them.
*   **Profile Screen:** Allows users to view and edit their profile information.
*   **Referral Screen:** Displays the user's unique referral code and allows users to copy it to their clipboard. The share button has been temporarily removed to resolve analysis errors.
*   **Theming:** The app supports both light and dark themes, and users can toggle between them.
*   **Navigation:** The app uses a bottom navigation bar to allow users to switch between the main screens.
*   **Push Notifications:** The app is configured to receive push notifications.
*   **Remote Config:** The app's title is remotely configurable.

### Current Plan

*   **Reactive Architecture:** I will overhaul the app's architecture to use real-time listeners (`snapshots()`) and a state management solution (`provider`) to dramatically reduce Firestore read costs and improve the user experience.
*   **App Check:** I will implement Firebase App Check to protect the app from abuse.
*   **Budget Alerts:** I will guide the user on how to set up budget alerts in the Google Cloud Console.
