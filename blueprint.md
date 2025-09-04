# Rewardly App Blueprint

## Overview

Rewardly is a mobile application designed to reward users for watching ads and playing games. It incorporates a tiered system, daily tasks, and a referral program to engage and retain users. The app also includes administrative features for managing user data and application settings.

## Features

### User Features

*   **Authentication:** Users can sign up and log in using their email and password.
*   **Points System:** Users earn points for watching ads and playing games.
*   **Tier System:** Users can progress through different tiers (e.g., Bronze, Silver, Gold) based on their point accumulation.
*   **Daily Tasks:** Users are encouraged to watch a certain number of ads daily to maintain a streak and earn bonus points.
*   **Withdrawal System:** Users can withdraw their earnings through various methods.
*   **Referral Program:** Users can refer others to the app and earn rewards.
*   **Achievements:** Users can unlock achievements by completing specific milestones.
*   **Profile Management:** Users can view their profile, points, tier, and other relevant information.
*   **Informational Screens:** The app includes screens for "About Us," "How It Works," "Terms of Service," and "Privacy Policy."

### Admin Features

*   **Admin Panel:** A dedicated screen for administrators to manage the app.
*   **User History:** Admins can view user withdrawal history and other relevant data.

### Technical Features

*   **Firebase Integration:** The app uses Firebase for authentication, database (Firestore), and remote configuration.
*   **Ad Integration:** The app integrates with an ad service to display rewarded and rewarded interstitial ads.
*   **Push Notifications:** The app uses a notification service to send push notifications to users.
*   **State Management:** The app uses the `provider` package for state management.
*   **Routing:** The app uses the `go_router` package for navigation.
*   **Theming:** The app includes a theme provider to manage the visual theme of the application.

