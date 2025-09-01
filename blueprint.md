# Rewardly Blueprint

## Overview

Rewardly is a mobile application designed to reward users for their engagement. Users can earn points by completing various tasks, such as watching ads and playing games, and then redeem those points for cash through a withdrawal system.

## Features

### Core Features

- **User Authentication:** Users can register and log in to the application.
- **Points System:** Users earn points for completing tasks.
- **Withdrawal System:** Users can withdraw their points for cash.
- **Admin Panel:** Admins can manage users and withdrawals.
- **Referral Program:** Users can refer friends to earn bonus points.

### Monetization

- **App Open Ads:** Ads that appear when the app is opened.
- **Interstitial Ads:** Full-screen ads that appear at natural transition points.
- **Rewarded Interstitial Ads:** Ads that reward users for watching them.
- **Native Ads:** Ads that are integrated into the app's content.

### Admin Panel

- **User Management:** Admins can view a list of users, search for users by email, and toggle their admin status.
- **Withdrawal Management:** Admins can view a list of pending withdrawals and approve or deny them.

### Endless Runner Game

A 3D endless runner game has been integrated directly into the home screen to provide an engaging way for users to earn points.

**Gameplay:**

- The player controls a character that runs endlessly through a 3D environment.
- The player can switch between three lanes to avoid obstacles and collect coins.
- The game features mobile-friendly swipe controls and keyboard controls for desktop.

**"Continue with Ad" Feature:**

- When the player collides with an obstacle, the game ends.
- A "Game Over" screen appears, offering the option to "Continue" by watching a rewarded ad.
- This ad flow is independent and does not count towards the user's daily ad limit for the main "Watch Ad" button.

**Optimized Coin Logic:**

- Coin collection is managed in a separate `coin_logic.js` file for easy configuration.
- To optimize for the Firebase free tier, the app writes to the database only after 10 coins are collected, not on every single coin.

**Graphics & Performance Enhancements:**

- **Modern UI:** The "Game Over" screen features a contemporary design with custom fonts, gradients, and interactive "glow" effects.
- **Realistic Lighting & Shadows:** The game uses a directional light to cast dynamic shadows, adding depth and realism.
- **Glow Effect:** Coins emit a vibrant glow, making them more visually appealing.
- **Varied 3D Models:** The player is a sphere, and obstacles are a mix of cylinders and boxes to break up visual monotony.
- **Dynamic Ground:** A moving grid texture enhances the sense of speed and provides a polished, sci-fi aesthetic.
- **Optimized Performance:** An object pooling system is used to reuse game objects, ensuring smooth gameplay.

## Point Economy

- **Conversion Rate:** 1000 points = ₹1
- **Earning Model:** Based on a 40/60 (user/admin) revenue split from an average eCPM of $1.45.

### Point Rewards per Ad

- **Bronze Tier:** 48 points
- **Silver Tier:** 54 points
- **Gold Tier:** 60 points

## Tier Promotion System

- **Daily Ad Quota:** 5 ads per day
- **Daily Ad Limit:** 10 ads per day
- **Bronze to Silver:** Maintain a 7-day streak of meeting the daily ad quota.
- **Silver to Gold:** Maintain a 30-day streak after reaching Silver.

## Current Plan

- [x] Implement an endless runner game on the home screen.
- [x] Integrate a "Continue with Ad" feature with an independent ad economy.
- [x] Optimize coin collection to minimize database writes.
- [x] Enhance the game's graphics with modern UI, lighting, shadows, and a glow effect.
- [x] Improve game performance with object pooling.
- [x] Implement mobile-friendly swipe controls.
- [x] Update the `blueprint.md` file.
