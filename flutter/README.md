# CodexBar (Flutter port)

A Flutter port of [CodexBar](https://github.com/steipete/codexbar), the macOS
menu bar app that surfaces AI coding-provider usage limits, credits, and
status. This port targets Linux first (with macOS/Windows supported by the
same Flutter packages) and uses the system tray via `tray_manager`.

See [`docs/upstream/`](docs/upstream/) for the upstream tracking checkpoint,
the Swift↔Dart porting map, and the porting decisions.

## Status

This is the **initial port**: core data model, provider fetch pipeline,
adaptive refresh, icon renderer, tray integration, menu card UI, settings,
and notifications are implemented. Four providers are wired (OpenAI, Anthropic,
OpenRouter, DeepSeek) via API key; OAuth/cookie/CLI auth and the remaining 56
providers are follow-ups. See `docs/upstream/PORT_MAP.md`.

## Prerequisites

### Flutter

Flutter 3.44+ (stable) with desktop enabled:

```bash
flutter config --enable-linux-desktop
flutter doctor
```

### Linux system packages

The Linux build needs development headers for the platform plugins
(`flutter_secure_storage` → libsecret, `tray_manager`/`window_manager` → GTK):

```bash
sudo apt-get install -y \
  libsecret-1-dev \
  libgtk-3-dev \
  libjsoncpp-dev \
  cmake \
  ninja-build \
  pkg-config
```

> On macOS/Windows, `flutter_secure_storage` and the tray/window plugins use
> the native Keychain / DPAPI / StatusNotifierItem with no extra setup.

## Build & run

```bash
cd flutter
flutter pub get
flutter run -d linux
```

The app starts with its window **hidden** and lives in the system tray (the
close-to-tray pattern). Click the tray icon to show the menu card popup. The
settings window is reachable from the menu card or by routing to `/settings`.

> Cinnamon's XApp Status Applet (enabled by default) acts as the
> StatusNotifierItem host, so the tray icon appears without extra setup on
> Linux Mint. GNOME users need the AppIndicator extension.

## Test

```bash
cd flutter
flutter test
```

## Configure providers

1. Open the menu card (tray click) → **Settings**.
2. Go to **Providers**.
3. Paste an API key for OpenAI / Anthropic / OpenRouter / DeepSeek and save.
   The provider is auto-enabled and starts refreshing.

Keys are stored in the system secure store (libsecret/Keyring on Linux,
Keychain on macOS, DPAPI on Windows).

## Notifications

- **Change detection**: posts a notification when usage differs from the
  previous refresh (toggle in Settings → Notifications).
- **Threshold warnings**: posts a notification when usage crosses the
  configured warning/critical percent (once per crossing).

## Project layout

```
lib/
├── main.dart, app.dart            # entry + window/tray wiring
├── core/
│   ├── models/                    # RateWindow, UsageSnapshot, … (CodexBarCore port)
│   ├── providers/                 # descriptor registry + fetch pipeline + 4 strategies
│   ├── refresh/                   # adaptive refresh decision table (pure)
│   ├── storage/                   # settings state + IO + secure storage
│   └── notifications/             # change detection + local notifications bridge
├── state/                         # Riverpod stores (settings, usage, default providers)
└── ui/
    ├── tray/                      # icon CustomPainter + tray controller
    ├── menu_card/                 # usage card, progress bar, tray popup
    ├── settings/                  # general/notifications/menu bar/providers panes
    └── theme/
docs/upstream/                     # UPSTREAM_CHECKPOINT, PORT_MAP, DECISIONS
```

## Tracking upstream changes

The Swift upstream is updated frequently. To detect and selectively port new
upstream changes:

```bash
git remote add upstream https://github.com/steipete/codexbar.git
git fetch upstream
git log 59c08133..upstream/main --oneline          # new commits since the checkpoint
git diff --stat 59c08133..upstream/main -- Sources/  # changed Swift files
```

Then look up each changed file in `docs/upstream/PORT_MAP.md` and update the
Dart counterpart. After porting, bump the checkpoint in
`docs/upstream/UPSTREAM_CHECKPOINT.md`. See that file for the full procedure.
