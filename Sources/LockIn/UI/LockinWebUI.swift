import Foundation

public struct LockinWebUI {
    public static func getHTML() -> String {
        return """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="apple-mobile-web-app-title" content="Lockin">
<title>Lockin • Focus &amp; Duck Companion</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<style>
  :root {
    --primary: #FF007A;
    --primary-light: #FFEBF4;
    --primary-glow: rgba(255, 0, 122, 0.28);
    --gold: #FFB800;
    --gold-light: #FFF8E7;
    --gold-glow: rgba(255, 184, 0, 0.3);
    --spotify: #1ED760;
    --spotify-dark: #121212;
    --bg: #F8F9FC;
    --card: #FFFFFF;
    --text-main: #11142D;
    --text-muted: #808191;
    --border: #F0F1F5;
    --success: #00D084;
    --warning: #FFAB00;
  }

  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    -webkit-tap-highlight-color: transparent;
    font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
  }

  body {
    background-color: #E5E8F0;
    display: flex;
    justify-content: center;
    min-height: 100vh;
    color: var(--text-main);
  }

  #app-frame {
    width: 100%;
    max-width: 430px;
    background: var(--bg);
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    position: relative;
    box-shadow: 0 24px 60px rgba(0,0,0,0.12);
    padding-bottom: 95px;
    overflow-x: hidden;
  }

  /* Header */
  .header {
    padding: 22px 20px 12px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .header-left {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .avatar {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: #FFF;
    overflow: hidden;
    border: 2px solid var(--primary);
    box-shadow: 0 4px 12px rgba(255,0,122,0.18);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.2s ease;
  }

  .avatar:hover {
    transform: scale(1.08);
    box-shadow: 0 6px 16px var(--primary-glow);
  }

  .avatar:active {
    transform: scale(0.94);
  }

  .avatar img {
    width: 36px;
    height: 36px;
    image-rendering: pixelated;
    object-fit: contain;
  }

  .brand-title {
    font-size: 26px;
    font-weight: 900;
    color: var(--primary);
    letter-spacing: -0.8px;
  }

  .header-right {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .coin-badge {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 6px 12px;
    background: var(--gold-light);
    border: 1.5px solid rgba(255, 184, 0, 0.4);
    border-radius: 20px;
    font-size: 13px;
    font-weight: 800;
    color: #B87800;
    box-shadow: 0 2px 10px var(--gold-glow);
    cursor: pointer;
    transition: transform 0.15s;
    text-align: center;
  }

  .coin-badge:active {
    transform: scale(0.96);
  }

  .coin-icon-svg {
    width: 16px;
    height: 16px;
    fill: var(--gold);
  }

  .status-badge {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 6px 10px;
    background: var(--card);
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  }

  .status-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--success);
    box-shadow: 0 0 8px var(--success);
  }

  /* Screens */
  .screen {
    display: none;
    padding: 10px 20px 24px;
    animation: fadeIn 0.2s ease;
  }

  .screen.active {
    display: block;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(6px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .greeting-title {
    font-size: 24px;
    font-weight: 900;
    color: var(--text-main);
    margin-bottom: 4px;
  }

  .greeting-sub {
    font-size: 13px;
    color: var(--text-muted);
    margin-bottom: 18px;
  }

  /* Preset Pills */
  .presets-row {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;
    width: 100%;
    margin-bottom: 18px;
  }

  .preset-btn {
    flex: 1;
    background: #F1F3F8;
    border: 2px solid transparent;
    border-radius: 16px;
    padding: 10px 4px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    cursor: pointer;
    transition: all 0.15s;
  }

  .preset-btn.active {
    background: var(--primary-light);
    border-color: var(--primary);
  }

  .preset-time {
    font-size: 14px;
    font-weight: 800;
    color: var(--text-main);
    text-align: center;
  }

  .preset-btn.active .preset-time {
    color: var(--primary);
  }

  .preset-desc {
    font-size: 10px;
    font-weight: 700;
    color: var(--text-muted);
    margin-top: 2px;
    text-align: center;
  }

  /* Timer Hero Card */
  .timer-card {
    background: var(--card);
    border-radius: 32px;
    padding: 26px 20px 22px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    box-shadow: 0 12px 32px rgba(0,0,0,0.04);
    margin-bottom: 18px;
    position: relative;
  }

  .ring-container {
    position: relative;
    width: 220px;
    height: 220px;
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 0 auto 20px auto;
  }

  .ring-svg {
    transform: rotate(-90deg);
    width: 100%;
    height: 100%;
  }

  .ring-bg {
    fill: none;
    stroke: #F1F3F8;
    stroke-width: 12;
  }

  .ring-progress {
    fill: none;
    stroke: var(--primary);
    stroke-width: 12;
    stroke-linecap: round;
    transition: stroke-dashoffset 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .ring-center {
    position: absolute;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
  }

  .timer-digits {
    font-size: 48px;
    font-weight: 900;
    color: var(--primary);
    letter-spacing: -1.5px;
    line-height: 1;
    margin-bottom: 6px;
    font-variant-numeric: tabular-nums;
    text-align: center;
  }

  .timer-label {
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 1.5px;
    color: var(--text-muted);
    text-transform: uppercase;
    text-align: center;
  }

  .reward-hint {
    font-size: 11px;
    font-weight: 700;
    color: var(--gold);
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 4px;
    margin-top: 4px;
    text-align: center;
  }

  /* Control Buttons - 100% Centered */
  .btn-primary {
    width: 100%;
    max-width: 260px;
    background: linear-gradient(135deg, #FF007A 0%, #E6006E 100%);
    color: white;
    border: none;
    border-radius: 28px;
    padding: 16px 24px;
    font-size: 15px;
    font-weight: 800;
    cursor: pointer;
    box-shadow: 0 8px 24px var(--primary-glow);
    transition: transform 0.15s, box-shadow 0.15s;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    gap: 10px;
    margin: 0 auto;
  }

  .btn-primary:active {
    transform: scale(0.97);
  }

  .btn-control-group {
    display: flex;
    gap: 10px;
    width: 100%;
    max-width: 260px;
    justify-content: center;
    align-items: center;
    margin: 0 auto;
  }

  .btn-secondary {
    flex: 1;
    background: #F1F3F8;
    color: var(--text-main);
    border: none;
    border-radius: 20px;
    padding: 14px 16px;
    font-size: 13px;
    font-weight: 800;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    gap: 6px;
    margin: 0 auto;
  }

  .btn-secondary:active {
    background: #E4E7EE;
  }

  .btn-secondary.danger {
    color: #FF334B;
  }

  /* FEATURE 1: SPOTIFY MINI PLAYER CARD */
  .spotify-card {
    background: #181920;
    color: white;
    border-radius: 24px;
    padding: 16px 18px;
    margin-bottom: 18px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    box-shadow: 0 8px 24px rgba(0,0,0,0.1);
    border: 1px solid rgba(255,255,255,0.08);
  }

  .spotify-info {
    display: flex;
    align-items: center;
    gap: 12px;
    overflow: hidden;
    flex: 1;
  }

  .spotify-icon-box {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: var(--spotify);
    display: flex;
    align-items: center;
    justify-content: center;
    color: black;
    flex-shrink: 0;
  }

  .spotify-text {
    overflow: hidden;
  }

  .spotify-title {
    font-size: 13px;
    font-weight: 800;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .spotify-artist {
    font-size: 11px;
    color: #A0A5B8;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .spotify-controls {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-shrink: 0;
  }

  .spotify-btn {
    background: rgba(255,255,255,0.1);
    color: white;
    border: none;
    border-radius: 50%;
    width: 34px;
    height: 34px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: background 0.15s, transform 0.15s;
  }

  .spotify-btn:active {
    transform: scale(0.92);
    background: rgba(255,255,255,0.25);
  }

  /* FEATURE 2: TAMAGOTCHI & DUCK MOOD CARD */
  .tamagotchi-card {
    background: linear-gradient(135deg, #181B26 0%, #252A3A 100%);
    color: white;
    border-radius: 28px;
    padding: 20px;
    margin-bottom: 18px;
    box-shadow: 0 12px 28px rgba(0,0,0,0.12);
  }

  .tamagotchi-top {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 14px;
  }

  .duck-mascot-avatar {
    width: 76px;
    height: 76px;
    background: rgba(255,255,255,0.06);
    border-radius: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    border: 1px solid rgba(255,255,255,0.12);
    flex-shrink: 0;
  }

  .duck-mascot-avatar img {
    width: 68px;
    height: 68px;
    image-rendering: pixelated;
    object-fit: contain;
  }

  .tamagotchi-mood-tag {
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 1px;
    color: #FF66B2;
    text-transform: uppercase;
    margin-bottom: 3px;
  }

  .tamagotchi-mood-title {
    font-size: 16px;
    font-weight: 900;
    color: white;
    margin-bottom: 3px;
  }

  .tamagotchi-mood-desc {
    font-size: 11px;
    color: #A0A5B8;
  }

  /* Tamagotchi Stat Bars */
  .t-stats-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 8px;
    margin-bottom: 14px;
    background: rgba(0,0,0,0.2);
    padding: 10px;
    border-radius: 16px;
  }

  .t-stat-item {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .t-stat-label {
    font-size: 10px;
    font-weight: 700;
    color: #A0A5B8;
    display: flex;
    justify-content: space-between;
  }

  .t-stat-bar {
    width: 100%;
    height: 6px;
    background: rgba(255,255,255,0.1);
    border-radius: 3px;
    overflow: hidden;
  }

  .t-stat-fill {
    height: 100%;
    border-radius: 3px;
    transition: width 0.3s ease;
  }

  .duck-care-row {
    display: flex;
    gap: 8px;
  }

  .duck-care-btn {
    flex: 1;
    background: rgba(255,255,255,0.1);
    color: white;
    border: none;
    border-radius: 14px;
    padding: 8px 12px;
    font-size: 11px;
    font-weight: 800;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    gap: 6px;
    transition: background 0.15s;
  }

  .duck-care-btn:active {
    background: rgba(255,255,255,0.25);
  }

  /* Focus Goal Task Card */
  .task-input-card {
    background: var(--card);
    border-radius: 24px;
    padding: 18px 20px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.03);
    margin-bottom: 18px;
  }

  .task-input-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
  }

  .task-input-title {
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 1px;
    color: var(--primary);
    text-transform: uppercase;
  }

  .task-input-box {
    display: flex;
    gap: 8px;
  }

  .task-input-box input {
    flex: 1;
    background: #F1F3F8;
    border: 1px solid transparent;
    border-radius: 14px;
    padding: 10px 14px;
    font-size: 13px;
    font-weight: 600;
    color: var(--text-main);
    outline: none;
  }

  .task-input-box input:focus {
    border-color: var(--primary);
    background: white;
  }

  .task-save-btn {
    background: var(--text-main);
    color: white;
    border: none;
    border-radius: 14px;
    padding: 10px 16px;
    font-size: 12px;
    font-weight: 800;
    cursor: pointer;
  }

  /* FEATURE 3: CUSTOM SOUND FX CARD */
  .soundfx-card {
    background: var(--card);
    border-radius: 24px;
    padding: 18px 20px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.03);
    margin-bottom: 18px;
  }

  .soundfx-title {
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 1px;
    color: var(--primary);
    text-transform: uppercase;
    margin-bottom: 12px;
  }

  .soundfx-row {
    display: flex;
    gap: 8px;
  }

  .soundfx-pill {
    flex: 1;
    background: #F1F3F8;
    border: 2px solid transparent;
    border-radius: 14px;
    padding: 10px 6px;
    text-align: center;
    cursor: pointer;
    font-size: 12px;
    font-weight: 800;
    color: var(--text-main);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 4px;
    transition: all 0.15s;
  }

  .soundfx-pill.active {
    border-color: var(--primary);
    background: var(--primary-light);
    color: var(--primary);
  }

  /* Wardrobe & Shop Grid */
  .shop-header-card {
    background: linear-gradient(135deg, #2D1A38 0%, #19162B 100%);
    color: white;
    border-radius: 28px;
    padding: 22px 20px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 16px;
    box-shadow: 0 12px 28px rgba(0,0,0,0.12);
  }

  .shop-duck-avatar {
    width: 84px;
    height: 84px;
    background: rgba(255,255,255,0.08);
    border-radius: 22px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1.5px solid rgba(255,0,122,0.4);
    flex-shrink: 0;
  }

  .shop-duck-avatar img {
    width: 74px;
    height: 74px;
    image-rendering: pixelated;
    object-fit: contain;
  }

  .wardrobe-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
  }

  .hat-card {
    background: var(--card);
    border-radius: 24px;
    padding: 16px 14px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    box-shadow: 0 8px 20px rgba(0,0,0,0.03);
    border: 2px solid transparent;
    cursor: pointer;
    transition: transform 0.15s, border-color 0.15s, box-shadow 0.15s;
    position: relative;
  }

  .hat-card.equipped {
    border-color: var(--primary);
    background: #FFF8FB;
    box-shadow: 0 10px 24px var(--primary-glow);
  }

  .hat-card:active {
    transform: scale(0.96);
  }

  .rarity-pill {
    font-size: 9px;
    font-weight: 800;
    padding: 3px 8px;
    border-radius: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    align-self: center;
    margin-bottom: 6px;
    text-align: center;
  }

  .rarity-Common { background: #EEF0F5; color: #6E7282; }
  .rarity-Rare { background: #E6F3FF; color: #007AFF; }
  .rarity-Epic { background: #F3E8FF; color: #9B51E0; }
  .rarity-Legendary { background: #FFF4D9; color: #D48800; border: 1px solid rgba(212,136,0,0.3); }

  .hat-img {
    width: 70px;
    height: 70px;
    image-rendering: pixelated;
    object-fit: contain;
    margin: 4px auto 8px auto;
  }

  .hat-name {
    font-size: 13px;
    font-weight: 800;
    text-align: center;
    color: var(--text-main);
    margin-bottom: 4px;
    line-height: 1.2;
  }

  .hat-price-row {
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    gap: 4px;
    font-size: 12px;
    font-weight: 800;
    color: #B87800;
    margin-bottom: 8px;
  }

  .hat-action-btn {
    width: 100%;
    padding: 8px 0;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 800;
    text-align: center;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto;
    gap: 4px;
  }

  .hat-card.equipped .hat-action-btn {
    background: var(--primary);
    color: white;
  }

  .hat-card.owned .hat-action-btn {
    background: #F1F3F8;
    color: var(--text-main);
  }

  .hat-card.locked .hat-action-btn {
    background: linear-gradient(135deg, #FFB800 0%, #E69500 100%);
    color: white;
    box-shadow: 0 4px 12px var(--gold-glow);
  }

  /* Break Time Screen */
  .break-card {
    background: var(--card);
    border-radius: 32px;
    padding: 30px 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    box-shadow: 0 12px 32px rgba(0,0,0,0.04);
    margin-bottom: 20px;
  }

  .break-duck-circle {
    width: 130px;
    height: 130px;
    border-radius: 50%;
    background: var(--primary-light);
    margin: 0 auto 18px auto;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 8px 24px rgba(255,0,122,0.15);
  }

  .break-duck-circle img {
    width: 90px;
    height: 90px;
    image-rendering: pixelated;
    object-fit: contain;
  }

  .hydration-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    gap: 8px;
    background: #E8F4FD;
    color: #007AFF;
    border: none;
    border-radius: 20px;
    padding: 14px 20px;
    font-size: 13px;
    font-weight: 800;
    cursor: pointer;
    width: 100%;
    max-width: 280px;
    margin: 14px auto 0 auto;
    transition: transform 0.15s;
  }

  .hydration-btn:active {
    transform: scale(0.97);
  }

  /* Remote Duck Actions Grid */
  .remote-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    margin-top: 14px;
  }

  .btn-remote {
    padding: 14px 12px;
    border-radius: 20px;
    border: 1px solid var(--border);
    background: var(--card);
    font-size: 13px;
    font-weight: 700;
    color: var(--text-main);
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    gap: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.02);
    transition: background 0.15s, transform 0.15s;
    margin: 0 auto;
    width: 100%;
  }

  .btn-remote:active {
    background: #F1F3F8;
    transform: scale(0.97);
  }

  /* Tab Bar */
  .tab-bar {
    position: fixed;
    bottom: 0;
    width: 100%;
    max-width: 430px;
    background: rgba(255, 255, 255, 0.94);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-top: 1px solid rgba(0,0,0,0.06);
    display: flex;
    justify-content: space-around;
    padding: 12px 10px 24px;
    z-index: 100;
  }

  .tab-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    gap: 4px;
    color: #A0A5B8;
    font-size: 11px;
    font-weight: 700;
    cursor: pointer;
    transition: color 0.15s;
  }

  .tab-item.active {
    color: var(--primary);
  }

  .tab-icon-svg {
    width: 22px;
    height: 22px;
    fill: currentColor;
  }

  /* Toast Notification */
  #toast {
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%) translateY(-100px);
    background: #11142D;
    color: white;
    padding: 12px 22px;
    border-radius: 24px;
    font-size: 13px;
    font-weight: 800;
    box-shadow: 0 10px 30px rgba(0,0,0,0.25);
    transition: transform 0.3s cubic-bezier(0.2, 0.8, 0.2, 1);
    z-index: 999;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    text-align: center;
  }

  #toast.show {
    transform: translateX(-50%) translateY(0);
  }

  /* Purchase Modal */
  .modal-overlay {
    display: none;
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0,0,0,0.5);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    z-index: 1000;
    align-items: center;
    justify-content: center;
    padding: 20px;
    animation: fadeIn 0.15s ease;
  }

  .modal-overlay.active {
    display: flex;
  }

  .modal-card {
    background: var(--card);
    width: 100%;
    max-width: 340px;
    border-radius: 32px;
    padding: 26px 22px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    box-shadow: 0 20px 50px rgba(0,0,0,0.25);
    margin: 0 auto;
  }

  .modal-duck-circle {
    width: 90px;
    height: 90px;
    border-radius: 50%;
    background: var(--primary-light);
    margin: 0 auto 14px auto;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .modal-duck-circle img {
    width: 68px;
    height: 68px;
    image-rendering: pixelated;
    object-fit: contain;
  }

  .modal-title {
    font-size: 18px;
    font-weight: 900;
    margin-bottom: 6px;
    color: var(--text-main);
    text-align: center;
  }

  .modal-desc {
    font-size: 13px;
    color: var(--text-muted);
    margin-bottom: 20px;
    line-height: 1.4;
    text-align: center;
  }

  .modal-actions {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    width: 100%;
  }

  .modal-btn {
    flex: 1;
    padding: 14px;
    border-radius: 18px;
    font-size: 13px;
    font-weight: 800;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
  }

  .modal-btn.confirm {
    background: linear-gradient(135deg, #FFB800 0%, #E69500 100%);
    color: white;
    box-shadow: 0 6px 18px var(--gold-glow);
  }

  .modal-btn.cancel {
    background: #F1F3F8;
    color: var(--text-main);
  }

  
  /* Gallery & Custom Photo Upload Styles */
  .edit-avatar-container {
    position: relative;
    width: 96px;
    height: 96px;
    margin: 12px auto 14px;
    cursor: pointer;
    transition: transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
  }

  .edit-avatar-container:hover {
    transform: scale(1.06);
  }

  .edit-avatar-container img {
    width: 96px;
    height: 96px;
    border-radius: 50%;
    object-fit: cover;
    border: 3.5px solid var(--primary);
    box-shadow: 0 8px 24px var(--primary-glow);
    display: block;
    background: #FFF;
  }

  .edit-avatar-camera-btn {
    position: absolute;
    bottom: 0px;
    right: 0px;
    width: 32px;
    height: 32px;
    background: var(--primary);
    border-radius: 50%;
    border: 2.5px solid #FFF;
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 8px rgba(0,0,0,0.25);
  }

  .btn-gallery-pick {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    width: 100%;
    padding: 12px 18px;
    background: var(--primary-light);
    color: var(--primary);
    border: 1.5px dashed var(--primary);
    border-radius: 16px;
    font-size: 13px;
    font-weight: 800;
    cursor: pointer;
    margin-bottom: 16px;
    transition: transform 0.15s, background 0.15s;
  }

  .btn-gallery-pick:active {
    transform: scale(0.97);
  }

  body.dark-mode .btn-gallery-pick {
    background: rgba(255, 0, 122, 0.12);
    border-color: rgba(255, 0, 122, 0.5);
    color: #FF66B2;
  }

  /* Dark Mode Styles */
  body.dark-mode {
    background-color: #0A0B10;
    color: #F3F4F6;
  }
  body.dark-mode #app-frame {
    background: #12141E;
  }
  body.dark-mode .card,
  body.dark-mode .profile-card,
  body.dark-mode .goals-card,
  body.dark-mode .settings-list-card,
  body.dark-mode .task-input-card,
  body.dark-mode .modal-card,
  body.dark-mode .theme-modal-sheet,
  body.dark-mode .tab-bar {
    background: #1A1D2B;
    border-color: #272C3D;
    color: #F3F4F6;
  }
  body.dark-mode .brand-title {
    color: var(--primary);
  }
  body.dark-mode .profile-name,
  body.dark-mode .goals-title,
  body.dark-mode .setting-title,
  body.dark-mode .setting-value,
  body.dark-mode .account-row-title,
  body.dark-mode .greeting-title,
  body.dark-mode .theme-name-text,
  body.dark-mode .modal-title {
    color: #FFFFFF;
  }
  body.dark-mode .profile-handle,
  body.dark-mode .setting-desc,
  body.dark-mode .greeting-sub,
  body.dark-mode .profile-balance-label,
  body.dark-mode .profile-level-row,
  body.dark-mode .goal-val,
  body.dark-mode .theme-sub-text,
  body.dark-mode .modal-desc {
    color: #9499AD;
  }
  body.dark-mode .setting-divider {
    background: #272C3D;
  }
  body.dark-mode .profile-progress-track,
  body.dark-mode .goal-progress-track {
    background: #272C3D;
  }
  body.dark-mode .btn-remote,
  body.dark-mode .account-icon-wrap,
  body.dark-mode .setting-icon-circle,
  body.dark-mode .btn-profile-back {
    background: #252A3C;
    border-color: #2E344A;
    color: #E2E8F0;
  }
  body.dark-mode .tab-item {
    color: #787D94;
  }
  body.dark-mode .tab-item.active {
    color: var(--primary);
  }

  /* Profile & Settings (Matching Figma LockIn Profile & Settings.png) */
  .profile-header-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding: 0 4px;
  }

  .btn-profile-back {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: var(--card);
    border: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: var(--text-main);
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    transition: transform 0.15s;
  }

  .btn-profile-back:active {
    transform: scale(0.92);
  }

  .profile-card {
    background: var(--card);
    border-radius: 28px;
    padding: 26px 20px 22px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
    border: 1px solid var(--border);
    margin-bottom: 16px;
    text-align: center;
  }

  .profile-avatar-wrap {
    position: relative;
    width: 92px;
    height: 92px;
    margin: 0 auto 12px;
  }

  .profile-avatar-wrap img {
    width: 92px;
    height: 92px;
    border-radius: 50%;
    object-fit: cover;
    border: 3px solid #FFF;
    box-shadow: 0 6px 20px rgba(0,0,0,0.12);
  }

  .avatar-edit-badge {
    position: absolute;
    bottom: 2px;
    right: 2px;
    width: 28px;
    height: 28px;
    background: var(--primary);
    border-radius: 50%;
    border: 2px solid #FFF;
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 2px 6px rgba(255,0,122,0.35);
    transition: transform 0.15s;
  }

  .avatar-edit-badge:active {
    transform: scale(0.9);
  }

  .profile-name {
    font-size: 22px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.4px;
    margin-bottom: 2px;
  }

  .profile-handle {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-muted);
    margin-bottom: 10px;
  }

  .profile-badge-pro {
    display: inline-block;
    background: linear-gradient(135deg, #FF007A, #FF3399);
    color: white;
    font-size: 11px;
    font-weight: 800;
    padding: 5px 16px;
    border-radius: 20px;
    letter-spacing: 0.3px;
    box-shadow: 0 4px 12px rgba(255,0,122,0.25);
    margin-bottom: 22px;
  }

  .profile-balance-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    text-align: left;
    margin-bottom: 14px;
    padding: 0 4px;
  }

  .profile-balance-label {
    font-size: 12px;
    font-weight: 700;
    color: var(--text-muted);
    margin-bottom: 4px;
  }

  .profile-balance-val {
    font-size: 30px;
    font-weight: 900;
    color: var(--text-main);
    letter-spacing: -0.6px;
    line-height: 1;
  }

  .profile-pts-suffix {
    color: var(--primary);
    font-size: 20px;
    font-weight: 800;
    margin-left: 2px;
  }

  .profile-shop-btn {
    background: linear-gradient(135deg, #FF007A, #FF3399);
    color: white;
    border: none;
    border-radius: 24px;
    padding: 9px 22px;
    font-size: 13px;
    font-weight: 800;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(255, 0, 122, 0.32);
    transition: transform 0.15s;
  }

  .profile-shop-btn:active {
    transform: scale(0.95);
  }

  .profile-level-row {
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    font-weight: 700;
    color: var(--text-muted);
    margin-bottom: 8px;
    padding: 0 4px;
  }

  .profile-level-pct {
    color: var(--primary);
    font-weight: 800;
  }

  .profile-progress-track {
    width: 100%;
    height: 7px;
    background: #F0F2F6;
    border-radius: 10px;
    overflow: hidden;
  }

  .profile-progress-fill {
    height: 100%;
    background: linear-gradient(90deg, #FF007A, #FF459E);
    border-radius: 10px;
    transition: width 0.4s ease;
  }

  /* Goals Card */
  .goals-card {
    background: var(--card);
    border-radius: 28px;
    padding: 22px 20px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
    border: 1px solid var(--border);
    margin-bottom: 16px;
  }

  .goals-title {
    font-size: 17px;
    font-weight: 800;
    color: var(--text-main);
    margin-bottom: 16px;
  }

  .goal-item {
    margin-bottom: 14px;
  }

  .goal-item:last-child {
    margin-bottom: 0;
  }

  .goal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
  }

  .goal-left {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .goal-icon-circle {
    width: 26px;
    height: 26px;
    border-radius: 50%;
    background: var(--primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .goal-name {
    font-size: 14px;
    font-weight: 700;
    color: var(--text-main);
  }

  .goal-val {
    font-size: 13px;
    font-weight: 700;
    color: var(--text-muted);
  }

  .goal-progress-track {
    width: 100%;
    height: 6px;
    background: #F0F2F6;
    border-radius: 10px;
    overflow: hidden;
  }

  .goal-progress-fill {
    height: 100%;
    background: var(--primary);
    border-radius: 10px;
  }

  /* Settings List Card */
  .settings-list-card {
    background: var(--card);
    border-radius: 28px;
    padding: 12px 18px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
    border: 1px solid var(--border);
    margin-bottom: 16px;
  }

  .setting-row {
    display: flex;
    align-items: center;
    padding: 14px 4px;
    cursor: pointer;
    gap: 14px;
  }

  .setting-icon-circle {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: var(--primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .setting-info {
    flex: 1;
    min-width: 0;
  }

  .setting-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--text-main);
  }

  .setting-desc {
    font-size: 11px;
    font-weight: 500;
    color: var(--text-muted);
    margin-top: 2px;
  }

  .setting-value {
    font-size: 14px;
    font-weight: 700;
    color: var(--text-main);
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .setting-divider {
    height: 1px;
    background: var(--border);
    margin: 0 4px;
  }

  .chevron-icon {
    color: var(--text-muted);
    flex-shrink: 0;
  }

  /* iOS Style Toggle Switch */
  .toggle-switch {
    position: relative;
    display: inline-block;
    width: 44px;
    height: 26px;
    flex-shrink: 0;
  }

  .toggle-switch input {
    opacity: 0;
    width: 0;
    height: 0;
  }

  .toggle-slider {
    position: absolute;
    cursor: pointer;
    top: 0; left: 0; right: 0; bottom: 0;
    background-color: #E2E8F0;
    border-radius: 26px;
    transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .toggle-slider:before {
    position: absolute;
    content: "";
    height: 20px;
    width: 20px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    border-radius: 50%;
    box-shadow: 0 2px 4px rgba(0,0,0,0.15);
    transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .toggle-switch input:checked + .toggle-slider {
    background-color: var(--primary);
  }

  .toggle-switch input:checked + .toggle-slider:before {
    transform: translateX(18px);
  }

  /* Account Card */
  .account-row {
    display: flex;
    align-items: center;
    padding: 14px 4px;
    cursor: pointer;
    gap: 14px;
  }

  .account-icon-wrap {
    width: 34px;
    height: 34px;
    border-radius: 50%;
    background: #F1F3F8;
    color: var(--text-main);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .account-row-title {
    flex: 1;
    font-size: 14px;
    font-weight: 700;
    color: var(--text-main);
  }

  /* Theme Sheet Modal (Matching Figma Modal Overlay.png) */
  .theme-modal-sheet {
    background: var(--card);
    width: 100%;
    max-width: 380px;
    border-radius: 36px 36px 28px 28px;
    padding: 22px 22px 28px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    margin: auto auto 20px auto;
    animation: slideUp 0.25s cubic-bezier(0.16, 1, 0.3, 1);
  }

  .theme-drag-handle {
    width: 42px;
    height: 5px;
    background: #CBD5E1;
    border-radius: 10px;
    margin: 0 auto 16px;
  }

  .theme-row {
    display: flex;
    align-items: center;
    padding: 14px 10px;
    border-radius: 16px;
    cursor: pointer;
    gap: 16px;
    transition: background 0.15s;
  }

  .theme-row:hover {
    background: rgba(0,0,0,0.03);
  }

  .theme-color-dot {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    flex-shrink: 0;
  }

  .theme-label-col {
    flex: 1;
  }

  .theme-name-text {
    font-size: 15px;
    font-weight: 700;
    color: var(--text-main);
  }

  .theme-sub-text {
    font-size: 12px;
    font-weight: 500;
    color: var(--text-muted);
  }

  .theme-check-radio {
    width: 22px;
    height: 22px;
    border-radius: 50%;
    border: 2px solid #CBD5E1;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .theme-check-radio.selected {
    border-color: var(--primary);
    background: var(--primary);
  }

  .theme-check-radio.selected:after {
    content: "";
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: white;
  }

  /* Form Inputs in Modals */
  .modal-input-field {
    width: 100%;
    padding: 12px 14px;
    border-radius: 14px;
    border: 1.5px solid var(--border);
    background: #F8F9FD;
    font-size: 14px;
    font-weight: 600;
    color: var(--text-main);
    outline: none;
    margin-bottom: 12px;
    box-sizing: border-box;
  }
  body.dark-mode .modal-input-field {
    background: #151722;
    border-color: #272C3D;
    color: #F3F4F6;
  }
  .modal-input-field:focus {
    border-color: var(--primary);
  }

  .avatar-choice-grid {
    display: flex;
    justify-content: center;
    gap: 12px;
    margin-bottom: 16px;
  }

  .avatar-choice-item {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    border: 2.5px solid transparent;
    cursor: pointer;
    overflow: hidden;
    transition: transform 0.15s, border-color 0.15s;
    background: #FFF;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .avatar-choice-item.selected {
    border-color: var(--primary);
    transform: scale(1.1);
    box-shadow: 0 4px 12px var(--primary-glow);
  }

  .avatar-choice-item img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
</style>
</head>
<body>

<div id="toast"><span id="toast-text">Action executed</span></div>


<!-- Theme Modal (Matching Figma Modal Overlay.png) -->
<div class="modal-overlay" id="theme-modal" onclick="if(event.target === this) closeThemeModal()">
  <div class="theme-modal-sheet">
    <div class="theme-drag-handle"></div>
    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px;">
      <div>
        <div class="theme-name-text" style="font-size: 18px; font-weight: 800;">Theme</div>
        <div class="theme-sub-text">Set your personal theme</div>
      </div>
      <button onclick="closeThemeModal()" style="background: none; border: none; font-size: 20px; color: var(--primary); cursor: pointer; padding: 2px 8px;">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z"/></svg>
      </button>
    </div>

    <div class="theme-row" onclick="setAppTheme('blue')">
      <div class="theme-color-dot" style="background: #007AFF;"></div>
      <div class="theme-label-col">
        <div class="theme-name-text">Classic Blue</div>
        <div class="theme-sub-text">blue</div>
      </div>
      <div class="theme-check-radio" id="radio-theme-blue"></div>
    </div>

    <div class="theme-row" onclick="setAppTheme('pink')">
      <div class="theme-color-dot" style="background: #FF007A;"></div>
      <div class="theme-label-col">
        <div class="theme-name-text">Classic Pink</div>
        <div class="theme-sub-text">pink</div>
      </div>
      <div class="theme-check-radio selected" id="radio-theme-pink"></div>
    </div>

    <div class="theme-row" onclick="showToast('Classic Yellow unlocks at 5,000 pts!')" style="opacity: 0.6;">
      <div class="theme-color-dot" style="background: #F6D075;"></div>
      <div class="theme-label-col">
        <div class="theme-name-text">Classic Yellow</div>
        <div class="theme-sub-text">yellow</div>
      </div>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="#94A3B8"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/></svg>
    </div>

    <div class="theme-row" onclick="showToast('Classic Green unlocks at 10,000 pts!')" style="opacity: 0.6;">
      <div class="theme-color-dot" style="background: #7ED9A4;"></div>
      <div class="theme-label-col">
        <div class="theme-name-text">Classic Green</div>
        <div class="theme-sub-text">green</div>
      </div>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="#94A3B8"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/></svg>
    </div>
  </div>
</div>

<!-- Duration Picker Modal -->
<div class="modal-overlay" id="duration-modal" onclick="if(event.target === this) closeDurationModal()">
  <div class="modal-card">
    <div class="modal-title">Default Focus Duration</div>
    <div class="modal-desc">Set your preferred standard session time</div>
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin: 16px 0;">
      <button class="preset-btn" onclick="setDefaultDuration(15)">15 min</button>
      <button class="preset-btn active" onclick="setDefaultDuration(25)">25 min</button>
      <button class="preset-btn" onclick="setDefaultDuration(45)">45 min</button>
      <button class="preset-btn" onclick="setDefaultDuration(60)">60 min</button>
    </div>
    <button class="modal-btn cancel" onclick="closeDurationModal()" style="width: 100%;">Close</button>
  </div>
</div>

<!-- Edit Profile Modal with Gallery / Photo Upload -->
<div class="modal-overlay" id="edit-profile-modal" onclick="if(event.target === this) closeEditProfileModal()">
  <div class="modal-card">
    <div class="modal-title">Edit Profile</div>
    <div class="modal-desc">Upload your photo or choose a custom mascot</div>

    <!-- Clickable Live Preview with Camera Icon -->
    <div class="edit-avatar-container" onclick="document.getElementById('avatar-file-input').click()" title="Tap to choose photo from gallery">
      <img id="edit-modal-avatar-preview" src="/sprites/user_avatar_dmess.png" alt="Avatar Preview">
      <div class="edit-avatar-camera-btn">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 15.2a3.2 3.2 0 1 0 0-6.4 3.2 3.2 0 0 0 0 6.4zM9 2L7.17 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2h-3.17L15 2H9zm3 15c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5z"/></svg>
      </div>
    </div>

    <!-- Hidden Native File Picker for Camera & Photo Gallery -->
    <input type="file" id="avatar-file-input" accept="image/*" style="display: none;" onchange="handleGalleryUpload(event)">

    <!-- Button to trigger gallery/photos on phone -->
    <button class="btn-gallery-pick" onclick="document.getElementById('avatar-file-input').click()">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/></svg>
      <span>Add from Gallery / Photos</span>
    </button>

    <div style="margin: 0 0 8px; font-size: 12px; font-weight: 700; color: var(--text-muted); text-align: left;">Or Pick Preset Avatar</div>
    <div class="avatar-choice-grid">
      <div class="avatar-choice-item" id="avt-opt-angel" onclick="selectAvatarOption('/sprites/user_avatar_dmess.png', 'avt-opt-angel')" title="Dmess">
        <img src="/sprites/user_avatar_dmess.png" alt="Dmess">
      </div>
      <div class="avatar-choice-item" id="avt-opt-dmess" onclick="selectAvatarOption('/sprites/user_avatar_dmess.png', 'avt-opt-dmess')" title="Dmess Dev">
        <img src="/sprites/user_avatar_dmess.png" alt="Dmess Dev">
      </div>
      <div class="avatar-choice-item" id="avt-opt-guest" onclick="selectAvatarOption('/sprites/user_avatar_guest.png', 'avt-opt-guest')" title="Guest Duck">
        <img src="/sprites/user_avatar_guest.png" alt="Guest Duck">
      </div>
      <div class="avatar-choice-item" id="avt-opt-ninja" onclick="selectAvatarOption('/sprites/wardrobe_05_ninja_front.png', 'avt-opt-ninja')" title="Ninja">
        <img src="/sprites/wardrobe_05_ninja_front.png" alt="Ninja Duck" style="image-rendering: pixelated; width: 36px; height: 36px;">
      </div>
      <div class="avatar-choice-item" id="avt-opt-wizard" onclick="selectAvatarOption('/sprites/wardrobe_06_wizard_front.png', 'avt-opt-wizard')" title="Wizard">
        <img src="/sprites/wardrobe_06_wizard_front.png" alt="Wizard Duck" style="image-rendering: pixelated; width: 36px; height: 36px;">
      </div>
    </div>

    <input class="modal-input-field" id="input-edit-name" placeholder="Display Name (e.g. Angel)" value="Dmess">
    <input class="modal-input-field" id="input-edit-handle" placeholder="Handle (e.g. @yea)" value="@yea">

    <div class="modal-actions">
      <button class="modal-btn cancel" onclick="closeEditProfileModal()">Cancel</button>
      <button class="modal-btn confirm" onclick="saveProfileChanges()">Save Changes</button>
    </div>
  </div>
</div>

<!-- Account Switcher / Login Modal -->
<div class="modal-overlay" id="auth-modal" onclick="if(event.target === this) closeAuthModal()">
  <div class="modal-card">
    <div class="modal-title" id="auth-modal-title">Account &amp; Login</div>
    <div class="modal-desc" id="auth-modal-desc">Switch profile or log into your Lockin account</div>

    <div style="display: flex; flex-direction: column; gap: 8px; margin: 16px 0; text-align: left;">
      <div class="setting-row" style="padding: 10px; border: 1.5px solid var(--border); border-radius: 16px;" onclick="loginAs('Angel', '@yea', 'Pro Member', '/sprites/user_avatar_dmess.png')">
        <img id="auth-img-yea" src="/sprites/user_avatar_dmess.png" style="width: 38px; height: 38px; border-radius: 50%; object-fit: cover;">
        <div class="setting-info">
          <div class="setting-title">Angel</div>
          <div class="setting-desc">@yea • Pro Member</div>
        </div>
        <div style="font-size: 11px; font-weight: 800; color: var(--primary);" id="auth-status-yea">Active</div>
      </div>

      <div class="setting-row" style="padding: 10px; border: 1.5px solid var(--border); border-radius: 16px;" onclick="loginAs('Dmess', '@dev', 'Pro Member', '/sprites/user_avatar_dmess.png')">
        <img id="auth-img-dev" src="/sprites/user_avatar_dmess.png" style="width: 38px; height: 38px; border-radius: 50%; object-fit: cover; background: #1C1F2E;">
        <div class="setting-info">
          <div class="setting-title">Dmess</div>
          <div class="setting-desc">@dev • Pro Member</div>
        </div>
        <div style="font-size: 11px; font-weight: 800; color: var(--primary); display: none;" id="auth-status-dev">Active</div>
      </div>

      <div class="setting-row" style="padding: 10px; border: 1.5px solid var(--border); border-radius: 16px;" onclick="loginAs('Guest Explorer', '@explorer', 'Free Tier', '/sprites/user_avatar_guest.png')">
        <img id="auth-img-explorer" src="/sprites/user_avatar_guest.png" style="width: 38px; height: 38px; border-radius: 50%; object-fit: cover; background: #FFF;">
        <div class="setting-info">
          <div class="setting-title">Guest Explorer</div>
          <div class="setting-desc">@explorer • Free Tier</div>
        </div>
        <div style="font-size: 11px; font-weight: 800; color: var(--primary); display: none;" id="auth-status-explorer">Active</div>
      </div>
    </div>

    <div class="modal-actions">
      <button class="modal-btn cancel" onclick="closeAuthModal()">Close</button>
      <button class="modal-btn confirm" style="background: #FF3B30;" onclick="signOutUser()">Sign Out</button>
    </div>
  </div>
</div>

<!-- Purchase Modal -->
<div class="modal-overlay" id="purchase-modal">
  <div class="modal-card">
    <div class="modal-duck-circle">
      <img id="modal-hat-img" src="" alt="Hat Preview">
    </div>
    <div class="modal-title" id="modal-hat-title">Unlock Accessory</div>
    <div class="modal-desc" id="modal-hat-desc">Do you want to unlock this hat for your Duck?</div>
    <div class="modal-actions">
      <button class="modal-btn cancel" onclick="closeModal()">Cancel</button>
      <button class="modal-btn confirm" id="modal-confirm-btn" onclick="confirmPurchase()">Buy &amp; Equip</button>
    </div>
  </div>
</div>

<div id="app-frame">
  <!-- Top Header -->
  <div class="header">
    <div class="header-left">
      <div class="avatar" id="header-avatar-btn" onclick="toggleProfileScreen()" title="Profile & Settings">
        <img id="header-avatar-img" src="/sprites/bongo_typing_frame_0.png" alt="Duck Avatar">
      </div>
      <div class="brand-title">Lockin</div>
    </div>
    <div class="header-right">
      <div class="coin-badge" onclick="switchTab('wardrobe')">
        <svg class="coin-icon-svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 6v12M8 9h8M8 15h8" stroke="#FFF" stroke-width="2" stroke-linecap="round"/></svg>
        <span id="header-coins-text">350</span>
      </div>
      <div class="status-badge" id="wifi-status">
        <div class="status-dot"></div>
      </div>
    </div>
  </div>

  <!-- SCREEN 1: FOCUS TIMER -->
  <div id="screen-home" class="screen active">
    <div class="greeting-title">Focus &amp; Earn</div>
    <div class="greeting-sub" id="hero-subtitle">Earn 2 Focus Coins / min + 100 on session completion</div>

    <!-- Duration Presets (100% Centered) -->
    <div class="presets-row">
      <div class="preset-btn active" id="preset-25" onclick="selectPreset(25, 'focus')">
        <div class="preset-time">25m</div>
        <div class="preset-desc">+150 Coins</div>
      </div>
      <div class="preset-btn" id="preset-50" onclick="selectPreset(50, 'focus')">
        <div class="preset-time">50m</div>
        <div class="preset-desc">+200 Coins</div>
      </div>
      <div class="preset-btn" id="preset-5" onclick="selectPreset(5, 'shortBreak')">
        <div class="preset-time">5m</div>
        <div class="preset-desc">Break</div>
      </div>
      <div class="preset-btn" id="preset-15" onclick="selectPreset(15, 'longBreak')">
        <div class="preset-time">15m</div>
        <div class="preset-desc">Rest</div>
      </div>
    </div>

    <!-- Main Pomodoro Ring Card -->
    <div class="timer-card">
      <div class="ring-container">
        <svg class="ring-svg" viewBox="0 0 220 220">
          <circle class="ring-bg" cx="110" cy="110" r="95"></circle>
          <circle class="ring-progress" id="progress-circle" cx="110" cy="110" r="95"
                  stroke-dasharray="596.9" stroke-dashoffset="0"></circle>
        </svg>
        <div class="ring-center">
          <div class="timer-digits" id="timer-text">25:00</div>
          <div class="timer-label" id="timer-mode-label">FOCUS MODE</div>
          <div class="reward-hint">
            <svg class="coin-icon-svg" style="width:12px;height:12px;" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/></svg>
            <span>+100 Coins upon finish</span>
          </div>
        </div>
      </div>

      <!-- Action Button Group - Centered -->
      <div id="pomo-idle-controls" style="width: 100%; display: flex; justify-content: center; align-items: center;">
        <button class="btn-primary" onclick="startPomodoro()">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
          <span>START LOCKIN</span>
        </button>
      </div>

      <div id="pomo-active-controls" class="btn-control-group" style="display: none;">
        <button class="btn-secondary" id="btn-pause" onclick="togglePausePomodoro()">
          <svg id="pause-icon-svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>
          <span id="pause-btn-text">PAUSE</span>
        </button>
        <button class="btn-secondary danger" onclick="stopPomodoro()">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M6 6h12v12H6z"/></svg>
          <span>STOP</span>
        </button>
      </div>
    </div>

    <!-- FEATURE 1: SPOTIFY / APPLE MUSIC MINI PLAYER -->
    <div class="spotify-card">
      <div class="spotify-info">
        <div class="spotify-icon-box">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.66 0 12 0zm5.521 17.34c-.24.359-.66.48-1.021.24-2.82-1.74-6.36-2.101-10.561-1.141-.418.122-.779-.179-.899-.539-.12-.421.18-.78.54-.9 4.56-1.021 8.52-.6 11.64 1.32.42.18.479.659.301 1.02zm1.44-3.3c-.301.42-.841.6-1.262.3-3.239-1.98-8.159-2.58-11.939-1.38-.479.12-1.02-.12-1.14-.6-.12-.48.12-1.021.6-1.141C9.6 9.9 15 10.561 18.72 12.84c.361.181.54.78.241 1.2zm.12-3.36C15.24 8.4 8.82 8.16 5.16 9.301c-.6.179-1.2-.181-1.38-.721-.18-.601.18-1.2.72-1.381 4.26-1.26 11.28-1.02 15.721 1.621.539.3.719 1.02.419 1.56-.299.421-1.02.599-1.559.3z"/></svg>
        </div>
        <div class="spotify-text">
          <div class="spotify-title" id="music-track-text">No Music Playing</div>
          <div class="spotify-artist" id="music-artist-text">Mac Audio Sync</div>
        </div>
      </div>
      <div class="spotify-controls">
        <button class="spotify-btn" onclick="musicAction('previous')">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/></svg>
        </button>
        <button class="spotify-btn" onclick="musicAction('playpause')">
          <svg id="music-playpause-icon" width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
        </button>
        <button class="spotify-btn" onclick="musicAction('next')">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/></svg>
        </button>
      </div>
    </div>

    <!-- FEATURE 2: TAMAGOTCHI & DUCK MOOD STATUS -->
    <div class="tamagotchi-card">
      <div class="tamagotchi-top">
        <div class="duck-mascot-avatar">
          <img id="hero-duck-img" src="/sprites/pomodoro_study_duck.png" alt="Duck Companion">
        </div>
        <div style="flex: 1;">
          <div class="tamagotchi-mood-tag" id="tamagotchi-tag">COMPANION</div>
          <div class="tamagotchi-mood-title" id="tamagotchi-title">Lockin Duck</div>
          <div class="tamagotchi-mood-desc" id="tamagotchi-desc">Desk companion aktif menemani fokusmu.</div>
        </div>
      </div>

      <!-- Tamagotchi Stat Bars -->
      <div class="t-stats-grid">
        <div class="t-stat-item">
          <div class="t-stat-label"><span>Energi</span><span id="stat-energy-text">100%</span></div>
          <div class="t-stat-bar"><div class="t-stat-fill" id="stat-energy-bar" style="width:100%; background:#00D084;"></div></div>
        </div>
        <div class="t-stat-item">
          <div class="t-stat-label"><span>Kenyang</span><span id="stat-hunger-text">85%</span></div>
          <div class="t-stat-bar"><div class="t-stat-fill" id="stat-hunger-bar" style="width:85%; background:#FFB800;"></div></div>
        </div>
        <div class="t-stat-item">
          <div class="t-stat-label"><span>Senang</span><span id="stat-happy-text">95%</span></div>
          <div class="t-stat-bar"><div class="t-stat-fill" id="stat-happy-bar" style="width:95%; background:#FF007A;"></div></div>
        </div>
      </div>

      <!-- Quick Care Buttons -->
      <div class="duck-care-row">
        <button class="duck-care-btn" onclick="careAction('pet', 'Loved &amp; Petted Duck!')">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="#FF007A"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
          <span>Pet Duck</span>
        </button>
        <button class="duck-care-btn" onclick="careAction('feed', 'Fed Bread! 100% Full')">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="#FFB800"><path d="M18.06 22.99h-12c-1.66 0-3-1.34-3-3v-10c0-1.66 1.34-3 3-3h12c1.66 0 3 1.34 3 3v10c0 1.66-1.34 3-3 3zM6.06 8.99v10h12v-10h-12zM12 1a5 5 0 0 1 5 5h-2a3 3 0 0 0-6 0H7a5 5 0 0 1 5-5z"/></svg>
          <span>Feed Bread</span>
        </button>
      </div>
    </div>

    <!-- FEATURE 3: CUSTOM SOUND FX SELECTION -->
    <div class="soundfx-card">
      <div class="soundfx-title">Pomodoro Bell Sound FX</div>
      <div class="soundfx-row">
        <div class="soundfx-pill active" id="sfx-lofi" onclick="selectSoundFX('lofi')">
          <span>Lofi Chime</span>
          <span style="font-size:10px; opacity:0.7;">Soft</span>
        </div>
        <div class="soundfx-pill" id="sfx-retro" onclick="selectSoundFX('retro')">
          <span>Retro Win</span>
          <span style="font-size:10px; opacity:0.7;">8-Bit Game</span>
        </div>
        <div class="soundfx-pill" id="sfx-gong" onclick="selectSoundFX('gong')">
          <span>Calm Gong</span>
          <span style="font-size:10px; opacity:0.7;">Zen Calm</span>
        </div>
      </div>
    </div>

    <!-- Focus Goal Task Card -->
    <div class="task-input-card">
      <div class="task-input-header">
        <span class="task-input-title">Focus Target on Mac</span>
        <span style="font-size: 11px; color: var(--text-muted);">Shows on duck board</span>
      </div>
      <div class="task-input-box">
        <input type="text" id="focus-task-input" placeholder="e.g. Selesaikan Fitur UI, Coding, Reading" onkeydown="if(event.key===Enter) saveFocusTask()">
        <button class="task-save-btn" onclick="saveFocusTask()">Set</button>
      </div>
    </div>
  </div>

  <!-- SCREEN 2: BREAK TIME (NO COIN CHEAT - PURE HYDRATION) -->
  <div id="screen-break" class="screen">
    <div class="greeting-title">Break Time</div>
    <div class="greeting-sub">Rest your eyes, breathe, and hydrate</div>

    <div class="break-card">
      <div class="break-duck-circle">
        <img id="break-duck-img" src="/sprites/drinking_water_frame_0.png" alt="Resting Duck">
      </div>
      <div class="timer-digits" id="break-digits" style="font-size: 52px; margin-bottom: 8px;">05:00</div>
      <div class="timer-label" style="margin-bottom: 20px;">REST &amp; RECHARGE</div>

      <button class="hydration-btn" onclick="logWater()">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"/></svg>
        <span id="water-btn-text">Drink 250ml Water (Logged: 0ml)</span>
      </button>

      <button class="btn-primary" style="margin: 16px auto 0 auto;" onclick="stopPomodoro(); switchTab('home');">
        <span>End Break &amp; Return</span>
      </button>
    </div>
  </div>

  <!-- SCREEN 3: DUCK WARDROBE & SHOP -->
  <div id="screen-wardrobe" class="screen">
    <div class="greeting-title">Duck Shop</div>
    <div class="greeting-sub">Earn Focus Coins by working hard and unlock hats</div>

    <div class="shop-header-card">
      <div class="shop-duck-avatar">
        <img id="wardrobe-active-duck-img" src="/sprites/wardrobe_01_none_front.png" alt="Active Duck">
      </div>
      <div>
        <div style="font-size: 11px; font-weight: 800; color: #FF66B2; letter-spacing: 1px;">EQUIPPED ON MAC</div>
        <div style="font-size: 18px; font-weight: 900; margin: 2px 0;" id="wardrobe-active-hat-name">Classic Duck</div>
        <div style="font-size: 13px; color: #FFB800; font-weight: 800;" id="shop-balance-display">Balance: 350 Focus Coins</div>
      </div>
    </div>

    <div class="wardrobe-grid" id="wardrobe-grid-container"></div>
  </div>

  <!-- SCREEN 4: PROFILE & SETTINGS (Matching Figma LockIn Profile & Settings.png) -->
  <div id="screen-settings" class="screen">
    <!-- Top Header Bar -->
    <div class="profile-header-bar">
      <button class="btn-profile-back" onclick="switchTab('home')" title="Back to Focus">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/></svg>
      </button>
      <div class="brand-title" style="font-size: 26px;">Lockin</div>
      <div style="width: 40px;"></div>
    </div>

    <!-- 1. Profile Hero Card -->
    <div class="profile-card">
      <div class="profile-avatar-wrap">
        <img id="profile-avatar-img" src="/sprites/user_avatar_dmess.png" alt="User Avatar">
        <button class="avatar-edit-badge" onclick="openEditProfileModal()" title="Edit Profile">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
        </button>
      </div>
      <div class="profile-name" id="profile-name-text">Angel</div>
      <div class="profile-handle" id="profile-handle-text">@yea</div>
      <div class="profile-badge-pro" id="profile-tier-badge">Pro Member</div>

      <div class="profile-balance-container">
        <div class="profile-balance-left">
          <div class="profile-balance-label">Available Balance</div>
          <div class="profile-balance-val">
            <span id="profile-balance-num">2,450</span> <span class="profile-pts-suffix">pts</span>
          </div>
        </div>
        <button class="profile-shop-btn" onclick="switchTab('wardrobe')">Shop</button>
      </div>

      <div class="profile-level-row">
        <span id="profile-tier-desc">550 pts to Platinum</span>
        <span class="profile-level-pct" id="profile-tier-pct">82%</span>
      </div>
      <div class="profile-progress-track">
        <div class="profile-progress-fill" id="profile-tier-bar" style="width: 82%;"></div>
      </div>
    </div>

    <!-- 2. Daily Goals Card -->
    <div class="goals-card">
      <div class="goals-title">Daily Goals</div>

      <div class="goal-item">
        <div class="goal-header">
          <div class="goal-left">
            <div class="goal-icon-circle">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/></svg>
            </div>
            <div class="goal-name">Deep Focus</div>
          </div>
          <div class="goal-val"><span id="goal-focus-hours">2.5</span> / 4 hrs</div>
        </div>
        <div class="goal-progress-track">
          <div class="goal-progress-fill" id="goal-focus-bar" style="width: 62.5%;"></div>
        </div>
      </div>

      <div class="goal-item" style="margin-top: 14px;">
        <div class="goal-header">
          <div class="goal-left">
            <div class="goal-icon-circle">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
            </div>
            <div class="goal-name">Tasks Completed</div>
          </div>
          <div class="goal-val"><span id="goal-tasks-count">5</span> / 8 tasks</div>
        </div>
        <div class="goal-progress-track">
          <div class="goal-progress-fill" id="goal-tasks-bar" style="width: 62.5%;"></div>
        </div>
      </div>
    </div>

    <!-- 3. Preferences & Settings Card -->
    <div class="settings-list-card">
      <!-- Default Focus Duration -->
      <div class="setting-row" onclick="openDurationModal()">
        <div class="setting-icon-circle">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M6 2v6h.01L6 8.01 10 12l-4 4 .01.01H6V22h12v-5.99h-.01L18 16l-4-4 4-3.99-.01-.01H18V2H6zm10 14.5V20H8v-3.5l4-4 4 4zM12 11.5L8 7.5V4h8v3.5l-4 4z"/></svg>
        </div>
        <div class="setting-info">
          <div class="setting-title">Default Focus Duration</div>
          <div class="setting-desc">Set your standard session time</div>
        </div>
        <div class="setting-value" id="pref-duration-label">25 min</div>
        <svg class="chevron-icon" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/></svg>
      </div>

      <div class="setting-divider"></div>

      <!-- Theme -->
      <div class="setting-row" onclick="openThemeModal()">
        <div class="setting-icon-circle" style="background: var(--primary);">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 3c-4.97 0-9 4.03-9 9 0 2.12.74 4.07 1.97 5.61L4.35 19.4c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0l1.9-1.9C9.28 19.57 10.58 20 12 20c4.97 0 9-4.03 9-9s-4.03-9-9-9zm0 15c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6z"/></svg>
        </div>
        <div class="setting-info">
          <div class="setting-title">Theme</div>
          <div class="setting-desc">Set your personal theme</div>
        </div>
        <div class="setting-value" id="pref-theme-label">Classic Pink</div>
        <svg class="chevron-icon" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/></svg>
      </div>

      <div class="setting-divider"></div>

      <!-- Push Notifications -->
      <div class="setting-row">
        <div class="setting-icon-circle">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z"/></svg>
        </div>
        <div class="setting-info">
          <div class="setting-title">Push Notifications</div>
          <div class="setting-desc">Reminders and session alerts</div>
        </div>
        <label class="toggle-switch">
          <input type="checkbox" id="pref-push-notif" checked onchange="togglePushNotifs(this.checked)">
          <span class="toggle-slider"></span>
        </label>
      </div>

      <div class="setting-divider"></div>

      <!-- Dark Theme -->
      <div class="setting-row">
        <div class="setting-icon-circle" style="background: #2D3146;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 3c-4.97 0-9 4.03-9 9 0 2.12.74 4.07 1.97 5.61.38.48.97.74 1.57.74.34 0 .68-.09.98-.26 1.83-1.07 3.97-1.69 6.23-1.69 6.84 0 12.44 5.38 12.74 12.14.02.48.24.93.61 1.23.36.31.84.45 1.31.38.48-.07.9-.34 1.17-.74 1.55-2.29 2.39-4.98 2.39-7.8 0-7.73-6.27-14-14-14z"/></svg>
        </div>
        <div class="setting-info">
          <div class="setting-title">Dark Theme</div>
          <div class="setting-desc">Reduce eye strain at night</div>
        </div>
        <label class="toggle-switch">
          <input type="checkbox" id="pref-dark-theme" onchange="toggleDarkTheme(this.checked)">
          <span class="toggle-slider"></span>
        </label>
      </div>
    </div>

    <!-- 4. Desk Duck Remote Controls Card -->
    <div class="settings-list-card" style="padding: 16px 18px;">
      <div style="font-size: 14px; font-weight: 800; margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between;">
        <span>Desk Duck Remote Controls</span>
        <span style="font-size: 11px; font-weight: 700; color: var(--success);">Wi-Fi Connected (8765)</span>
      </div>
      <div class="remote-grid">
        <button class="btn-remote" onclick="sendDuckAction('summon', 'Summoned Duck to Mouse')">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M13.64 21.97l-4.22-8.66-4.66 4.67V2l15.66 11.34-6.4 1.29 4.22 8.66-4.6 2.68z"/></svg>
          <span>Summon</span>
        </button>
        <button class="btn-remote" onclick="sendDuckAction('perch', 'Perched on Window')">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V8h14v11z"/></svg>
          <span>Perch Window</span>
        </button>
        <button class="btn-remote" onclick="sendDuckAction('pond', 'Sent Duck to Pond')">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 3a9 9 0 1 0 9 9c0-.46-.04-.92-.1-1.36a5.389 5.389 0 0 1-4.4 2.26 5.403 5.403 0 0 1-3.14-1 5.4 5.4 0 0 1-6.28 0 5.4 5.4 0 0 1-3.14 1c-.34 0-.68-.03-1.01-.1A9.01 9.01 0 0 0 12 21a9 9 0 0 0 9-9c0-4.97-4.03-9-9-9z"/></svg>
          <span>Send to Pond</span>
        </button>
        <button class="btn-remote" onclick="sendDuckAction('toggleVis', 'Toggled Duck Visibility')">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>
          <span>Hide / Show</span>
        </button>
      </div>
    </div>

    <!-- 5. Account Section -->
    <div class="goals-card" style="margin-top: 14px;">
      <div class="goals-title">Account</div>

      <div class="account-row" onclick="openEditProfileModal()">
        <div class="account-icon-wrap">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
        </div>
        <div class="account-row-title">Edit Profile</div>
        <svg class="chevron-icon" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/></svg>
      </div>

      <div class="setting-divider"></div>

      <div class="account-row" onclick="openAuthModal()">
        <div class="account-icon-wrap" style="color: #FF3B30; background: #FFF0F0;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg>
        </div>
        <div class="account-row-title" style="color: #FF3B30;" id="account-auth-action-text">Sign Out / Switch Account</div>
        <svg class="chevron-icon" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/></svg>
      </div>
    </div>
  </div>

  <!-- Bottom Navigation Tab Bar -->
  <div class="tab-bar">
    <div class="tab-item active" id="nav-home" onclick="switchTab('home')">
      <svg class="tab-icon-svg" viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
      <div>Focus</div>
    </div>
    <div class="tab-item" id="nav-break" onclick="switchTab('break')">
      <svg class="tab-icon-svg" viewBox="0 0 24 24"><path d="M20 3H4v10c0 2.21 1.79 4 4 4h6c2.21 0 4-1.79 4-4v-3h2c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 5h-2V5h2v3zM4 19h16v2H4z"/></svg>
      <div>Break</div>
    </div>
    <div class="tab-item" id="nav-wardrobe" onclick="switchTab('wardrobe')">
      <svg class="tab-icon-svg" viewBox="0 0 24 24"><path d="M12 2C9.24 2 7 4.24 7 7c0 .59.1 1.15.3 1.67L3 13v7c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2v-7l-4.3-4.33c.2-.52.3-1.08.3-1.67 0-2.76-2.24-5-5-5zm0 2c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3z"/></svg>
      <div>Shop</div>
    </div>
    <div class="tab-item" id="nav-settings" onclick="switchTab('settings')">
      <svg class="tab-icon-svg" viewBox="0 0 24 24"><path d="M19.14 12.94c.04-.3.06-.61.06-.94 0-.32-.02-.64-.07-.94l2.03-1.58c.18-.14.23-.41.12-.61l-1.92-3.32c-.12-.22-.37-.29-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54c-.04-.24-.24-.41-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.05.3-.09.63-.09.94s.02.64.07.94l-2.03 1.58c-.18.14-.23.41-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z"/></svg>
      <div>Remote</div>
    </div>
  </div>
</div>

<script>

  // --- Profile & Authentication State (Per-Account Isolated) ---
  let currentUser = {
    name: "Dmess",
    handle: "@yea",
    tier: "Pro Member",
    avatar: "/sprites/user_avatar_dmess.png"
  };
  let selectedAvatarChoice = "/sprites/user_avatar_dmess.png";
  let currentTheme = "pink";

  function getAccountKey(handle) {
    return "lockin_account_" + (handle || "").replace("@", "").toLowerCase();
  }

  function getStoredAccount(handle, defaultName, defaultTier, defaultAvatar) {
    const key = getAccountKey(handle);
    const saved = localStorage.getItem(key);
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        if (parsed && parsed.avatar) return parsed;
      } catch(e) {}
    }
    return {
      name: defaultName,
      handle: handle,
      tier: defaultTier,
      avatar: defaultAvatar
    };
  }

  function saveStoredAccount(acc) {
    const key = getAccountKey(acc.handle);
    localStorage.setItem(key, JSON.stringify(acc));
  }

  function toggleProfileScreen() {
    const settingsScreen = document.getElementById("screen-settings");
    if (settingsScreen && settingsScreen.classList.contains("active")) {
      switchTab("home");
    } else {
      switchTab("settings");
    }
  }

  function openThemeModal() {
    document.getElementById("theme-modal").classList.add("active");
  }

  function closeThemeModal() {
    document.getElementById("theme-modal").classList.remove("active");
  }

  function setAppTheme(theme) {
    currentTheme = theme;
    document.querySelectorAll(".theme-check-radio").forEach(r => r.classList.remove("selected"));
    const radio = document.getElementById("radio-theme-" + theme);
    if (radio) radio.classList.add("selected");

    const label = document.getElementById("pref-theme-label");
    if (theme === "blue") {
      document.documentElement.style.setProperty("--primary", "#007AFF");
      document.documentElement.style.setProperty("--primary-light", "#EBF3FF");
      document.documentElement.style.setProperty("--primary-glow", "rgba(0, 122, 255, 0.28)");
      if (label) label.innerText = "Classic Blue";
      showToast("Theme set to Classic Blue");
    } else {
      document.documentElement.style.setProperty("--primary", "#FF007A");
      document.documentElement.style.setProperty("--primary-light", "#FFEBF4");
      document.documentElement.style.setProperty("--primary-glow", "rgba(255, 0, 122, 0.28)");
      if (label) label.innerText = "Classic Pink";
      showToast("Theme set to Classic Pink");
    }
    localStorage.setItem("lockin_theme", theme);
    closeThemeModal();
  }

  function openDurationModal() {
    document.getElementById("duration-modal").classList.add("active");
  }

  function closeDurationModal() {
    document.getElementById("duration-modal").classList.remove("active");
  }

  function setDefaultDuration(mins) {
    selectedMinutes = mins;
    document.getElementById("pref-duration-label").innerText = mins + " min";
    document.querySelectorAll(".preset-btn").forEach(b => b.classList.remove("active"));
    const b = document.getElementById("preset-" + mins);
    if (b) b.classList.add("active");
    showToast("Default focus set to " + mins + "m");
    closeDurationModal();
  }

  function openEditProfileModal() {
    document.getElementById("input-edit-name").value = currentUser.name;
    document.getElementById("input-edit-handle").value = currentUser.handle;
    document.getElementById("edit-modal-avatar-preview").src = currentUser.avatar || "/sprites/user_avatar_dmess.png";
    selectedAvatarChoice = currentUser.avatar;

    document.querySelectorAll(".avatar-choice-item").forEach(a => a.classList.remove("selected"));
    document.getElementById("edit-profile-modal").classList.add("active");
  }

  function closeEditProfileModal() {
    document.getElementById("edit-profile-modal").classList.remove("active");
  }

  function selectAvatarOption(url, optId) {
    selectedAvatarChoice = url;
    document.getElementById("edit-modal-avatar-preview").src = url;
    document.querySelectorAll(".avatar-choice-item").forEach(a => a.classList.remove("selected"));
    const el = document.getElementById(optId);
    if (el) el.classList.add("selected");
  }

  // Handle Photo Picker from Phone Gallery / Camera
  function handleGalleryUpload(event) {
    const file = event.target.files && event.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function(e) {
      const img = new Image();
      img.onload = function() {
        // High quality square crop to 256x256
        const canvas = document.createElement("canvas");
        const size = 256;
        canvas.width = size;
        canvas.height = size;
        const ctx = canvas.getContext("2d");

        const minDim = Math.min(img.width, img.height);
        const sx = (img.width - minDim) / 2;
        const sy = (img.height - minDim) / 2;

        ctx.drawImage(img, sx, sy, minDim, minDim, 0, 0, size, size);
        const dataUrl = canvas.toDataURL("image/jpeg", 0.88);

        // Immediately update preview
        selectedAvatarChoice = dataUrl;
        document.getElementById("edit-modal-avatar-preview").src = dataUrl;
        document.querySelectorAll(".avatar-choice-item").forEach(a => a.classList.remove("selected"));

        // Upload to server
        fetch("/api/profile/upload_avatar", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ image: dataUrl })
        })
        .then(r => r.json())
        .then(res => {
          if (res.avatarUrl) {
            selectedAvatarChoice = res.avatarUrl;
          }
        })
        .catch(() => {});

        showToast("Photo loaded from gallery! Click Save Changes.");
      };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  }

  async function saveProfileChanges() {
    const nameVal = document.getElementById("input-edit-name").value.trim() || currentUser.name;
    const handleVal = document.getElementById("input-edit-handle").value.trim() || currentUser.handle;

    currentUser.name = nameVal;
    currentUser.handle = handleVal;
    currentUser.avatar = selectedAvatarChoice;

    applyUserProfileUI();
    saveStoredAccount(currentUser);
    localStorage.setItem("lockin_active_handle", currentUser.handle);

    try {
      await fetch("/api/profile/update", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: currentUser.name,
          handle: currentUser.handle,
          avatar: currentUser.avatar,
          tier: currentUser.tier
        })
      });
    } catch(e) {}

    showToast("Profile & Photo saved successfully!");
    closeEditProfileModal();
  }

  function openAuthModal() {
    // Update active badges in auth modal
    const curH = (currentUser.handle || "").replace("@", "").toLowerCase();
    ["yea", "dev", "explorer"].forEach(h => {
      const statusEl = document.getElementById("auth-status-" + h);
      const imgEl = document.getElementById("auth-img-" + h);
      if (statusEl) statusEl.style.display = (h === curH) ? "block" : "none";

      // Show user's actual stored avatar in auth list
      const acc = getStoredAccount("@" + h, "", "", "");
      if (imgEl && acc.avatar) imgEl.src = acc.avatar;
    });

    document.getElementById("auth-modal").classList.add("active");
  }

  function closeAuthModal() {
    document.getElementById("auth-modal").classList.remove("active");
  }

  async function loginAs(name, handle, tier, defaultAvatar) {
    // Load account with its OWN saved avatar (never shared with other accounts!)
    const account = getStoredAccount(handle, name, tier, defaultAvatar);
    currentUser = account;
    selectedAvatarChoice = account.avatar;

    applyUserProfileUI();
    localStorage.setItem("lockin_active_handle", handle);

    try {
      await fetch("/api/profile/update", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(currentUser)
      });
    } catch(e) {}

    showToast("Logged in as " + currentUser.name);
    closeAuthModal();
  }

  function signOutUser() {
    currentUser = {
      name: "Guest",
      handle: "@explorer",
      tier: "Free Tier",
      avatar: "/sprites/bongo_typing_frame_0.png"
    };
    applyUserProfileUI();
    localStorage.removeItem("lockin_user");
    showToast("Signed out. Switched to Guest mode.");
    closeAuthModal();
  }

  function applyUserProfileUI() {
    const nameEl = document.getElementById("profile-name-text");
    const handleEl = document.getElementById("profile-handle-text");
    const tierEl = document.getElementById("profile-tier-badge");
    const avtEl = document.getElementById("profile-avatar-img");
    const authText = document.getElementById("account-auth-action-text");

    if (nameEl) nameEl.innerText = currentUser.name;
    if (handleEl) handleEl.innerText = currentUser.handle;
    if (tierEl) tierEl.innerText = currentUser.tier;
    if (avtEl) avtEl.src = currentUser.avatar;

    if (authText) {
      authText.innerText = currentUser.name === "Guest" ? "Sign In / Switch Account" : "Sign Out (" + currentUser.name + ")";
    }
  }

  function toggleDarkTheme(isDark) {
    if (isDark) {
      document.body.classList.add("dark-mode");
      localStorage.setItem("lockin_dark_theme", "true");
    } else {
      document.body.classList.remove("dark-mode");
      localStorage.setItem("lockin_dark_theme", "false");
    }
  }

  function togglePushNotifs(enabled) {
    localStorage.setItem("lockin_push_notif", enabled ? "true" : "false");
    showToast(enabled ? "Push notifications enabled" : "Push notifications muted");
  }

  // Restore preferences on boot
  (function initUserPrefs() {
    const savedDark = localStorage.getItem("lockin_dark_theme");
    const darkCheckbox = document.getElementById("pref-dark-theme");
    if (savedDark === "true") {
      document.body.classList.add("dark-mode");
      if (darkCheckbox) darkCheckbox.checked = true;
    }

    const savedTheme = localStorage.getItem("lockin_theme");
    if (savedTheme) {
      setAppTheme(savedTheme);
    }

    const activeHandle = localStorage.getItem("lockin_active_handle") || "@yea";
    currentUser = getStoredAccount(activeHandle, "Dmess", "Pro Member", "/sprites/user_avatar_dmess.png");
    selectedAvatarChoice = currentUser.avatar;
    applyUserProfileUI();
  })();

  let currentState = null;
  let selectedMinutes = 25;
  let selectedMode = 'focus';
  let waterTotal = 0;
  let pendingHatPurchase = null;
  let currentSoundFX = "lofi";

  const CIRCLE_RADIUS = 95;
  const CIRCLE_CIRCUMFERENCE = 2 * Math.PI * CIRCLE_RADIUS;

  const HATS = [
    { id: "none", name: "Classic Duck", img: "/sprites/wardrobe_01_none_front.png", price: 0, rarity: "Common" },
    { id: "sunglasses", name: "Cool Sunglasses", img: "/sprites/wardrobe_02_sunglasses_front.png", price: 150, rarity: "Common" },
    { id: "straw", name: "Straw Hat", img: "/sprites/wardrobe_08_straw_front.png", price: 250, rarity: "Common" },
    { id: "hardhat", name: "Hard Hat", img: "/sprites/wardrobe_09_hardhat_front.png", price: 400, rarity: "Rare" },
    { id: "cowboy", name: "Cowboy Hat", img: "/sprites/wardrobe_03_cowboy_front.png", price: 600, rarity: "Rare" },
    { id: "sprout", name: "Plant Sprout", img: "/sprites/wardrobe_10_sprout_front.png", price: 750, rarity: "Rare" },
    { id: "detective", name: "Detective Cap", img: "/sprites/wardrobe_07_detective_front.png", price: 900, rarity: "Epic" },
    { id: "ninja", name: "Ninja Headband", img: "/sprites/wardrobe_05_ninja_front.png", price: 1200, rarity: "Epic" },
    { id: "wizard", name: "Wizard Cone", img: "/sprites/wardrobe_06_wizard_front.png", price: 1500, rarity: "Epic" },
    { id: "crown", name: "Royal Crown", img: "/sprites/wardrobe_04_crown_front.png", price: 2500, rarity: "Legendary" }
  ];

  // Sound FX synthesizers
  function playPomodoroSound(type) {
    try {
      const ctx = new (window.AudioContext || window.webkitAudioContext)();
      const s = type || currentSoundFX || "lofi";

      if (s === "retro") {
        // 8-bit game victory fanfare (C5, E5, G5, C6)
        const notes = [523.25, 659.25, 783.99, 1046.50];
        notes.forEach((freq, idx) => {
          const osc = ctx.createOscillator();
          const gain = ctx.createGain();
          osc.type = "square";
          osc.frequency.setValueAtTime(freq, ctx.currentTime + idx * 0.08);
          gain.gain.setValueAtTime(0.18, ctx.currentTime + idx * 0.08);
          gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + idx * 0.08 + 0.14);
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.start(ctx.currentTime + idx * 0.08);
          osc.stop(ctx.currentTime + idx * 0.08 + 0.15);
        });
      } else if (s === "gong") {
        // Zen gong / Tibetan singing bowl (rich resonant low fundamental)
        const osc = ctx.createOscillator();
        const osc2 = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = "sine";
        osc2.type = "sine";
        osc.frequency.setValueAtTime(216, ctx.currentTime);
        osc2.frequency.setValueAtTime(432, ctx.currentTime);
        gain.gain.setValueAtTime(0.4, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 1.8);
        osc.connect(gain);
        osc2.connect(gain);
        gain.connect(ctx.destination);
        osc.start();
        osc2.start();
        osc.stop(ctx.currentTime + 1.8);
        osc2.stop(ctx.currentTime + 1.8);
      } else {
        // Lofi chime (Rhodes chord A5 + E6)
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = "sine";
        osc.frequency.setValueAtTime(880, ctx.currentTime);
        osc.frequency.setValueAtTime(1318.51, ctx.currentTime + 0.07);
        gain.gain.setValueAtTime(0.3, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.6);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start();
        osc.stop(ctx.currentTime + 0.6);
      }
    } catch(e) {}
  }

  function selectSoundFX(sfx) {
    currentSoundFX = sfx;
    document.querySelectorAll(".soundfx-pill").forEach(p => p.classList.remove("active"));
    const el = document.getElementById("sfx-" + sfx);
    if (el) el.classList.add("active");

    playPomodoroSound(sfx);
    fetch("/api/settings/sound", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ sound: sfx })
    });
    showToast("Bel suara: " + sfx.toUpperCase());
  }

  function showToast(msg) {
    const toast = document.getElementById("toast");
    document.getElementById("toast-text").innerText = msg;
    toast.classList.add("show");
    setTimeout(() => toast.classList.remove("show"), 2400);
  }

  function renderWardrobeGrid(activeHat, unlockedList, coins) {
    const container = document.getElementById("wardrobe-grid-container");
    container.innerHTML = "";

    const unlocked = new Set(unlockedList || ["none"]);

    HATS.forEach(hat => {
      const card = document.createElement("div");
      const isEquipped = (hat.id === activeHat);
      const isOwned = unlocked.has(hat.id) || (hat.price === 0);

      let cardClass = "hat-card";
      if (isEquipped) cardClass += " equipped";
      else if (isOwned) cardClass += " owned";
      else cardClass += " locked";
      card.className = cardClass;

      let btnHTML = "";
      if (isEquipped) {
        btnHTML = `<div class="hat-action-btn">EQUIPPED</div>`;
      } else if (isOwned) {
        btnHTML = `<div class="hat-action-btn">EQUIP</div>`;
      } else {
        btnHTML = `<div class="hat-action-btn">
          <svg style="width:12px;height:12px;fill:currentColor;" viewBox="0 0 24 24"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/></svg>
          BUY ${hat.price}
        </div>`;
      }

      card.onclick = () => handleHatClick(hat, isOwned, isEquipped, coins);

      card.innerHTML = `
        <div class="rarity-pill rarity-${hat.rarity}">${hat.rarity}</div>
        <img class="hat-img" src="${hat.img}" alt="${hat.name}">
        <div class="hat-name">${hat.name}</div>
        <div class="hat-price-row">
          ${hat.price === 0 ? "Free" : hat.price + " Coins"}
        </div>
        ${btnHTML}
      `;
      container.appendChild(card);
    });

    const activeObj = HATS.find(h => h.id === activeHat) || HATS[0];
    document.getElementById("wardrobe-active-duck-img").src = activeObj.img;
    document.getElementById("wardrobe-active-hat-name").innerText = activeObj.name;
    document.getElementById("header-avatar-img").src = activeObj.img;
  }

  function handleHatClick(hat, isOwned, isEquipped, coins) {
    if (isEquipped) {
      showToast("Already equipped on your Mac!");
      return;
    }
    if (isOwned) {
      equipHat(hat.id);
      return;
    }

    pendingHatPurchase = hat;
    document.getElementById("modal-hat-img").src = hat.img;
    document.getElementById("modal-hat-title").innerText = "Unlock " + hat.name;

    const modalDesc = document.getElementById("modal-hat-desc");
    const confirmBtn = document.getElementById("modal-confirm-btn");

    if (coins >= hat.price) {
      modalDesc.innerHTML = `Price: <strong>${hat.price} Focus Coins</strong>.<br>You have ${coins} coins. Unlock and equip now?`;
      confirmBtn.style.display = "block";
      confirmBtn.innerText = "Buy & Equip (" + hat.price + ")";
      confirmBtn.onclick = confirmPurchase;
    } else {
      const diff = hat.price - coins;
      modalDesc.innerHTML = `<span style="color:#FF334B; font-weight:800;">Not enough Focus Coins!</span><br>Price: ${hat.price} coins • You have: ${coins} coins.<br>Complete more Pomodoro sessions to earn <strong>${diff}</strong> more coins!`;
      confirmBtn.style.display = "block";
      confirmBtn.innerText = "Start Focus (+Coins)";
      confirmBtn.onclick = () => {
        closeModal();
        switchTab("home");
      };
    }

    document.getElementById("purchase-modal").classList.add("active");
  }

  function closeModal() {
    document.getElementById("purchase-modal").classList.remove("active");
    pendingHatPurchase = null;
  }

  async function confirmPurchase() {
    if (!pendingHatPurchase) return;
    const hat = pendingHatPurchase;
    closeModal();

    try {
      const res = await fetch("/api/shop/buy", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ hat: hat.id })
      });
      const data = await res.json();
      if (data.status === "purchased") {
        playPomodoroSound("retro");
        showToast("Unlocked & Equipped: " + hat.name + "!");
      } else {
        showToast(data.error || "Purchase failed");
      }
    } catch(e) {}
  }

  async function equipHat(hatId) {
    try {
      const res = await fetch("/api/wardrobe/hat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ hat: hatId })
      });
      const data = await res.json();
      if (data.status === "equipped") {
        playPomodoroSound("lofi");
        const hObj = HATS.find(h => h.id === hatId);
        showToast("Equipped: " + (hObj ? hObj.name : hatId));
      }
    } catch(e) {}
  }

  async function saveFocusTask() {
    const input = document.getElementById("focus-task-input");
    const val = input.value.trim();
    try {
      await fetch("/api/focus/task", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ task: val })
      });
      showToast(val ? "Target: " + val : "Cleared target");
    } catch(e) {}
  }

  async function careAction(action, label) {
    try {
      await fetch("/api/duck/action", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action: action })
      });
      playPomodoroSound("lofi");
      showToast(label);
    } catch(e) {}
  }

  async function musicAction(act) {
    try {
      await fetch("/api/music/" + act, { method: "POST" });
    } catch(e) {}
  }

  function selectPreset(minutes, mode) {
    selectedMinutes = minutes;
    selectedMode = mode;
    document.querySelectorAll(".preset-btn").forEach(b => b.classList.remove("active"));
    const btn = document.getElementById("preset-" + minutes);
    if (btn) btn.classList.add("active");

    if (mode === 'shortBreak' || mode === 'longBreak') {
      startPomodoro();
      switchTab('break');
    }
  }

  function updateUI(state) {
    currentState = state;
    if (!state || !state.pomodoro) return;

    const pomo = state.pomodoro;
    const duck = state.duck;
    const eco = state.economy || { coins: 350, completedSessions: 3, unlockedHats: ["none"] };
    const music = state.music || {};

    // 1. Coins (Earned ONLY through focus)
    const coinsVal = eco.coins || 0;
    document.getElementById("header-coins-text").innerText = coinsVal;
    document.getElementById("shop-balance-display").innerText = "Balance: " + coinsVal + " Focus Coins";
    const profileBal = document.getElementById("profile-balance-num");
    if (profileBal) profileBal.innerText = coinsVal.toLocaleString();

    // 1.5 Sync Profile Goals
    const focusMins = eco.totalFocusMinutes || 150;
    const focusHrs = (focusMins / 60).toFixed(1);
    const goalHrsEl = document.getElementById("goal-focus-hours");
    if (goalHrsEl) goalHrsEl.innerText = focusHrs;
    const goalBarEl = document.getElementById("goal-focus-bar");
    if (goalBarEl) goalBarEl.style.width = Math.min(100, Math.round((parseFloat(focusHrs) / 4.0) * 100)) + "%";

    const sessions = eco.completedSessions || 5;
    const goalTasksEl = document.getElementById("goal-tasks-count");
    if (goalTasksEl) goalTasksEl.innerText = sessions;
    const goalTasksBar = document.getElementById("goal-tasks-bar");
    if (goalTasksBar) goalTasksBar.style.width = Math.min(100, Math.round((sessions / 8.0) * 100)) + "%";

    if (state.user && !localStorage.getItem("lockin_user")) {
      currentUser.name = state.user.name || currentUser.name;
      currentUser.handle = state.user.handle || currentUser.handle;
      currentUser.avatar = state.user.avatar || currentUser.avatar;
      currentUser.tier = state.user.tier || currentUser.tier;
      applyUserProfileUI();
    }

    // 2. Spotify Mini Player
    const trackEl = document.getElementById("music-track-text");
    const artistEl = document.getElementById("music-artist-text");
    const iconEl = document.getElementById("music-playpause-icon");

    if (music.isPlaying && music.track) {
      trackEl.innerText = music.track;
      artistEl.innerText = music.artist || "Playing on Mac";
      iconEl.innerHTML = `<path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>`;
    } else if (music.track) {
      trackEl.innerText = music.track;
      artistEl.innerText = "Paused on Mac";
      iconEl.innerHTML = `<path d="M8 5v14l11-7z"/>`;
    } else {
      trackEl.innerText = "No Music Playing";
      artistEl.innerText = "Spotify / Apple Music";
      iconEl.innerHTML = `<path d="M8 5v14l11-7z"/>`;
    }

    // 3. Tamagotchi Mood & Stats
    if (duck.mood) {
      // document.getElementById("tamagotchi-title").innerText = duck.mood;
    }
    if (duck.moodDesc) {
      // document.getElementById("tamagotchi-desc").innerText = duck.moodDesc;
    }
    const energy = duck.energy !== undefined ? duck.energy : 100;
    const hunger = duck.hunger !== undefined ? duck.hunger : 100;
    const happy = duck.happiness !== undefined ? duck.happiness : 100;

    document.getElementById("stat-energy-text").innerText = energy + "%";
    document.getElementById("stat-energy-bar").style.width = energy + "%";
    document.getElementById("stat-hunger-text").innerText = hunger + "%";
    document.getElementById("stat-hunger-bar").style.width = hunger + "%";
    document.getElementById("stat-happy-text").innerText = happy + "%";
    document.getElementById("stat-happy-bar").style.width = happy + "%";

    // 4. Focus Task
    if (duck.focusTask !== undefined && document.activeElement !== document.getElementById("focus-task-input")) {
      document.getElementById("focus-task-input").value = duck.focusTask || "";
    }

    // 5. Sound FX selection
    if (state.soundFX && state.soundFX !== currentSoundFX) {
      currentSoundFX = state.soundFX;
      document.querySelectorAll(".soundfx-pill").forEach(p => p.classList.remove("active"));
      const p = document.getElementById("sfx-" + state.soundFX);
      if (p) p.classList.add("active");
    }

    // 6. Digits & Timer
    document.getElementById("timer-text").innerText = pomo.timeString;
    document.getElementById("break-digits").innerText = pomo.timeString;
    document.getElementById("timer-mode-label").innerText = pomo.modeTitle || "FOCUS MODE";

    // 7. Circular Progress
    const circle = document.getElementById("progress-circle");
    const progress = pomo.progress || 0;
    const offset = CIRCLE_CIRCUMFERENCE * (1 - Math.min(progress, 1));
    circle.style.strokeDashoffset = offset;

    // 8. Controls
    const idleControls = document.getElementById("pomo-idle-controls");
    const activeControls = document.getElementById("pomo-active-controls");
    const pauseBtnText = document.getElementById("pause-btn-text");

    if (pomo.isActive) {
      idleControls.style.display = "none";
      activeControls.style.display = "flex";
      pauseBtnText.innerText = pomo.isPaused ? "RESUME" : "PAUSE";
    } else {
      idleControls.style.display = "flex";
      activeControls.style.display = "none";
    }

    // 9. Hero Duck Mascot Sprite
    if (pomo.isActive && pomo.mode === "Focus") {
      document.getElementById("hero-duck-img").src = "/sprites/pomodoro_study_duck.png";
    } else if (pomo.isActive && (pomo.mode === "Short Break" || pomo.mode === "Long Break")) {
      document.getElementById("hero-duck-img").src = "/sprites/drinking_water_frame_0.png";
    } else {
      const activeHatObj = HATS.find(h => h.id === duck.currentHat) || HATS[0];
      document.getElementById("hero-duck-img").src = activeHatObj.img;
    }

    // 10. Wardrobe Grid
    renderWardrobeGrid(duck.currentHat, eco.unlockedHats, eco.coins || 0);
  }

  function switchTab(tabId) {
    document.querySelectorAll(".screen").forEach(s => s.classList.remove("active"));
    document.querySelectorAll(".tab-item").forEach(t => t.classList.remove("active"));

    const screen = document.getElementById("screen-" + tabId);
    const nav = document.getElementById("nav-" + tabId);
    if (screen) screen.classList.add("active");
    if (nav) nav.classList.add("active");
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  async function startPomodoro() {
    try {
      await fetch("/api/pomodoro/start", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ minutes: selectedMinutes, mode: selectedMode })
      });
      playPomodoroSound(currentSoundFX);
      showToast("Started " + selectedMinutes + "m Focus! Earn coins as you work.");
    } catch(e) {}
  }

  async function togglePausePomodoro() {
    if (!currentState || !currentState.pomodoro) return;
    const endpoint = currentState.pomodoro.isPaused ? "/api/pomodoro/resume" : "/api/pomodoro/pause";
    try {
      await fetch(endpoint, { method: "POST" });
      showToast(currentState.pomodoro.isPaused ? "Resumed" : "Paused");
    } catch(e) {}
  }

  async function stopPomodoro() {
    try {
      await fetch("/api/pomodoro/stop", { method: "POST" });
      showToast("Session stopped");
    } catch(e) {}
  }

  async function sendDuckAction(action, label) {
    try {
      await fetch("/api/duck/action", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action: action })
      });
      showToast(label || "Action executed");
    } catch(e) {}
  }

  // Pure hydration logger - NO CHEAP COINS
  function logWater() {
    waterTotal += 250;
    document.getElementById("water-btn-text").innerText = "Drink 250ml Water (Logged: " + waterTotal + "ml)";
    showToast("Logged 250ml! Stay hydrated & healthy.");
  }

  function initSSE() {
    const eventSource = new EventSource("/api/events");
    eventSource.onopen = () => {
      document.querySelector(".status-dot").style.background = "var(--success)";
    };
    eventSource.onmessage = (event) => {
      try {
        const state = JSON.parse(event.data);
        updateUI(state);
      } catch(e) {}
    };
    eventSource.onerror = () => {
      document.querySelector(".status-dot").style.background = "var(--warning)";
    };
  }

  fetch("/api/state")
    .then(r => r.json())
    .then(data => {
      updateUI(data);
      initSSE();
    })
    .catch(() => initSSE());
</script>
</body>
</html>
"""
    }
}
