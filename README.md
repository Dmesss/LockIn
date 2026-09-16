<p align="center">
  <img src="Resources/AppIcon.png" width="120" height="120" alt="LockIn Logo" style="border-radius: 26px;">
</p>

<h1 align="center">🔒 LockIn</h1>
<p align="center"><b>MacBook Notch Dynamic Island & Desktop Companion</b></p>
<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2014.0%2B-black?style=flat-square&logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat-square&logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="MIT License">
</p>

> Transform your MacBook notch into a functional **Dynamic Island** with a live **Spotify player**, **week calendar**, **real-time weather**, **quick mirror**, and an adorable **interactive pixel duck desktop companion**!

---

## 🌟 Highlights

- **Dynamic Island Notch**: Expands your physical MacBook notch into an Apple-inspired Dynamic Island.
- **🎵 Live Spotify Player**: Album cover art, real-time scrub bar, elapsed & total duration, and playback controls.
- **📅 5-Day Week Calendar**: Clean calendar strip with today's date indicator and centered media transport controls.
- **⛅ Real-Time Weather**: Live temperature, city, condition, and dynamic day/night/rain icons.
- **🎦 Quick Mirror Webcam**: One-click round webcam circle in the notch for quick camera checks before calls.
- **🐥 Interactive Desktop Duck**: A pixel pet that waddles across your screen, perches on active windows, bobs to Spotify music, and wears 10+ unlockable hats.
- **🖤 100% Borderless Pitch-Black**: Seamlessly blends into the MacBook screen bezel and notch hardware.
- **⚡ Native Swift & Zero Overhead**: Built purely with Swift and AppKit. Zero Electron, lightweight on memory, and battery-friendly.

---

## 🖥️ Dynamic Island Modes

### 1. Idle Mode (480pt)
- **Left Column**: Mini 5-day week calendar with centered transport controls (`⏮️ ⏯️ ⏭️`) to easily control Spotify even when idle.
- **Right Column**: Centered weather dashboard displaying weather icon, temperature, city, and condition.
- **Top Ear Bar**: Clean, borderless icons for Home, Pomodoro focus timer, Camera mirror, Settings, and live Mac battery percentage.

### 2. Spotify Playback Mode (510pt)
- Automatically expands when a track plays on Spotify.
- Shows genuine album art, song title, artist, progress scrub bar, and interactive playback controls.
- Keeps the week calendar and weather readily accessible on the right.

### 3. Quick Mirror Mode (520pt)
- Click the camera icon in the top ear to open a circular mirror preview right inside your notch.
- Keeps Spotify playback controls active on the left, and the calendar in the center.

---

## 🐥 Desktop Duck Companion

- **Living Pixel Pet**: Custom pixel animations including waddling, idle breathing, head bobbing, sleeping, preening, bongo typing, and climbing window borders.
- **Window Perching**: Intelligently detects top-level macOS windows and perches directly on title bars.
- **Gamification & Wardrobe**:
  - Earn Focus Coins by completing Pomodoro focus sessions.
  - 10+ collectible pixel hats: Hard Hat, Detective, Straw Hat, Wizard, Ninja, Sunglasses, Pirate, Chef, Crown, and more.
- **System Reactive**: Responds to high CPU usage, low battery alerts, day/night cycles, and rainy weather.

---

## ⌨️ Shortcuts & Interactions

| Target | Gesture / Action | Result |
| :--- | :--- | :--- |
| **Notch Island** | Mouse Hover / Click | Expands or collapses Dynamic Island |
| **Notch Camera** | Click 🎦 Icon | Toggles Quick Mirror circle |
| **Notch Pomodoro**| Click 🍅 Icon | Starts / pauses Pomodoro timer |
| **Desktop Duck** | Click & Drag | Moves duck anywhere across screens |
| **Desktop Duck** | Right Click | Opens context menu & quick settings |

---

## 🚀 Installation & Getting Started

### Option 1: Download Pre-built Release (Recommended)
1. Download the latest `LockIn.zip` from the **[Releases](https://github.com/Dmesss/LockIn/releases)** tab.
2. Unzip and drag `LockIn.app` into your `/Applications` folder.
3. Open `LockIn`!
   *(To have it launch automatically on login, add `LockIn` under macOS **System Settings > General > Login Items**).*

---

### Option 2: Build from Source

**Requirements:**
- macOS 14.0 (Sonoma) or later
- Xcode 15.0+ or Swift 5.9+ Command Line Tools

```zsh
# 1. Clone the repository
git clone https://github.com/Dmesss/LockIn.git
cd LockIn

# 2. Build and bundle the app
./tools/make_app.sh

# 3. Copy to Applications
cp -R dist/LockIn.app /Applications/

# 4. Launch
open /Applications/LockIn.app
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
