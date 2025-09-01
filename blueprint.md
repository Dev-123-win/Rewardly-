# Rewardly Blueprint

## Overview

Rewardly is a mobile application designed to reward users for their engagement. Users can earn points by completing various tasks, such as watching ads, and then redeem those points for cash through a withdrawal system.

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

- [x] Implement a daily streak system for tier promotions.
- [x] Update the user data model to track streaks.
- [x] Implement the core streak logic in the home screen.
- [x] Create a streak indicator widget.
- [x] Update the `blueprint.md` file.
