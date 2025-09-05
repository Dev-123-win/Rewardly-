# Application Blueprint

## Overview

This document outlines the architecture, features, and design of the rebuilt Flutter application. The goal is to create a scalable, maintainable, and visually appealing application following modern best practices.

## Project Structure (Feature-First)

The project will be organized by feature to improve scalability and code organization.

```
lib/
|-- main.dart
|-- app/
|   |-- theme/
|   |   |-- theme_provider.dart
|   |   |-- app_theme.dart
|   |-- routing/
|   |   |-- app_router.dart
|-- features/
|   |-- auth/
|   |   |-- data/
|   |   |-- domain/
|   |   |-- presentation/
|   |       |-- screens/
|   |       |-- widgets/
|   |-- home/
|   |   |-- presentation/
|   |       |-- screens/
|   |       |-- widgets/
|-- core/
    |-- widgets/
    |-- utils/
```

## Phase 1: Foundational Setup (Current Plan)

1.  **Clear Existing Code:** Remove the old `lib` directory to start fresh. (Done)
2.  **Establish Core Structure:**
    *   Create a new `lib` directory.
    *   Add `provider` and `google_fonts` packages for state management and typography.
    *   Create `lib/main.dart` as the application entry point.
3.  **Implement Theming:**
    *   Create a `ThemeProvider` to manage light/dark modes.
    *   Define a `ThemeData` using `ColorScheme.fromSeed` for a Material 3 theme.
    *   Use `google_fonts` for custom typography.
4.  **Implement Basic UI:**
    *   Create a simple `HomeScreen` with a placeholder UI.
    *   Set up the `MaterialApp` to use the defined theme and provider.

## Future Phases

*   **Authentication:** Implement login and registration screens using Firebase Authentication.
*   **Routing:** Integrate `go_router` for declarative navigation.
*   **Feature Development:** Re-implement the original application's features within the new architecture.
