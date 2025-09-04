# Rewardly App Blueprint

## Overview

Rewardly is a mobile application for Android and web that allows users to earn rewards, likely through activities like playing games or completing tasks. Users can manage their earnings, view their achievements, and withdraw their rewards. The app is monetized through ads and uses a comprehensive suite of Firebase services for its backend, security, and dynamic configuration.

## Features

*   **User Authentication:** Login and Registration screens.
*   **Home Screen:** Main dashboard for the user.
*   **Profile Screen:** User profile management.
*   **Game Screen:** A screen dedicated to a game for earning rewards.
*   **Achievements:** A screen to display user achievements.
*   **Referral Program:** A system for users to refer others.
*   **Withdrawals:** Screens for managing and viewing withdrawal history.
*   **Admin Panel:** A dedicated screen for administrative purposes.
*   **Theming:** Light and dark mode support.
*   **Offline Support:** A banner indicates when the user is offline.

## Architecture & Design

*   **State Management:** `provider`
*   **Navigation:** `go_router`
*   **Backend:** Firebase (Core, App Check, Remote Config)
*   **Monetization:** Google Mobile Ads (App Open Ads)
*   **UI:** Material 3 with custom theming, `google_fonts` for typography, and a `NoiseBackground` for a textured look.
*   **Connectivity:** Uses `connectivity_plus` to handle offline states.

## Identified Issues and Fixes

### 1. Missing Game Assets

*   **Issue:** The `GameScreen` was trying to load an "Endless Runner" game from `assets/endless_runner_game/`, but this directory and its contents were missing from the project. The `pubspec.yaml` file also contained incorrect references to subdirectories within this missing folder.
*   **Fix:**
    1.  Created a placeholder `index.html` file within a new `assets/endless_runner_game/` directory to prevent the app from crashing.
    2.  Corrected the `pubspec.yaml` file to properly include the `assets/endless_runner_game/` directory.
    3.  Ran `flutter pub get` to update the project with the new asset configuration.
*   **Next Steps:** The placeholder game should be replaced with the actual game. The logic for communicating the player's score from the web game to the Flutter app for reward processing is still missing and needs to be implemented.

### 2. App Stuck on Splash Screen

*   **Issue:** The `SplashScreen` had a fixed 3-second delay and then unconditionally navigated to the home screen (`/`). This caused the app to hang if the user was not authenticated.
*   **Fix:**
    1.  Modified `lib/splash_screen.dart` to listen for changes in the Firebase Authentication state.
    2.  If the user is logged in, the app now navigates to the home screen (`/`).
    3.  If the user is logged out, the app now navigates to the login screen (`/login`).

### 3. Sluggish Post-Login Navigation

*   **Issue:** After a successful login, the app did not immediately navigate to the home screen. It waited for the splash screen's authentication listener to fire, creating a noticeable delay.
*   **Fix:** Added an explicit `context.go('/')` call within the `_login` function in `lib/screens/login_screen.dart` to ensure immediate navigation to the home screen after a successful login.

### 4. Case-Sensitive Referral Codes

*   **Issue:** The registration screen performed a case-sensitive check for referral codes. This would cause a valid code to be rejected if the user entered it in a different case (e.g., `abcde123` instead of `ABCDE123`).
*   **Fix:** Converted the entered referral code to uppercase in `lib/screens/register_screen.dart` before querying Firestore, making the check case-insensitive.

### 5. Discarded Game Rewards

*   **Issue:** A race condition in `home_screen.dart` could cause a player's game rewards to be discarded if they were received while a rewarded ad was being shown.
*   **Fix:** Implemented a queuing system. Game rewards received during an ad are now stored in a temporary variable and processed after the ad is dismissed, preventing any loss of rewards.

### 6. Flawed Tier Promotion Logic

*   **Issue:** The tier promotion logic in `user_data_provider.dart` used an `if/else if` structure, which prevented users from being promoted more than one tier at a time, even if they met the requirements.
*   **Fix:** Replaced the `if/else if` with two separate `if` statements to ensure that all promotion conditions are checked independently within the same transaction.

### 7. Inefficient Ad Loading

*   **Issue:** The ad service only loaded a new ad after the previous one was dismissed, creating a delay and potential for lost revenue.
*   **Fix:** Implemented a more robust ad loading strategy that loads a new ad immediately after one is shown, ensuring that an ad is always available.

### 8. Duplicate Achievement Icons

*   **Issue:** The `silver_tier` and `gold_tier` achievements used the same icon, which could cause confusion.
*   **Fix:** Changed the icon for the `silver_tier` achievement to `Icons.shield_outlined` to provide a clear visual distinction.

### 9. Critical Admin Panel Vulnerabilities

*   **Issue:** The `AdminScreen` had no access control, allowing any user to access it. It also had a UI flaw that could lead to admins locking themselves out, an inefficient search, and memory leaks.
*   **Fix:**
    1.  **Access Control:** Added a check to ensure only authorized administrators can access the admin panel.
    2.  **Self-Revocation Prevention:** Disabled the ability for an admin to revoke their own privileges.
    3.  **Optimized Search:** Implemented a debounce to the search functionality to reduce unnecessary Firestore reads.
    4.  **Memory Leak Fix:** Properly disposed of the `TextEditingController`.

### 10. Broken Navigation Model

*   **Issue:** The app used a mix of `go_router` and a manual `BottomNavigationBar`, leading to state mismatches, broken deep linking, and UI glitches.
*   **Fix:** Refactored the navigation to use a `StatefulShellRoute`, which is the correct way to implement a `BottomNavigationBar` with `go_router`, creating a unified and robust navigation system.

### 11. Unnecessary Startup Delay and Lack of Feedback

*   **Issue:** The splash screen had an unnecessary 500ms delay and lacked a loading indicator, making the app feel slow and unresponsive at startup.
*   **Fix:** Removed the artificial delay and added a `CircularProgressIndicator` to provide immediate feedback to the user, improving the perceived startup time.

### 12. Improved Login Screen UX and Memory Management

*   **Issue:** The login screen lacked a password visibility toggle, leading to a frustrating user experience. It also suffered from memory leaks due to undisposed `TextEditingController`s.
*   **Fix:** Added a password visibility toggle to the password field and ensured that all `TextEditingController`s are properly disposed of, improving both UX and performance.

### 13. Improved Registration Screen UX and Efficiency

*   **Issue:** The registration screen lacked password visibility toggles, had inefficient referral code logic, and suffered from memory leaks.
*   **Fix:** Added password visibility toggles, optimized the referral code logic to prevent unnecessary database reads, and ensured all `TextEditingController`s are properly disposed of.

### 14. Critical `HomeScreen` Overhaul

*   **Issue:** The `HomeScreen` suffered from critical memory leaks, a broken navigation button, inconsistent user feedback, and overly complex code.
*   **Fix:**
    1.  **Eliminated Memory Leaks:** Ensured all resources, including the `WebViewController` and ads, are properly managed and disposed of.
    2.  **Fixed Broken Navigation:** Corrected the navigation to point to the correct "How It Works" screen.
    3.  **Provided Clear User Feedback:** Implemented robust error handling to ensure users are always informed of what's happening with their rewards.
    4.  **Simplified and Streamlined Code:** Refactored the ad and reward logic to be more efficient, readable, and maintainable.
