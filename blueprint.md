# Project Blueprint

## Overview

This document outlines the style, design, and features of the Rewardly Flutter application. It serves as a single source of truth for the application's current state and future development plans.

## Style and Design

*   **Theming**: The app uses a Material 3 theme with a centralized `ThemeData` object. It supports both light and dark modes with a theme toggle.
*   **Color Scheme**: A modern and energetic color palette is generated from a primary seed color. The primary color is a vibrant blue.
*   **Typography**: The app uses the `google_fonts` package for a clean and readable look, with `Roboto Slab` for display/headline styles and `Inter` for body text.
*   **UI Components**: Cards have a prominent shadow to create a "lifted" effect. Interactive elements have a subtle glow.
*   **Background**: A subtle noise texture is applied to the main background for a premium, tactile feel.

## Features

*   **User Authentication**: Users can sign up, log in, and log out using Firebase Authentication.
*   **Home Screen**: Displays the user's current point balance and provides navigation to other screens.
*   **Profile Screen**: Shows the user's email, point balance, and provides links to withdrawal actions.
*   **Store Screen**: A grid view of items that can be redeemed with points.
*   **Withdrawal Screen**: A form for users to request a withdrawal of their points.
*   **Withdrawal History**: A list of past withdrawal requests with their status.
*   **Routing**: The app uses the `go_router` package for declarative navigation and deep linking.

## Current Plan

### Tiered Rewards and Store

1.  **Introduce User Tiers**: Create a tier system (e.g., Bronze, Silver, Gold) based on user points.
2.  **Tier-Based Rewards**: Adjust the number of points earned from watching ads based on the user's tier.
3.  **Exclusive Store Items**: Add a `requiredTier` to store items, making some items exclusive to higher-tier users.
4.  **UI Enhancements**: Display the user's tier on the profile and home screens.

### Referral System

1.  **Generate Referral Codes**: Create a unique referral code for each user.
2.  **Share Functionality**: Allow users to share their referral codes.
3.  **Reward Referrals**: Implement a system to reward both the referrer and the new user upon successful referral.

### Push Notifications and Remote Config

1.  **Firebase Cloud Messaging**: Set up push notifications to alert users about new rewards, promotions, and successful referrals.
2.  **Firebase Remote Config**: Use Remote Config to dynamically adjust reward values and feature flags without releasing a new version of the app.
