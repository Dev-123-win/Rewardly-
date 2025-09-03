# Rewardly App Blueprint

## Overview

Rewardly is a mobile application that allows users to earn points by watching ads and playing games. These points can then be redeemed for real-world rewards. The app is designed with a gamified experience, featuring user tiers, daily streaks, and achievements to keep users engaged.

## Features

### Core

- **Authentication:** Users can sign up and log in using email and password, with secure authentication handled by Firebase Auth.
- **Points System:** Users earn points for various in-app actions, such as watching ads or playing games.
- **Ad Integration:** The app integrates with Google Mobile Ads to display rewarded and rewarded interstitial ads.
- **Gamification:**
  - **User Tiers:** Users can progress through Bronze, Silver, and Gold tiers, earning more points per ad at higher tiers.
  - **Daily Streaks:** Users are encouraged to complete daily goals to maintain a streak and earn rewards.
  - **Achievements:** Users can unlock achievements by reaching certain milestones.
- **Game:** An endless runner game is integrated into the app, allowing users to collect coins that can be converted into points.
- **Withdrawals:** Users can withdraw their earned points for real rewards.
- **Referrals:** Users can refer friends to earn bonus points.

### UI/UX

- **Dynamic Theme:** The app features a modern, dynamic theme with both light and dark modes, and user-facing controls to switch between them.
- **"How It Works" Page:** A dedicated screen explains the app's features and reward system.
- **Noise Background:** A subtle noise texture is applied to the main background for a premium feel.
- **Custom Fonts:** The app uses Google Fonts for a unique and visually appealing typography.
- **Responsive Design:** The app is designed to be responsive and adapt to different screen sizes.
- **About and Legal:**
    - An "About" screen provides links to the app's legal documents.
    - Includes a "Privacy Policy" and "Terms & Conditions" that are displayed from markdown files.
    - Links to these documents are available on the Home, Login, and Register screens.

### Admin

- **Admin Panel:** A dedicated admin panel allows administrators to manage users and other app settings.

## Current Plan

### Added About and Legal Screens
- **Created Markdown Files:** Added `PRIVACY_POLICY.md` and `TERMS_AND_CONDITIONS.md` to the project root.
- **Updated Assets:** Included the new markdown files in the `pubspec.yaml` to be bundled with the app.
- **Document Viewer:** Created a reusable `DocumentScreen` to render and display the content of the markdown files.
- **About Screen:** Implemented an `AboutScreen` that serves as a hub, providing navigation to the legal documents.
- **Routing:** Updated the application's router (`GoRouter`) to include new routes for the `/about`, `/privacy`, and `/terms` pages.
- **UI Integration:**
    - Added an "About" icon to the app bar on the `HomeScreen` for easy access.
    - Included links to the "Privacy Policy" and "Terms of Service" on both the `LoginScreen` and `RegisterScreen` to ensure users can review them before creating an account or logging in.
- **Redirect Logic:** Updated the router's redirect logic to ensure that the new legal pages are accessible to unauthenticated users.
