# Rewardly App Blueprint

## Overview

Rewardly is a mobile application that allows users to earn points by watching ads and playing a game. These points can then be redeemed for rewards. The app also includes a tier system that rewards users for their engagement.

## Features

*   **User Authentication:** Users can create an account and log in using their email and password.
*   **Points System:** Users can earn points by watching ads and playing a game.
*   **Tier System:** Users can progress through three tiers: Bronze, Silver, and Gold. Each tier has its own set of benefits.
    *   **Silver Tier:** 5,000 points OR a 7-day streak.
    *   **Gold Tier:** 10,000 points OR a 30-day streak.
*   **Achievements:** Users can unlock achievements by completing certain tasks.
*   **Admin Panel:** Admins can view user data and manage the app.
*   **Dark Mode:** The app includes a dark mode for users who prefer it.

## Design

*   **Color Scheme:** The app uses a deep purple color scheme.
*   **Typography:** The app uses the Oswald and Roboto fonts.
*   **Iconography:** The app uses Material Design icons.

## Bug Fixes and Improvements

*   **Critical Security Bug: Invalid App Check Key:** Fixed a critical security bug where the Firebase App Check was configured with a placeholder reCAPTCHA key.
*   **Critical Bug: Memory Leak:** Fixed a memory leak in the `AppLifecycleReactor` class.
*   **Poor User Experience: Flawed Navigation:** Re-architected the navigation to use a `StatefulShellRoute`, which provides a more consistent and user-friendly experience.
*   **Critical Bug: Flawed Tier Promotion:** Fixed a critical bug in the tier promotion logic.
*   **Logic Bug: Redundant and Inconsistent Tier Calculation:** Removed redundant tier calculation logic from the `HomeScreen`.
*   **UI Bug: Stale Admin Status:** Implemented `WidgetsBindingObserver` to automatically refresh the user's admin status.
*   **Poor User Experience: SnackBar Spam:** Improved the achievement notification to prevent `SnackBar` spam.
*   **The Race Condition:** Fixed a race condition in the `SplashScreen`.
*   **Redundant Tier Logic:** Moved the tier name and color logic to the `UserTier` model.
*   **Poor UX:** Added a logout button to the `ProfileScreen`.
*   **Inconsistent Design:** Used a `Consumer` widget to get the user's data from the `UserDataProvider`.
*   **Improved UI:** Improved the UI of the `ProfileScreen` to make it more visually appealing and user-friendly.
