# HyperType Landing Page Brief

**Project:** HyperType - A neon arcade typing game built with Godot  
**Last Updated:** May 8, 2026  
**Status:** Active project, ongoing development and polish

---

## 1. Product Understanding

### What is HyperType?

HyperType is a **fast-paced synthwave typing shooter** where players defeat enemies by typing words accurately and quickly. It combines:
- **Retro-futuristic visual design** (synthwave/cyberpunk aesthetic)
- **Arcade-style responsive gameplay** (immediate feedback and punchy UI)
- **Typing mechanics** (accuracy and speed matter equally)
- **Progression systems** (achievements, high scores, persistent stats, difficulty levels)

**Source:** [README.md](README.md), [project.godot](project.godot)

### Core Gameplay Loop

1. **Select difficulty** (Beginner/Challenging/Insane)
2. **Type incoming words** to destroy enemies descending from the top
3. **Build streaks** for bonus satisfaction (visual/audio feedback scales with streak)
4. **Survive as long as possible** while levels increase in speed and enemy density
5. **Defeat bosses** (spawned after 15 enemies per level)
6. **Game Over** when all 6 lives are lost
7. **Review stats** and high scores on results screen
8. **Unlock achievements** and chase progression goals

**Source:** [README.md](README.md), [main.gd](scripts/main.gd), [game_over.gd](scripts/game_over.gd)

### Target Audience

- **Typing enthusiasts** (speed typists, competitive gamers)
- **Arcade game fans** (retro/synthwave aesthetic lovers)
- **Casual gamers** (easy entry with "Beginner" difficulty)
- **Achievement hunters** (persistent progression, 25+ achievement system)
- **Web gamers** (playable in browser, no installation needed)

### Differentiators

1. **Typing-based combat system** – Words are weapons, accuracy is critical
2. **Synthwave visual identity** – Strong cyberpunk neon aesthetic
3. **Escalating difficulty** – Speed ramps with levels; enemies spawn faster
4. **Streak rewards system** – Visual/audio feedback intensifies at milestones (10, 25+ words)
5. **Persistent progression** – Account-based stats, achievements, leaderboard (via Talo)
6. **Guest mode** – Quick runs without account creation
7. **Boss encounters** – Special enemies with larger health pools
8. **Multiple enemy types** – Robot, ship, tank, small, standard enemies with unique visuals

**Source:** [README.md](README.md), [main.gd](scripts/main.gd), [Achievements.gd](scripts/Achievements.gd)

---

## 2. User-Facing Features Extracted

### A. Main Gameplay Features

| Feature | Details | Source |
|---------|---------|--------|
| **Three Difficulty Modes** | Beginner (40 px/s), Challenging (190 px/s), Insane (400 px/s) | [intro_screen.gd](scripts/intro_screen.gd) L72-78 |
| **Lives System** | 6 lives per run; lose 1 life on typing mistake that results in hit | [main.gd](scripts/main.gd) L7-8 |
| **Level Progression** | Level increases every 1000 points; enemy speed scales with level | [main.gd](scripts/main.gd) L53 |
| **Boss Encounters** | Appears after 15 enemies defeated per level | [main.gd](scripts/main.gd) L17 |
| **Enemy Variety** | 5 unique enemy types: Standard, Robot, Ship, Small, Tank | [main.gd](scripts/main.gd) L59-64 |
| **Streak System** | Tracks consecutive correct words; visual/audio milestones at 10, 25+ | [main.gd](scripts/main.gd) L19 |
| **Pause Menu** | Continue, Restart, Return to Main Menu actions | [pause_menu.gd](scripts/pause_menu.gd) L12-14 |

### B. Typing Mechanics

| Mechanic | Details | Source |
|----------|---------|--------|
| **Word Destruction** | Type letters sequentially to destroy word; all letters must be typed correctly | [letter.gd](scripts/letter.gd) |
| **Accuracy Tracking** | Monitors correct vs. wrong characters typed | [main.gd](scripts/main.gd) L20-22 |
| **Streak Breaks** | One typo breaks active streak | [main.gd](scripts/main.gd) L19 |
| **WPM Calculation** | Words Per Minute calculated on game over | [game_over.gd](scripts/game_over.gd) L71 |
| **Typing Timeout** | 0.3 second typing timeout for detecting end of typing session | [main.gd](scripts/main.gd) L29-30 |

**Source:** [main.gd](scripts/main.gd), [letter.gd](scripts/letter.gd)

### C. UI Screens & States

| Screen | Purpose | Key Elements | Source |
|--------|---------|--------------|--------|
| **Intro Screen** | Main menu & auth | Login/Register, Guest Play, Difficulty Select, Achievements Gallery | [intro_screen.gd](scripts/intro_screen.gd) |
| **Difficulty Select** | Choose game mode | Beginner, Challenging, Insane buttons; User info display | [intro_screen.gd](scripts/intro_screen.gd) L71-78 |
| **Gameplay Screen** | In-game HUD | Score, Level, Lives (6 hearts), Streak, Achievement notifications | [main.gd](scripts/main.gd) L37-50 |
| **Game Over Screen** | Results & stats | High Score, Level, Time Played, Correct Words, Accuracy, Longest Streak, WPM | [game_over.gd](scripts/game_over.gd) |
| **Pause Menu** | Mid-game options | Continue, Restart, Return to Main Menu (with pause state) | [pause_menu.gd](scripts/pause_menu.gd) |
| **Achievements Gallery** | Unlocked badges | Grid view of achievement cards with unlock status | [intro_screen.gd](scripts/intro_screen.gd) L365-430 |

**Source:** [intro_screen.gd](scripts/intro_screen.gd), [game_over.gd](scripts/game_over.gd), [main.gd](scripts/main.gd)

### D. Settings & Options

| Setting | Details | Source |
|---------|---------|--------|
| **Auth Modes** | Account Login, Account Registration, Guest Play | [intro_screen.gd](scripts/intro_screen.gd) L80-95 |
| **Difficulty Selection** | Three preset speeds (40, 190, 400 px/s) | [intro_screen.gd](scripts/intro_screen.gd) L72-78 |
| **God Mode** | Debug/experimental feature (triggerable via secret code) | [intro_screen.gd](scripts/intro_screen.gd) L300+, [GameSettings.gd](scripts/game_settings.gd) |
| **Pause/Resume** | Full pause support with game state preservation | [pause_menu.gd](scripts/pause_menu.gd) |
| **Logout/Session** | Account-based persistence via Talo | [intro_screen.gd](scripts/intro_screen.gd) L157-162 |

**Source:** [intro_screen.gd](scripts/intro_screen.gd), [GameSettings.gd](scripts/game_settings.gd)

### E. Stats & Results Screen Details

**Game Over Screen Shows:**
- High Score (or "GOD MODE" if special mode active)
- Current Level
- Time Played (in seconds)
- Correct Words
- Accuracy (as percentage with character counts)
- Longest Streak (this run)
- WPM (Words Per Minute)

**Persistent Stats (Tracked Across All Runs):**
- Total Playtime (seconds)
- Total Words Typed
- Total Perfect Words (typed without error)
- Longest Streak (all-time)
- Overall Accuracy (percentage)
- Bosses Defeated (all-time)
- Highest Level (all-time)
- Total Deaths
- Enemies Defeated (all-time)
- Perfect Levels Completed
- Comebacks Count

**Source:** [game_over.gd](scripts/game_over.gd) L1-100, [PlayerData.gd](scripts/PlayerData.gd) L6-26

### F. Audio & Visual Feedback

| Element | Details | Count | Source |
|---------|---------|-------|--------|
| **SFX Inventory** | Typing, correct letter, wrong letter, word complete, boss present, explosions, achievement unlock | 24 audio files | [audio_manager.gd](scripts/audio_manager.gd), `/assets/sounds/` |
| **Ambient Audio** | Background music, loops during gameplay | 1 | [AudioManager](scripts/audio_manager.gd) |
| **Achievement Audio** | Unlock sound + voice line per achievement | 25+ voice files | `/assets/sounds/achievements/` |
| **Streak Audio** | "Streak" sound at 10 words, "Mega Streak" sound at 25+ | 2 | [audio_manager.gd](scripts/audio_manager.gd) |
| **Particle Effects** | Enemy death particles, laser effects, step particles | Procedural | [enemy.gd](scripts/enemy.gd), [laser.gd](scripts/laser.gd) |
| **Animations** | Level up shake, stat reveals (game over), achievement card appear | Multiple | [main.gd](scripts/main.gd), [game_over.gd](scripts/game_over.gd) |

**Source:** [audio_manager.gd](scripts/audio_manager.gd), `/assets/sounds/`

### G. Achievements System

**Categories:**
1. **Accuracy & Perfection** (Persistent) – 5 achievements (Nailed It, Perfection Party, etc.)
2. **Typing Volume & Speed** (Persistent) – 3 achievements (Rapid-Fire Fingers, etc.)
3. **Endurance/Playtime** (Persistent) – 3 achievements (Keyboard Marathon, etc.)
4. **Boss Battles** (Persistent) – 3 achievements (Boss Basher to Obliterator)
5. **Enemy Defeat** (Persistent) – 4 achievements (First Blood to Massacre)
6. **Death & Resilience** (Persistent) – 3 achievements (Bounce Back to Phoenix)
7. **Level Progression** (Persistent) – Multiple tier achievements
8. **Run-Specific** (Session) – Achievements that reset each game

**Badge System:** Each achievement has:
- Title
- Description
- Badge image
- Voice line (unlock notification)
- Condition & required value

**Source:** [Achievements.gd](scripts/Achievements.gd)

### H. Accessibility & Controls

| Control | Input | Source |
|---------|-------|--------|
| **Navigate UI** | Tab / Arrow keys / Mouse | Standard Godot |
| **Select Menu Item** | Enter / Space / Left-click | FancyButton |
| **Pause Game** | ESC | [main.gd](scripts/main.gd) L378, [pause_menu.gd](scripts/pause_menu.gd) L53 |
| **Type Words** | Standard keyboard (any key) | [main.gd](scripts/main.gd) input handling |
| **Exit Game** | ESC (main menu) → Quit button | [intro_screen.gd](scripts/intro_screen.gd) |
| **Secret Debug** | Press "1" key (toggle debug HUD), "2" key (render shader) | [main.gd](scripts/main.gd) L362-369 |

**Feature Notes:**
- Mouse mode is hidden during gameplay, visible during menus
- Keyboard-focused interaction (typing-first design)
- Focus ring navigation for all UI buttons
- All buttons have hover/focus audio feedback

**Source:** [main.gd](scripts/main.gd), [pause_menu.gd](scripts/pause_menu.gd), [fancy_button.gd](scripts/fancy_button.gd)

### I. Save / Persistence Behavior

| Persistence Layer | Details | Source |
|-------------------|---------|--------|
| **Auth State** | Managed by Talo (external service); checked on app startup | [intro_screen.gd](scripts/intro_screen.gd) L120-127 |
| **Persistent Stats** | Saved per authenticated player via Talo; includes 15+ tracked stats | [PlayerData.gd](scripts/PlayerData.gd) L23-64 |
| **Achievements** | Saved as JSON per player; separate lists for persistent and run-based | [Achievements.gd](scripts/Achievements.gd) |
| **Guest Runs** | In-memory only; reset on menu return; no persistence | [intro_screen.gd](scripts/intro_screen.gd) L154 |
| **Session Data** | Run stats (current game) stored temporarily during gameplay | [main.gd](scripts/main.gd) |
| **High Score** | Compared against persistent record; updated if beaten | [game_over.gd](scripts/game_over.gd) L71-76 |

**Source:** [PlayerData.gd](scripts/PlayerData.gd), [Achievements.gd](scripts/Achievements.gd), [intro_screen.gd](scripts/intro_screen.gd)

### J. Experimental / Hidden Features

| Feature | Status | Purpose | Trigger | Source |
|---------|--------|---------|---------|--------|
| **God Mode** | Hidden/Experimental | Debug/fun mode; displays "GOD MODE" instead of score | Secret code (unreleased) | [GameSettings.gd](scripts/game_settings.gd), [intro_screen.gd](scripts/intro_screen.gd) L300+ |
| **Debug HUD** | Hidden/Debug | Shows persistent stats, run stats, unlocked achievements | Press "1" key | [main.gd](scripts/main.gd) L362-369 |
| **Distortion Shader** | Hidden/Debug | Renders chromatic aberration + distortion effect | Press "2" key | [main.gd](scripts/main.gd) L369, [distortion.gdshader](scripts/distortion.gdshader) |
| **GPU Warmup** | Internal | Pre-renders particles to reduce first-hit stuttering | Runs on game start | [main.gd](scripts/main.gd) L67-75 |

**Source:** [GameSettings.gd](scripts/game_settings.gd), [main.gd](scripts/main.gd)

---

## 3. Visual Identity Extraction

### A. Color Palette

**Primary Neon Colors:**

| Color | Hex | RGB | Usage | Source |
|-------|-----|-----|-------|--------|
| **Cyberpunk Magenta** | `#ff00b8` | `(255, 0, 184)` | Primary accent, button borders, high score highlight, UI elements | [index.shell.html](docs/index.shell.html) L16; [intro_screen.gd](scripts/intro_screen.gd) L354 |
| **Cyberpunk Cyan** | `#00d6ff` | `(0, 214, 255)` | Secondary accent, panel glows, background gradients | [index.shell.html](docs/index.shell.html) L17; [synthwave.gdshader](scripts/synthwave.gdshader) |
| **Deep Space Blue/Black** | `#04060d` / `#03040a` | `(4, 6, 13)` / `(3, 4, 10)` | Background, primary dark color | [index.shell.html](docs/index.shell.html) L13 |
| **Pure White** | `#f6f7fb` | `(246, 247, 251)` | Text, UI, primary foreground | [index.shell.html](docs/index.shell.html) L18 |
| **Muted Gray** | `#aab4d6` | `(170, 180, 214)` | Secondary text, disabled states | [index.shell.html](docs/index.shell.html) L19 |

**UI Panel Colors:**

| Element | Color | Source |
|---------|-------|--------|
| Panel Background | `rgba(3, 6, 18, 0.82)` | [index.shell.html](docs/index.shell.html) L14 |
| Panel Border | `rgba(255, 0, 186, 0.95)` (magenta) | [index.shell.html](docs/index.shell.html) L15 |
| Panel Glow | `rgba(0, 208, 255, 0.18)` (cyan) | [index.shell.html](docs/index.shell.html) L17 |
| Danger/Error BG | `rgba(98, 29, 45, 0.92)` | [index.shell.html](docs/index.shell.html) L20 |
| Danger Border | `rgba(255, 86, 146, 0.9)` (red-pink) | [index.shell.html](docs/index.shell.html) L21 |

**Dynamic/State Colors:**

| State | Color | Usage | Source |
|-------|-------|-------|--------|
| Button Hover | `Color(1.6, 1.6, 1.6)` (brightened white) | Button brightness on hover | [fancy_button.gd](scripts/fancy_button.gd) L49 |
| High Score Glow (Beat) | `Color(1.2, 0, 1.2, 1)` (bright magenta) | New high score pulsate effect | [game_over.gd](scripts/game_over.gd) L162 |
| Level Up Animation | `Color(0, 0.5, 1)` → `Color.WHITE` (cyan → white) | Level advance visual feedback | [main.gd](scripts/main.gd) L656-657 |
| Achievement Card (Locked) | `Color(0.48, 0.48, 0.55, 0.95)` (muted gray) | Desaturated achievement cards | [intro_screen.gd](scripts/intro_screen.gd) L395 |
| Achievement Border (Unlocked) | `Color(1.0, 0.0, 0.65, 1.0)` (magenta) | Unlocked achievement card border | [intro_screen.gd](scripts/intro_screen.gd) L354 |
| Achievement BG (Locked) | `Color(0.11, 0.02, 0.13, 0.92)` (dark purple) | Card background | [intro_screen.gd](scripts/intro_screen.gd) L349 |

**Shader Colors:**

| Shader | Color | Purpose | Source |
|--------|-------|---------|--------|
| Synthwave Grid | `background_color: vec4(0, 0, 0, 1)` / `grid_color: vec4(1, 0, 0.5, 1)` | Background grid layer (magenta lines) | [synthwave.gdshader](scripts/synthwave.gdshader) |
| Glow Effect | `vec3(1.0, 0.5, 0.0)` (orange) | Letter destruction glow | [glow_shader.gdshader](scripts/glow_shader.gdshader) |

**Source:** [index.shell.html](docs/index.shell.html), [intro_screen.gd](scripts/intro_screen.gd), [fancy_button.gd](scripts/fancy_button.gd), [main.gd](scripts/main.gd), [main_theme.tres](main_theme.tres)

### B. Typography & Fonts

| Font | Weight/Style | Usage | Details | Source |
|------|--------------|-------|---------|--------|
| **Departure Mono (Nerd Font)** | Regular | Default UI font, all text | Monospace, retro arcade feel | [main_theme.tres](main_theme.tres) L3 |
| **JetBrains Mono** | Italic Variable | Alternative available | Not currently active but included in assets | `/assets/fonts/JetBrainsMono-Italic-VariableFont_wght.ttf` |
| **System Font** | Default | Web fallback (index.shell.html) | "Segoe UI", Tahoma, Geneva, Verdana, sans-serif | [index.shell.html](docs/index.shell.html) L37 |

**Font Sizes & Scale:**

| Element | Size | Source |
|---------|------|--------|
| Default Theme Font Size | 24px | [main_theme.tres](main_theme.tres) L11 |
| Score Label (Dynamic) | 24px+ | [main.gd](scripts/main.gd) |
| Streak Label (Dynamic) | 32–64px (scales with streak) | [main.gd](scripts/main.gd) L871–900 |
| Achievement Unlock Text | 24px | [main_theme.tres](main_theme.tres) |
| Level Up Text | Scaled with tweens | [main.gd](scripts/main.gd) L656–700 |
| Game Over Stats | Animated to target values | [game_over.gd](scripts/game_over.gd) |

**Text Color Usage:**

| Element | Color | Source |
|---------|-------|--------|
| Primary Text | White `#f6f7fb` | [index.shell.html](docs/index.shell.html) L18 |
| Score (Highlighted) | Magenta `Color(1, 0, 1, 1)` | [main.gd](scripts/main.gd) L576 |
| Floating Score Popup | Magenta `Color.MAGENTA` | [main.gd](scripts/main.gd) L594 |
| Achievement Unlocked (Title) | Default white | [main.gd](scripts/main.gd) |
| Option Text | White `Color(1, 1, 1, 1)` | [main_theme.tres](main_theme.tres) L19 |
| Muted/Secondary | `#aab4d6` (gray) | [index.shell.html](docs/index.shell.html) L19 |

**Source:** [main_theme.tres](main_theme.tres), [index.shell.html](docs/index.shell.html), [main.gd](scripts/main.gd)

### C. Spacing & Sizing System

| Element | Dimension | Source |
|---------|-----------|--------|
| Window Resolution | 1600 × 900 | [project.godot](project.godot) L23-24 |
| Default Panel Size (UI) | 760 × 757 px | [intro_screen.gd](scripts/intro_screen.gd) L118 |
| Achievements Panel Size (UI) | 1160 × 757 px | [intro_screen.gd](scripts/intro_screen.gd) L119 |
| Button Border Width | 3px | [main_theme.tres](main_theme.tres) (all StyleBox) |
| Panel Border Width | 2px | [intro_screen.gd](scripts/intro_screen.gd) L353 |
| Achievement Card Min Size | 250 × 240 px | [intro_screen.gd](scripts/intro_screen.gd) L403 |
| Enemy Letter Spacing | 44px | [enemy.gd](scripts/enemy.gd) L52 |
| Letter Line Thickness | 3px | [enemy.gd](scripts/enemy.gd) L63 |
| Shell Panel (Web) | min(92vw, 880px) | [index.shell.html](docs/index.shell.html) L83 |
| Shell Padding (Web) | 24px | [index.shell.html](docs/index.shell.html) L83, 73 |

**Source:** [project.godot](project.godot), [main_theme.tres](main_theme.tres), [intro_screen.gd](scripts/intro_screen.gd)

### D. Border Radius & Visual Effects

| Element | Border Radius | Source |
|---------|---------------|--------|
| Achievement Card | 12px (all corners) | [intro_screen.gd](scripts/intro_screen.gd) L355–358 |
| Shell Panel (Web) | 28px | [index.shell.html](docs/index.shell.html) L84 |
| Button Styling | Default (from theme) | [main_theme.tres](main_theme.tres) |

**Shadows & Glows:**

| Effect | Specification | Source |
|--------|---------------|--------|
| Button Shadow | 3px shadow, offset (3, 3), `Color(0, 0, 0, 0.259)` | [main_theme.tres](main_theme.tres) |
| Canvas Shadow | `0 18px 60px rgba(0, 0, 0, 0.45)` | [index.shell.html](docs/index.shell.html) L22 |
| Panel Glow | `0 0 60px rgba(0, 208, 255, 0.18)` (cyan glow) | [index.shell.html](docs/index.shell.html) L87 |
| Panel Inset Line | `0 0 0 1px rgba(255, 255, 255, 0.04) inset` | [index.shell.html](docs/index.shell.html) L86 |
| Panel Outer Shadow | `0 24px 80px rgba(0, 0, 0, 0.45)` | [index.shell.html](docs/index.shell.html) L87 |
| High Score Pulsate | Glowing outline + brightness loop | [game_over.gd](scripts/game_over.gd) L163–164 |

**Source:** [main_theme.tres](main_theme.tres), [index.shell.html](docs/index.shell.html), [game_over.gd](scripts/game_over.gd)

### E. Gradients & Backgrounds

| Background | Layers | Source |
|-----------|--------|--------|
| **Body (Web)** | 1. Radial gradient (cyan, top) + 2. Radial gradient (magenta, bottom) + 3. Linear gradient (top-to-bottom) | [index.shell.html](docs/index.shell.html) L31–35 |
| **Shell Overlay (Web)** | 1. Linear gradient (dark overlay) + 2. Radial gradient (cyan, top) + 3. Radial gradient (magenta, bottom) + blur filter | [index.shell.html](docs/index.shell.html) L73–77 |
| **Theme Color (Meta)** | Dark blue `#05070d` | [index.shell.html](docs/index.shell.html) L5 |

**Backdrop Effects:**
- Blur: `backdrop-filter: blur(4px)` | [index.shell.html](docs/index.shell.html) L78

**Source:** [index.shell.html](docs/index.shell.html)

### F. Button Styles

**Default Button Style:**

| Property | Value | Source |
|----------|-------|--------|
| Background Color | `Color(0.314067, 0.0805, 0.35, 1)` (dark purple) | [main_theme.tres](main_theme.tres) L27 |
| Border Color | `Color(3, 0, 1, 1)` (bright magenta) | [main_theme.tres](main_theme.tres) L28 |
| Border Width | 3px all sides | [main_theme.tres](main_theme.tres) L24–27 |
| Shadow | 3px offset (3, 3), `Color(0, 0, 0, 0.259)` | [main_theme.tres](main_theme.tres) L29–30 |
| Text Color | White (default) | [main_theme.tres](main_theme.tres) |

**Button Hover State:**

| Property | Value | Source |
|----------|-------|--------|
| Background Color | `Color(0.264141, 0.0618426, 0.295252, 1)` (darker purple) | [main_theme.tres](main_theme.tres) L17 |
| Border Color | `Color(1.83137, 0, 0.576471, 1)` (bright magenta) | [main_theme.tres](main_theme.tres) L18 |
| Scale Tween | 1.1x scale + 0.1 rad rotation | [fancy_button.gd](scripts/fancy_button.gd) L49–54 |
| Modulate | `Color(1.6, 1.6, 1.6)` (brightened) | [fancy_button.gd](scripts/fancy_button.gd) L49 |
| Audio Feedback | UI hover sound, pitch-varied | [fancy_button.gd](scripts/fancy_button.gd) L56 |

**Button Focus State:**
- Same as hover (reuses the hover effect)

**Source:** [main_theme.tres](main_theme.tres), [fancy_button.gd](scripts/fancy_button.gd)

### G. Card / Panel Styles

**Achievement Card (Locked):**

| Property | Value | Source |
|----------|-------|--------|
| Background | `Color(0.11, 0.02, 0.13, 0.92)` (dark purple, semi-transparent) | [intro_screen.gd](scripts/intro_screen.gd) L349 |
| Border | 2px solid `Color(1.0, 0.0, 0.65, 1.0)` (magenta) | [intro_screen.gd](scripts/intro_screen.gd) L354 |
| Border Radius | 12px all corners | [intro_screen.gd](scripts/intro_screen.gd) L355–358 |
| Content Margin | 16px all sides | [intro_screen.gd](scripts/intro_screen.gd) L359–362 |
| Modulate (Desaturated) | `Color(0.48, 0.48, 0.55, 0.95)` | [intro_screen.gd](scripts/intro_screen.gd) L395 |

**Achievement Card (Unlocked):**

| Property | Value | Source |
|----------|-------|--------|
| Modulate | `Color.WHITE` (full brightness) | [intro_screen.gd](scripts/intro_screen.gd) L395 |
| Other properties | Same as locked | [intro_screen.gd](scripts/intro_screen.gd) |

**Game Over Panel:**

| Property | Value | Source |
|----------|-------|--------|
| Background | Dark with subtle styling | [game_over.gd](scripts/game_over.gd) |
| Animations | Stats animate in sequentially with tweens | [game_over.gd](scripts/game_over.gd) L142–153 |
| Shake Effect | Stats shake on reveal (visual feedback) | [game_over.gd](scripts/game_over.gd) L177–200 |

**Source:** [intro_screen.gd](scripts/intro_screen.gd), [main_theme.tres](main_theme.tres), [game_over.gd](scripts/game_over.gd)

### H. Animation Style & Timing

| Animation Type | Timing | Details | Source |
|---|---|---|---|
| **Button Hover** | 0.2s | Scale 1.0 → 1.1, rotation 0 → 0.1 rad (TRANS_BACK + TRANS_BOUNCE) | [fancy_button.gd](scripts/fancy_button.gd) L49–54 |
| **Button Unhover** | 0.1s | Scale 1.1 → 1.0 (TRANS_BACK) | [fancy_button.gd](scripts/fancy_button.gd) L61–63 |
| **High Score Pulsate** | 0.5s loop | Modulate brightness 1.2 ↔ 0.8 (TRANS_SINE, infinite loop) | [game_over.gd](scripts/game_over.gd) L162–175 |
| **Stat Reveal (Game Over)** | 0.2–0.4s per stat | Tweens to target value + shake on finish (TRANS_LINEAR) | [game_over.gd](scripts/game_over.gd) L177–201 |
| **Streak Flash** | 0.05–0.2s | Color magenta flash + scale pulse when typing correct letter | [letter.gd](scripts/letter.gd) L71–110 |
| **Level Up Animation** | 0.5–1.0s | Scale bounce, color fade, shake effect on level label | [main.gd](scripts/main.gd) L653–710 |
| **Achievement Unlock** | Seq. 0.3–1.0s | Appear animation + audio + voice line | [main.gd](scripts/main.gd) L135–164 |
| **Enemy Death** | 0.2–0.4s | Fade out + particle emission | [enemy.gd](scripts/enemy.gd) L130–144 |
| **Camera Shake** | 0.6s | 25px offset, multiple small shakes (TRANS_SINE) | [main.gd](scripts/main.gd) L337–357 |

**Easing Functions Used:**
- `TRANS_BACK` – Overshoot/bouncy effect (buttons)
- `TRANS_BOUNCE` – Elastic bounce (buttons, level up)
- `TRANS_SINE` – Smooth sine curve (camera shake, pulsate)
- `TRANS_LINEAR` – Constant speed (stat reveals)

**Source:** [fancy_button.gd](scripts/fancy_button.gd), [game_over.gd](scripts/game_over.gd), [main.gd](scripts/main.gd), [letter.gd](scripts/letter.gd)

### I. Shaders & Post-Processing Effects

| Shader | Purpose | Key Parameters | Visual Effect | Source |
|--------|---------|-----------------|---------------|--------|
| **Synthwave Grid** | Background scenery | `brightness`, `fov`, `line_count`, `grid_color` (magenta), `anchor` | Retro perspective grid lines, movement on Y-axis | [synthwave.gdshader](scripts/synthwave.gdshader) |
| **Distortion** | Event effect (impact) | `strength`, `radius`, `aberration`, `center`, `feather` | Chromatic aberration + radial lens distortion on impact | [distortion.gdshader](scripts/distortion.gdshader) |
| **Screen Effect** | Ambient post-process | `curvature`, `vignette_multiplier`, `blur_amount` | CRT-like curved screen + vignette + slight blur | [screen_effect.gdshader](scripts/screen_effect.gdshader) |
| **Chromatic Aberration (CRO_ABR)** | Color separation | `amount` | RGB channel separation for arcade feel | [cro_abr_shader.gdshader](scripts/cro_abr_shader.gdshader) |
| **Glow** | Entity emission | Texture alpha → glow intensity | Orange glow on letters destroyed | [glow_shader.gdshader](scripts/glow_shader.gdshader) |
| **Water Shader** | Not actively used (asset available) | Wave noise, mix value, screen texture | Water wave distortion effect | [water_shader.gdshader](scenes/water_shader.gdshader) |

**Source:** [synthwave.gdshader](scripts/synthwave.gdshader), [distortion.gdshader](scripts/distortion.gdshader), [screen_effect.gdshader](scripts/screen_effect.gdshader), [cro_abr_shader.gdshader](scripts/cro_abr_shader.gdshader)

### J. Assets & Icons

**Sprites & Images:**

| Asset | Type | Usage | Source Path |
|-------|------|-------|-------------|
| Enemy Sprites (6 types) | PNG sprite sheets | Mech, robot, ship, tank, small, standard | `/assets/sprites/{bipedal-unit.png, robot.png, ship-unit.png, tank-unit.png, ...}` |
| Badge/Achievement Icons | PNG | Achievement unlock badges (25+) | `/assets/sprites/badges/` |
| Particle Effects | PNG sprite sheets | Explosions, sparks, steps | `/assets/sprites/{particles_sprite.png, spark_particle.png, ...}` |
| Environment | PNG tiles & backgrounds | Platform tiles, sci-fi interior | `/assets/sprites/{tile-set-sci-fi-interior-platform.png, ...}` |
| Effects (Light) | WebP/PNG | Light overlays, glows | `/assets/sprites/{light.webp, light_02.png, ...}` |
| Game Logo/Cover | JPG | Promo image | `/hypertype.jpg` |

**Fonts:**

| Font | Type | File | Usage |
|------|------|------|-------|
| Departure Mono Nerd Font | OTF | `/assets/fonts/DepartureMonoNerdFont-Regular.otf` | Primary UI font (active) |
| JetBrains Mono Variable | TTF | `/assets/fonts/JetBrainsMono-Italic-VariableFont_wght.ttf` | Available alternative |
| Departure Mono Proportional | OTF | `/assets/fonts/DepartureMonoNerdFontPropo-Regular.otf` | Alternative variant |
| Departure Mono Mono | OTF | `/assets/fonts/DepartureMonoNerdFontMono-Regular.otf` | Alternative variant |

**Other Media:**

| Asset | Type | Path |
|-------|------|------|
| Favicon | PNG | `/docs/index.icon.png` |
| Apple Touch Icon | PNG | `/docs/index.apple-touch-icon.png` |
| Logo/Branding | SVG | `/docs/vollrath_logo.svg` |

**Source:** `/assets/sprites/`, `/assets/fonts/`, `/docs/`

---

## 4. Copywriting Material Extracted

### A. App Name & Branding

| Element | Text | Source |
|---------|------|--------|
| **Primary Name** | HyperType | [README.md](README.md), [project.godot](project.godot) |
| **Tagline (Short)** | "A neon arcade typing game built with Godot" | [README.md](README.md) |
| **Tagline (Medium)** | "A fast-paced synthwave typing shooter where your words are your weapons" | [README.md](README.md) |
| **Tagline (Long)** | "HyperType is a fast-paced synthwave typing shooter where your words are your weapons. Enemies rush in from the skyline, every correct keypress fires back, and the pressure ramps up as the level speed climbs." | [README.md](README.md) |

### B. Feature Descriptions

| Feature | Description | Source |
|---------|-------------|--------|
| **Core Gameplay** | "The core loop is simple: 1) Pick a difficulty. 2) Type incoming words correctly to destroy enemies. 3) Build streaks, survive mistakes, and push your score higher. 4) Defeat bosses, unlock achievements, and chase better runs." | [README.md](README.md) |
| **Design Philosophy** | "HyperType is designed to feel immediate and readable, with strong visual feedback, punchy UI, and a classic cyber-arcade mood." | [README.md](README.md) |
| **Difficulty Modes** | "Three difficulty modes: Beginner, Challenging, and Insane" | [README.md](README.md) |
| **Auth Features** | "Guest play for quick runs" | [README.md](README.md) |
| **Account Features** | "Account login and registration flow" | [README.md](README.md) |
| **Progression** | "Achievement unlocks and badge gallery" | [README.md](README.md) |
| **Tracking** | "High score and run stat tracking" | [README.md](README.md) |
| **Boss Encounters** | "Boss encounters and escalating enemy pressure" | [README.md](README.md) |
| **Performance** | "GPU / particle warm-up flow to reduce first-effect hitching" | [README.md](README.md) |
| **Pause** | "Pause menu with continue, restart, and return-to-menu actions" | [README.md](README.md) |

### C. Achievement Titles & Descriptions (Sample)

| Achievement | Title | Description |
|-------------|-------|-------------|
| Accuracy | "Nailed It!" | "Complete a level without a single mistake" |
| Accuracy | "Perfection Party" | "Finish 5 levels perfectly" |
| Accuracy | "Typo? Never!" | "Maintain 99% accuracy for 5 levels" |
| Speed | "Rapid-Fire Fingers" | "Type 1,000 words in total" |
| Endurance | "Keyboard Marathon" | "Play for 1 hour" |
| Boss | "Boss Basher" | "Defeat 25 bosses" |
| Combat | "First Blood" | "Defeat 1 enemy" |
| Resilience | "Bounce Back" | "Die 10 times" |
| Progression | "Level Up Legend" | "Reach level 10" |

**Full achievement list:** [Achievements.gd](scripts/Achievements.gd) lines 7–200+

### D. UI Button Labels

| Screen | Button Text | Action |
|--------|------------|--------|
| Main Menu | "Login" | Go to login/register state |
| Main Menu | "Play as Guest" | Start difficulty select without account |
| Main Menu | "Quit" | Exit application |
| Auth | "Login" / "Create Account" | Submit auth form |
| Auth | "(Create account)" / "(Back to login)" | Toggle between login/register modes |
| Difficulty | "Beginner" | Start game at easy speed (40 px/s) |
| Difficulty | "Challenging" | Start game at normal speed (190 px/s) |
| Difficulty | "Insane" | Start game at hard speed (400 px/s) |
| Difficulty | "View Achievements" | Open achievements gallery |
| Difficulty | "Logout" | Log out current user |
| Difficulty | "Quit" | Exit application |
| Achievements | "Back" | Return to difficulty select |
| Game Over | "Restart" | Start new game at same difficulty |
| Game Over | "Back to Main Menu" | Return to difficulty select |
| Pause Menu | "Continue" | Resume game |
| Pause Menu | "Restart" | Start new game |
| Pause Menu | "Return to Main Menu" | Go to main menu |

**Source:** [intro_screen.gd](scripts/intro_screen.gd), [game_over.gd](scripts/game_over.gd), [pause_menu.gd](scripts/pause_menu.gd)

### E. UI Labels & Displays

| Label | Text Format | Context | Source |
|-------|-------------|---------|--------|
| Score | "High Score: {number}" | Game over screen (or "GOD MODE" if special mode) | [game_over.gd](scripts/game_over.gd) L28–34 |
| Level | "Level: {number}" | Gameplay HUD & game over | [main.gd](scripts/main.gd), [game_over.gd](scripts/game_over.gd) |
| Time | "{seconds} seconds" | Game over stats | [game_over.gd](scripts/game_over.gd) L53 |
| Words | "{count}" | Game over stats (Correct Words) | [game_over.gd](scripts/game_over.gd) L58 |
| Accuracy | "{correct} / {total} ({percentage}%)" | Game over stats | [game_over.gd](scripts/game_over.gd) L66–69 |
| Streak | "{count} words" | Game over stats | [game_over.gd](scripts/game_over.gd) L73 |
| WPM | "{number}" | Game over stats (Words Per Minute) | [game_over.gd](scripts/game_over.gd) L71 |
| Achievement | "Achievement Unlocked: {title}" | Floating notification during gameplay | [main.gd](scripts/main.gd) L127 |
| User Info | "Playing as: {username}" | Difficulty select (logged in) | [intro_screen.gd](scripts/intro_screen.gd) L138 |
| User Info | "Playing as Guest" | Difficulty select (guest mode) | [intro_screen.gd](scripts/intro_screen.gd) L141 |
| Achievements | "Unlocked {count} / {total}" | Achievements gallery summary | [intro_screen.gd](scripts/intro_screen.gd) L428 |

**Source:** [game_over.gd](scripts/game_over.gd), [main.gd](scripts/main.gd), [intro_screen.gd](scripts/intro_screen.gd)

### F. Empty States & Messages

| State | Message | Source |
|-------|---------|--------|
| No Achievements | "None yet!" | [main.gd](scripts/main.gd) L89 |
| Auth Error (General) | Handled by Talo response | [intro_screen.gd](scripts/intro_screen.gd) auth handling |
| Game Preparation | "Preparing shaders and particles..." | [intro_screen.gd](scripts/intro_screen.gd) L308 |

### G. Results / Success Messages

| Message | Context | Source |
|---------|---------|--------|
| "New High Score" | Visual/audio celebration | [game_over.gd](scripts/game_over.gd) L75 |
| Achievement Unlock Notification | Audio + badge display | [main.gd](scripts/main.gd) L127–164 |
| Level Up Notification | Visual animation + audio | [main.gd](scripts/main.gd) L620–710 |
| Streak Milestone (10+) | "STREAK x {count}" with special effects | [main.gd](scripts/main.gd) L881–900 |
| Streak Milestone (25+) | "STREAK x {count}" with rainbow effect | [main.gd](scripts/main.gd) L896–900 |

**Source:** [game_over.gd](scripts/game_over.gd), [main.gd](scripts/main.gd)

### H. Settings Labels

| Setting | Label Text |
|---------|------------|
| Difficulty | Not explicitly labeled (buttons are self-descriptive) |
| Guest/Auth Mode | "Playing as Guest" vs "Playing as: {name}" |
| Theme/Dark Mode | Not implemented (dark theme is hardcoded) |

---

## 5. Suggested Landing Page Structure

### Recommended Landing Page Outline

```
1. Navigation / Header
   - HyperType branding
   - Quick nav (Play, Features, About, External links)
   - Call-to-action: "Play Now" button (hero CTA)

2. Hero Section
   - Large visually striking image/video of gameplay
   - Headline: "HyperType"
   - Subheadline: "A fast-paced synthwave typing shooter where your words are your weapons"
   - Primary CTA: "Play Game"
   - Secondary CTA: "Learn More"

3. Quick Gameplay Explainer
   - 3–4 sentence description of the core loop
   - Highlight: "Type words. Defeat enemies. Build streaks. Unlock achievements."
   - Visuals: Animated GIF or short video of typing → enemy destruction

4. Feature Highlight Section
   - 4–6 key feature cards with icons/short text:
     a. "Three Difficulty Levels" (Beginner, Challenging, Insane)
     b. "Progression & Achievements" (25+ unlockable badges)
     c. "Real-time Typing Feedback" (accuracy, speed, streaks)
     d. "Retro Synthwave Aesthetic" (neon colors, arcade vibes)
     e. "Guest Play + Accounts" (quick runs or persistent progress)
     f. "Boss Encounters" (special challenges every 15 enemies)

5. Gameplay Mechanics / How to Play
   - Step-by-step visual walkthrough
   - Screenshot carousel or annotated gameplay image
   - Stats tracked: Score, Level, Streaks, Accuracy, WPM

6. Achievement System Showcase
   - Grid of achievement badges (3–4 visible)
   - Headline: "Unlock Badges & Chase Milestones"
   - Categories: Accuracy, Speed, Endurance, Boss Battles, etc.
   - CTA: "View All Achievements" (if space allows)

7. Stats & Progression
   - "Persistent Progress" or "Track Your Growth"
   - Showcase metrics: Total Words Typed, Playtime, High Scores, Accuracy
   - Highlight: "Guest play available for quick runs"

8. Visual Identity / Aesthetic Showcase
   - Large image of key UI screen (intro menu, gameplay, game over)
   - Description of synthwave design philosophy
   - Highlight neon color palette (magenta + cyan)

9. Technical Details / Portfolio
   - Built with: Godot 4, GDScript
   - Player Authentication: Talo (if relevant to landing page audience)
   - Web-based: "Play instantly in your browser"

10. Footer
    - Links: GitHub (if public), Privacy/Terms, Credits
    - Social links (if applicable)
    - Copyright & legal
    - Secondary CTA: "Play Now" (repeat)
```

---

### Detailed Section Recommendations

#### **1. Hero Section**

**Purpose:** Immediately communicate what HyperType is and grab attention  
**Headline:** "HyperType: Type to Survive"  
**Alternative Headline:** "Your Words Are Your Weapons"  
**Subheadline:** "A fast-paced synthwave typing shooter. Type words to destroy enemies, build streaks, and chase high scores."  
**Body Copy:** "Experience arcade action like never before. Every keystroke counts. Compete solo or unlock achievements across multiple difficulty levels."  

**Visual Content Needed:**
- Hero image: Gameplay screenshot showing vibrant neon UI, enemy spawns, score visible
- Alternative: Looping gameplay GIF (2–3 seconds) showing typing → enemy destruction feedback
- Color scheme: Use brand magenta + cyan on dark background

**Call-to-Action:**
- Primary: "Play Now" (bright magenta button)
- Secondary: "Watch Gameplay" (outlinebutton, optional video)

**Source Material:**
- Tagline: [README.md](README.md)
- Colors: [index.shell.html](docs/index.shell.html), [main_theme.tres](main_theme.tres)
- Visual identity: Game screenshots

---

#### **2. Features Section**

**Purpose:** Outline key differentiators  
**Headline:** "Why HyperType?"  

**Feature Cards (Grid, 2–3 columns):**

| Card | Icon | Headline | Body Copy |
|------|------|----------|-----------|
| 1 | ⌨️ | "Typing Meets Action" | "Type words to destroy enemies. Accuracy and speed both matter. Every mistake costs a life." |
| 2 | 🎯 | "Three Difficulty Modes" | "Beginner, Challenging, Insane. Choose your pace and ramp up as you master the game." |
| 3 | 🏆 | "Achievements & Progression" | "25+ achievements to unlock. Track your stats across multiple runs. Beat your high score." |
| 4 | 🎨 | "Synthwave Aesthetic" | "Neon magenta and cyan on dark backgrounds. Arcade vibes with modern polish." |
| 5 | 👤 | "Play Any Way" | "Guest play for quick runs, or create an account for persistent progress and leaderboards." |
| 6 | 👹 | "Boss Encounters" | "Face special enemies with unique challenges. Escalating difficulty keeps you on your toes." |

**Visual Content Needed:**
- 6 small icons (custom or icon set)
- Screenshots for each feature highlight (optional)

**Source Material:**
- Feature list: [README.md](README.md)
- Details: [main.gd](scripts/main.gd), [Achievements.gd](scripts/Achievements.gd)

---

#### **3. Gameplay Explanation Section**

**Purpose:** Clearly explain how to play  
**Headline:** "The Core Loop"  
**Subheadline:** "Simple to learn, hard to master"  

**Body Copy:**
```
1. Pick your difficulty: Beginner (casual), Challenging (standard), or Insane (intense).
2. Words appear at the top of the screen with enemies behind them.
3. Type each word correctly to destroy the enemy. One typo and you lose a life.
4. Build streaks for bonus visual/audio feedback and score multipliers.
5. Survive levels and defeat bosses as the difficulty ramps up.
6. Chase high scores, unlock achievements, and master all difficulty levels.
```

**Visual Content Needed:**
- Annotated gameplay screenshot with callouts for key UI elements:
  - Score display
  - Lives (heart icons)
  - Current level
  - Enemy word to type
  - Streak counter
- Alternative: Series of 4–5 smaller screenshots showing gameplay progression

**Screenshots to Capture:**
- Game start (intro screen with difficulty buttons): [intro_screen.tscn](scenes/intro_screen.tscn)
- Gameplay in progress (visible: score, level, lives, enemy word): [main.tscn](scenes/main.tscn)
- High streak moment (25+ with special effects): [main.gd](scripts/main.gd) L896+
- Game Over screen (stats reveal): [game_over.tscn](scenes/game_over.tscn)

**Source Material:**
- Core loop description: [README.md](README.md)
- Gameplay mechanics: [main.gd](scripts/main.gd), [letter.gd](scripts/letter.gd)

---

#### **4. Stats & Progression Section**

**Purpose:** Highlight tracking and long-term engagement  
**Headline:** "Track Your Progress"  
**Subheadline:** "Every key you press counts"  

**Metrics Displayed:**
- Words typed (cumulative)
- Playtime (hours)
- Longest streak
- Overall accuracy
- Bosses defeated
- Highest level reached
- Perfect levels (no mistakes)

**Body Copy:**
```
Your stats are tracked across every run. Whether you play as a guest or create an account, 
HyperType remembers your achievements. Set goals, beat your personal bests, and 
climb the difficulty ladder.
```

**Visual Content Needed:**
- Screenshot of Game Over screen showing all stats animated
- Optional: Small charts or progress bars for key metrics
- Optional: Comparison of stats across difficulty levels

**Screenshots to Capture:**
- Full Game Over screen: [game_over.tscn](scenes/game_over.tscn)

**Source Material:**
- Stats tracked: [PlayerData.gd](scripts/PlayerData.gd) L6–26, [game_over.gd](scripts/game_over.gd)

---

#### **5. Achievements Section**

**Purpose:** Showcase long-term engagement hooks  
**Headline:** "Unlock Badges"  
**Subheadline:** "25+ achievements to chase"  

**Achievement Categories to Highlight:**
- **Accuracy:** "Nailed It!" (perfect level), "Typo? Never!" (99% accuracy)
- **Speed:** "Rapid-Fire Fingers" (1000 words), "Wordsmith Extraordinaire" (50,000 words)
- **Endurance:** "Keyboard Marathon" (1 hour), "Keyboard Immortal" (10 hours)
- **Combat:** "Boss Basher" (25 bosses), "Enemy Annihilator" (100 enemies)

**Body Copy:**
```
Achievements reward your progress across multiple dimensions: 
accuracy, typing volume, endurance, boss battles, and more. 
Earn badges and compete with friends.
```

**Visual Content Needed:**
- Badge grid showing 8–12 achievement icons
- Optional: Full achievement gallery screenshot

**Screenshots/Assets to Use:**
- Achievement badges from `/assets/sprites/badges/`
- Achievements gallery from [achievements_container](scenes/intro_screen.tscn)

**Source Material:**
- Achievement list: [Achievements.gd](scripts/Achievements.gd) L1–200+

---

#### **6. Difficulty/Game Modes Section**

**Purpose:** Clarify difficulty scaling  
**Headline:** "Choose Your Challenge"  

**Difficulty Cards:**

| Level | Name | Speed | Recommended | Vibe |
|-------|------|-------|-------------|------|
| 1 | Beginner | 40 px/s | New players | Relaxed, learn the ropes |
| 2 | Challenging | 190 px/s | Most players | Balanced, engaging |
| 3 | Insane | 400 px/s | Experts | Intense, hardcore |

**Body Copy:**
```
Whether you're picking up a typing game for the first time or you're a 
competitive speedster, HyperType has a difficulty for you. 
Each level offers unique challenges and leaderboard tracking.
```

**Visual Content Needed:**
- Screenshot of difficulty select screen: [intro_screen.tscn](scenes/intro_screen.tscn)

**Source Material:**
- Difficulty definitions: [intro_screen.gd](scripts/intro_screen.gd) L72–78

---

#### **7. Visual/Aesthetic Section**

**Purpose:** Showcase the unique synthwave look  
**Headline:** "Neon Arcade Vibes"  
**Subheadline:** "Retro-futuristic design meets modern polish"  

**Body Copy:**
```
HyperType embraces synthwave and cyberpunk aesthetics. 
Neon magenta and cyan colors pop against deep dark backgrounds. 
Responsive UI, satisfying animations, and punchy audio feedback 
create an immediate, rewarding experience.
```

**Visual Content Needed:**
- Full screenshot of intro menu (magenta buttons, dark background, cyan accents)
- Gameplay screenshot highlighting neon colors
- Optional: Short video showcasing UI animations

**Color References:**
- Primary: Magenta `#ff00b8`
- Secondary: Cyan `#00d6ff`
- Background: Dark `#04060d`
- Text: White `#f6f7fb`

**Screenshots to Capture:**
- Intro/menu screen: [intro_screen.tscn](scenes/intro_screen.tscn)
- Gameplay: [main.tscn](scenes/main.tscn)
- Game over: [game_over.tscn](scenes/game_over.tscn)

**Source Material:**
- Design philosophy: [README.md](README.md)
- Colors: [index.shell.html](docs/index.shell.html), [main_theme.tres](main_theme.tres)
- Shaders: [synthwave.gdshader](scripts/synthwave.gdshader)

---

#### **8. Technical / Portfolio Section (Optional)**

**Purpose:** Highlight technical credentials  
**Headline:** "Built With Modern Tools"  

**Body Copy:**
```
HyperType is built with Godot 4 and GDScript, demonstrating 
modern game engine expertise and arcade game design principles. 
Play instantly in your browser—no installation needed.
```

**Key Points:**
- Engine: Godot 4
- Language: GDScript
- Platform: Web (HTML5/WebGL)
- Auth: Talo (player progression service)
- Performance: GPU particle warmup, optimized rendering

**Visual Content Needed:**
- Logos: Godot logo, browser compatibility icons

**Source Material:**
- Tech stack: [README.md](README.md), [project.godot](project.godot)

---

#### **9. Call-to-Action / Footer**

**Primary CTA:** "Play Game" (bright magenta button, links to live game)  
**Secondary CTA:** "View Source / GitHub" (if applicable)  

**Footer Links:**
- GitHub (if public repo)
- Privacy Policy
- Terms of Service
- Credits / Attribution
- Social links (Twitter, Discord, etc., if applicable)

**Footer Copy:**
```
HyperType © 2026. Built by [Your Name/Studio]. 
Play in browser. Create a free account or play as a guest.
```

---

### Landing Page Design Notes

**Layout & Responsiveness:**
- Desktop-first (1600 × 900 base resolution matches game)
- Mobile-friendly: Stack sections vertically, optimize images
- Dark theme throughout (matches in-game aesthetic)

**Color Scheme:**
- Background: `#04060d` or similar dark blue
- Accent 1: `#ff00b8` (magenta) – buttons, highlights
- Accent 2: `#00d6ff` (cyan) – secondary accents, glows
- Text: `#f6f7fb` (white)

**Typography:**
- Font: Departure Mono (if available), fallback to monospace or system font
- Heading: Bold, large size (48–64px)
- Body: Regular, readable size (16–18px)
- Accent text: Lighter gray `#aab4d6`

**Imagery:**
- Screenshots directly from the game (captured at 1600 × 900)
- High contrast with neon colors
- Optional: Short gameplay video (2–5 seconds)

**Animations:**
- Subtle parallax on scroll (optional)
- Button hover effects (scale + color change)
- Stat counters animate up on page load (if section visible)
- Auto-playing muted gameplay video (if included)

---

## 6. Missing Data

### Required Before Landing Page Design

| Data | Use Case | Priority | Status |
|------|----------|----------|--------|
| **Live Game URL** | Link "Play Now" button; deployment endpoint | High | ⚠️ Not in codebase |
| **GitHub Repository URL** | Optional footer/social link | Medium | ⚠️ Not in codebase |
| **Final Tagline** | Hero section headline | High | 📝 Exists: "A neon arcade typing game built with Godot" |
| **App Logo (Vector)** | Header branding, favicon | High | ⚠️ `vollrath_logo.svg` exists but unclear if final |
| **Gameplay Video** | Hero section or feature carousel | Medium | ⚠️ Not in codebase; needs capture |
| **Gameplay Screenshots (4–6)** | Feature highlight carousel, sections | High | 📝 Scenes exist; needs capture at 1600×900 |
| **Achievement Badge Icons (25+)** | Achievements section gallery | Medium | ✅ Exist in `/assets/sprites/badges/` |
| **Social Media Links** | Footer, optional sharing | Low | ⚠️ Not specified |
| **SEO Meta Title** | Page `<title>` tag | Medium | ⚠️ Not finalized (recommend: "HyperType – Free Typing Game") |
| **SEO Meta Description** | Page `<meta description>` | Medium | ⚠️ Not finalized (recommend: "Fast-paced synthwave typing shooter. Type words to destroy enemies, build streaks, unlock achievements. Play free in your browser.") |
| **Creator/Studio Name** | Footer attribution | Low | ⚠️ Not in codebase |
| **Launch Date or Status Line** | Landing page headline or subtitle | Low | ⚠️ Not specified; README says "Active project" |
| **Email / Contact** | Footer contact info | Low | ⚠️ Not specified |
| **Privacy Policy / Terms** | Footer links | Medium | ⚠️ Not in repo |
| **Preferred CTA Wording** | "Play Now" vs "Start Game" vs other | Low | 📝 "Play the game" suggested in README |

---

### Assumptions Made in This Brief

1. **Deployment:** Game is deployed at `https://avollrath.github.io/HyperType/` (from README.md link)
2. **Audience:** Typing enthusiasts, casual gamers, arcade fans, achievement hunters
3. **Tone:** Energetic, arcade-inspired, modern; not overly technical
4. **Target Market:** Web browser players (no desktop app emphasis)
5. **CTA Priority:** "Play Game" is primary; account creation is secondary
6. **Guest Mode:** Emphasized as low-friction entry point
7. **Achievement System:** Significant engagement hook (25+ badges)
8. **Visual Style:** Pure synthwave/cyberpunk; no toned-down alternatives
9. **Mobile:** Typing games are harder on mobile; landing page should be responsive but gameplay may note desktop-preferred

---

### Recommended Next Steps

1. **Content Gathering:**
   - [ ] Confirm live game URL
   - [ ] Finalize SEO title and meta description
   - [ ] Decide on GitHub visibility (public/private)
   - [ ] Create or finalize logo asset

2. **Asset Capture:**
   - [ ] Screenshot intro screen (1600 × 900)
   - [ ] Screenshot gameplay (1600 × 900)
   - [ ] Screenshot game over / stats screen (1600 × 900)
   - [ ] Screenshot with high streak (25+) if possible
   - [ ] Optional: Record 2–3 second gameplay GIF/video

3. **Design:**
   - [ ] Create landing page wireframe
   - [ ] Define grid/layout system
   - [ ] Choose font stack (Departure Mono + fallbacks)
   - [ ] Finalize color palette usage

4. **Copy Refinement:**
   - [ ] Write or finalize SEO title and description
   - [ ] Refine hero section copy if needed
   - [ ] Decide on feature card wording
   - [ ] Draft footer legal/contact info

5. **Build & Launch:**
   - [ ] Implement landing page (HTML/CSS or framework)
   - [ ] Link to live game
   - [ ] Test responsiveness
   - [ ] Add analytics (optional)
   - [ ] Deploy

---

## Appendix: Quick Reference

### Key Files Referenced

| Path | Purpose | Key Info |
|------|---------|----------|
| [README.md](README.md) | Project overview | Taglines, features, philosophy |
| [project.godot](project.godot) | Godot config | Window size, main scene, autoloads |
| [main_theme.tres](main_theme.tres) | Theme/styling | Colors, button styles, font |
| [main.gd](scripts/main.gd) | Core gameplay | Game loop, scoring, animations |
| [intro_screen.gd](scripts/intro_screen.gd) | Menu UI | Auth, difficulty select, achievements |
| [game_over.gd](scripts/game_over.gd) | Results screen | Stats display, animations |
| [Achievements.gd](scripts/Achievements.gd) | Achievement system | 25+ achievement definitions |
| [PlayerData.gd](scripts/PlayerData.gd) | Persistence | Stats tracking, save/load |
| [index.shell.html](docs/index.shell.html) | Web colors | CSS variables, brand palette |
| [main.tscn](scenes/main.tscn) | Gameplay scene | In-game HUD, UI layout |
| [intro_screen.tscn](scenes/intro_screen.tscn) | Menu scene | Button layout, screens |
| [game_over.tscn](scenes/game_over.tscn) | Results scene | Stats display layout |

### Brand Color Quick Ref

```css
--accent: #ff00b8;      /* Magenta – primary CTA, highlights */
--accent-2: #00d6ff;    /* Cyan – secondary accents, glows */
--bg: #04060d;          /* Deep dark – backgrounds */
--text: #f6f7fb;        /* White – body text */
--muted: #aab4d6;       /* Gray – secondary text, disabled */
```

### Typography Quick Ref

```
Font Family: "Departure Mono Nerd Font Regular" (fallback: monospace)
Base Size: 24px
Heading: 48–64px, bold
Body: 16–18px, regular
Accent: 12–16px, regular, color: #aab4d6
```

---

**End of Landing Page Brief**

*This document should be sufficient to kickstart design and copywriting for HyperType's landing page. All references point to actual codebase files for verification and deeper context.*
