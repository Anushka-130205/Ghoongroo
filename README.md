<div align="center">

<img src="docs/assets/appicon.jpg" alt="Ghoongroo app logo" width="120" height="120" style="border-radius: 24px;" />

# Ghoongroo

### Your AI-Powered Kathak Companion

*Practice authentic Kathak with real-time, on-device feedback — right from your iPhone.*

[![Platform](https://img.shields.io/badge/Platform-iOS%2016%2B%20%7C%20iPadOS-blue?logo=apple)](https://www.apple.com/ios/)
[![Language](https://img.shields.io/badge/Swift-SwiftUI-orange?logo=swift)](https://developer.apple.com/swift/)
[![Vision](https://img.shields.io/badge/Apple-Vision-black?logo=apple)](https://developer.apple.com/documentation/vision)
[![Privacy](https://img.shields.io/badge/Analysis-100%25%20On--Device-success)](#-privacy-first)
[![Website](https://img.shields.io/badge/Website-Live-brightgreen)](https://anushka-130205.github.io/Ghoongroo/)

[**🌐 Visit the Website**](https://anushka-130205.github.io/Ghoongroo/) · [**Features**](#-features) · [**Taals**](#-taals) · [**Architecture**](#-project-structure)

</div>

---

## ✨ Overview

**Ghoongroo** is an iOS app that helps students of **Kathak** — one of India's classical dance forms — refine their technique through artificial intelligence. Using Apple's **Vision** framework, the app tracks your movement in real time and turns it into clear, actionable feedback, all while keeping your practice data entirely on your device.

Whether you're learning your first *taal* or perfecting a spin, Ghoongroo acts as a patient practice partner that watches, listens, and scores — so you always know what to work on next.

---

## 🌟 Features

### 🎯 Grace Score Engine
An AI scoring system that evaluates **five body regions** — posture accuracy, joint alignment, balance stability, rhythm synchronization, and movement smoothness — and distills them into a single **Grace Score out of 100**.

### 📹 Real-Time Pose Tracking
Powered by **Apple Vision**, the app simultaneously tracks **19 body landmarks** as you dance, analyzing form frame by frame.

### 🥁 Taal Practice with Synced Audio
Practice classical rhythmic cycles with synchronized audio guidance and bol playback.

### 📚 Structured Curriculum
Progressive lessons that take you from **beginner fundamentals** through to **advanced techniques** like spins (*chakkar*).

### 🔒 Privacy-First
All analysis runs **on-device** using Apple's Foundation Model. **Your practice data never leaves your iPhone.**

---

## 🎼 Taals

| Taal | Beats | Description |
|------|:-----:|-------------|
| **Teental** | 16 | The most popular cycle in Kathak |
| **Jhaptal** | 10 | A graceful, medium-length cycle |
| **Ektaal** | 12 | A rich cycle used in expressive compositions |

---

## 🗂 Project Structure

```
Ghoongroo/
├── Ghoongroo/                 # iOS app source (SwiftUI)
│   ├── App/                   # App entry point & local database
│   ├── Managers/              # Camera, pose detection, beat, session & stats controllers
│   ├── Models/                # Grace Score engine, taals, rhythm & insight models
│   ├── Audio/                 # Bol speech & taal sound playback
│   ├── Views/                 # Practice, Learn, Result & Onboarding screens
│   ├── Theme/                 # Design system & styling
│   └── Assets.xcassets/       # Images, taal cards & app icon
├── Ghoongroo.xcodeproj/       # Xcode project
├── docs/                      # Marketing website (served via GitHub Pages)
│   ├── index.html             # Landing page
│   ├── contact.html           # Contact & support
│   ├── privacy.html           # Privacy policy
│   ├── terms.html             # Terms of use
│   ├── style.css              # Site styling
│   └── assets/                # Site images (app icon, hero)
└── README.md
```

---

## 🛠 Tech Stack

- **SwiftUI** — declarative UI across iPhone & iPad
- **Apple Vision** — real-time body-pose landmark detection
- **On-device Foundation Model** — private movement analysis
- **AVFoundation** — camera capture & audio playback

---

## 🚀 Getting Started

### Requirements
- **iOS 16.0+ / iPadOS** device (a physical device is recommended for camera-based tracking)
- **Xcode 15+** on macOS

### Build & Run
```bash
# 1. Clone the repository
git clone https://github.com/Anushka-130205/Ghoongroo.git
cd Ghoongroo

# 2. Open the project in Xcode
open Ghoongroo.xcodeproj

# 3. Select a target device and press ⌘R to build & run
```

---

## 🌐 Website

The marketing site lives in [`docs/`](docs/) and is published with **GitHub Pages**:

👉 **[anushka-130205.github.io/Ghoongroo](https://anushka-130205.github.io/Ghoongroo/)**

It includes the landing page, privacy policy, terms of use, and a contact/support page.

---

<div align="center">

*Coming soon to the App Store.* 🍎

Made with ❤️ for Kathak.

</div>
