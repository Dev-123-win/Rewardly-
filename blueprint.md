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

1.  **Refine Color Scheme**: Update the primary color from `deepPurple` to a more modern `blue`.
2.  **Enhance UI Components**: Increase the elevation and shadow of `Card` widgets to create a "lifted" look.
3.  **Implement User-Friendly Error Handling**:
    *   Add the `connectivity_plus` package to monitor network status.
    *   Create a global, non-intrusive banner to inform the user when they are offline.
4.  **Add Background Texture**: Apply a subtle noise texture to the app's background to enhance the visual design (pending finding a suitable asset or method).
