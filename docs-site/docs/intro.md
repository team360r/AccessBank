---
sidebar_position: 0
title: Introduction
---

# Welcome to AccessBank

Learn Flutter accessibility by building a real banking app — one chapter at a time.

## What You'll Build

AccessBank is a Flutter banking app with realistic screens: login, dashboard, transfer money, transaction history, and account settings. It works — but it's inaccessible. Your job is to fix it.

By the end, every screen will be fully usable with VoiceOver and TalkBack. You will have written real semantic widget trees, tested with actual screen readers, and shipped accessible Flutter code you're proud of.

## What You'll Learn

- Setting up accessibility tooling in Flutter (DevTools, screen readers, inspector)
- Writing semantic widget trees with `Semantics`, `MergeSemantics`, and `ExcludeSemantics`
- Navigation and focus management for screen readers and keyboard users
- Visual accessibility: contrast ratios, text scaling, touch targets, and dark mode
- Accessible forms: labels, error announcements, validation, and autofill
- Reducing motion for users with vestibular disorders
- Live regions and dynamic announcements
- Testing with TalkBack, VoiceOver, and Flutter's accessibility widget test matchers
- Polishing for production across iOS and Android

## How This Tutorial Works

This tutorial uses a **three-panel workflow**:

```mermaid
graph LR
    B["🌐 Browser<br/>localhost:3000<br/>Tutorial guide"]
    IDE["💻 IDE<br/>VS Code / Android Studio<br/>Edit Flutter code"]
    D["📱 Device<br/>iPhone / Android<br/>See & hear changes"]
    B --> IDE --> D --> B
```

Read the guide in your browser, make code changes in your IDE, and immediately hear the result on your connected device with a screen reader running.

## Chapter Learning Path

```mermaid
graph TD
    C0["Ch 0\nToolkit"] --> C1["Ch 1\nWelcome"]
    C1 --> C2["Ch 2\nSemantics"]
    C2 --> C3["Ch 3\nNavigation"]
    C3 --> C4["Ch 4\nVisual"]
    C4 --> C5["Ch 5\nForms"]
    C5 --> C6["Ch 6\nMotion"]
    C6 --> C7["Ch 7\nLive Regions"]
    C7 --> C8["Ch 8\nTesting"]
    C8 --> C9["Ch 9\nPolish"]
```

## Prerequisites

- Flutter SDK 3.x+ — [Install Flutter](https://docs.flutter.dev/get-started/install)
- Node.js 18+ — [nodejs.org](https://nodejs.org)
- VS Code or Android Studio
- An iOS device/simulator or Android device/emulator
- Basic Flutter knowledge (built at least one app)
- No accessibility experience needed!

## Ready to Start?

Run `./setup.sh` to install all dependencies and configure iOS signing, then `./start.sh` to launch the tutorial guide and app together. Then jump straight in:

[Start Chapter 0: Your Accessibility Toolkit](/chapters/toolkit)
