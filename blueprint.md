
# Blueprint: Rewardly App Optimization

This document outlines the plan to refactor the Rewardly application to improve its robustness, efficiency, and scalability, ensuring it operates within the Firebase Spark Plan's free tier limits for up to 5,000 daily active users.

## 1. Project Overview
**Purpose:** To create a stable and scalable "watch-to-earn" mobile application that leverages Firebase services efficiently.

### Implemented Features (Summary):
- **Authentication:** Firebase Auth for user sign-in.
- **UI:** Flutter-based, with screens for home, watch & earn, profile, and redeeming rewards.
- **State Management:** `provider` package for managing application state.
- **Monetization:** `google_mobile_ads` for showing rewarded video ads.
- **Backend:** Cloud Firestore for storing user data like points.

---

## 2. Current Change: Architecture & Efficiency Refactor

This section details the plan to fix critical bugs and design flaws.

### **Plan & Steps:**

#### **Step 1: Integrate Firebase Remote Config**
- **Goal:** Decouple business logic from the application code to allow for dynamic updates without releasing a new app version.
- **Action:**
    1. Add the `firebase_remote_config` package to `pubspec.yaml`.
    2. Create a `RemoteConfigService` to handle fetching and activating remote values.
    3. The service will fetch `adReward`, `adsPerDayLimit`, and `adCooldown`.
    4. Provide sensible default values within the app in case the fetch from Firebase fails.

#### **Step 2: Optimize Firestore Write Operations**
- **Goal:** Drastically reduce the number of Firestore writes to stay within the Spark Plan's free limit (20,000 writes/day).
- **Action:**
    1. **Eliminate Per-Ad Writes:** Stop writing to Firestore immediately after a user watches an ad.
    2. **Local Accumulation:** Create local state variables in the `WatchAndEarnScreen` to track points and ads watched *during the current session*.
    3. **UI Responsiveness:** Use the `UserDataProvider` to update the user's points in the local app state immediately, so the UI feels responsive.
    4. **Batch Write on Dispose:** Implement a single batch write in the `dispose` method of the `WatchAndEarnScreen`. This write will commit the total accumulated points and ad count for the session to Firestore when the user navigates away from the screen.

#### **Step 3: Improve Ad Loading and Error Handling**
- **Goal:** Make the ad loading process more robust and prevent the app from getting into a broken state.
- **Action:**
    1. **Remove Infinite Loop:** Replace the `while` loop for ad loading with a strategy that uses a limited number of retries (e.g., 3 attempts) with an exponential backoff delay.
    2. **Propagate Errors:** Modify the `AdService` to stop silently swallowing errors. Errors will be propagated to the UI layer.
    3. **User Feedback:** The `WatchAndEarnScreen` will display a clear message to the user (e.g., "Failed to load ad. Please try again later.") if an ad fails to load after all retry attempts, preventing user confusion.

#### **Step 4: Prevent Unnecessary Background Processing**
- **Goal:** Conserve battery and CPU by ensuring UI rebuilds only happen when the screen is active.
- **Action:**
    1. **Use `WidgetsBindingObserver`:** Implement this observer in the `WatchAndEarnScreen`.
    2. **Lifecycle-Aware Timer:** Pause the 30-second cooldown timer when the app is paused or in the background, and resume it when the app is brought back to the foreground. This stops `setState` from being called unnecessarily.

