# musiki2 (unconfident)
Youtube Music shortcut for Ubuntu Touch with background playback feature  

## License
- The main code of app is from [Rúben Carneiro](https://gitlab.com/rubencarneiro)'s [ChatGPT](https://gitlab.com/rubencarneiro/ChatGPT) app (for Ubuntu Touch) licensed under GNU General Public License version 3
- The [build workflow](https://github.com/symbuzzer/musiki2/blob/master/.github/workflows/clickable.yml) is from [Mateo Salta](https://github.com/mateosalta)'s [cuddly-bassoon](https://github.com/mateosalta/cuddly-bassoon) app licensed under GNU General Public License version 3

## Thanks
- Shapa7276 for system integration *(sound indicator, playback controls etc.)*
- Rúben Carneiro for main code of app
- Mateo Salta for build workflow
- Maciek Sopyło, Aaron Hafer and Kugi Eusebio for background playback feature
- Brian Douglass for limiting webview URL


## Changelog
[CHANGELOG.md](https://github.com/symbuzzer/musiki2/blob/master/CHANGELOG.md)

## Technical Details: System Media Controls (MPRIS)

This app implements a custom C++ D-Bus bridge to enable full system media controls (Sound Indicator, Lock Screen, Hardware Keys) on Ubuntu Touch.

### The Problem
QtWebEngine creates a dynamic MPRIS service name (e.g., `org.mpris.MediaPlayer2.chromium.instance1234`) which changes on every launch. The Ubuntu Touch sound indicator requires a fixed, predictable service name to discover and control the application.

### The Solution
We implemented a custom C++ QML plugin (`MprisTest`) that:
1.  **Registers a Fixed Service**: Registers `org.mpris.MediaPlayer2.musiki2` on the session D-Bus.
2.  **Implements MPRIS Interface**: Exposes the standard `org.mpris.MediaPlayer2.Player` interface.
3.  **Bridges Signals**: Receives D-Bus commands (Play, Pause, Next, etc.) and emits QML signals.
4.  **Injects JavaScript**: QML catches these signals and injects JavaScript into the `WebEngineView` to click the corresponding buttons on the YouTube Music website.

### Architecture
*   **C++ Plugin (`src/plugin/`)**: Handles low-level D-Bus communication.
*   **D-Bus Service File**: `org.mpris.MediaPlayer2.musiki2.service` allows the system to auto-discover the app.
*   **QML Integration**: `Main.qml` instantiates the plugin and syncs playback status.

### Reusing this Code
This bridge is designed to be modular. To use it in another app, you would need to:
1.  Copy the `src/plugin` directory.
2.  Update the service name in `mpristest.cpp` and `mpristest.h`.
3.  Update the `DesktopEntry` property to match your app's ID.
4.  Connect the QML signals to your WebView's JavaScript logic.


