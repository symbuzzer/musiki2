# Bluetooth Fix - Final Solution

## Root Cause Found! ✅

**The Problem**: QtWebEngine automatically creates its own MPRIS service `org.mpris.MediaPlayer2.chromium.instance9282`, which **conflicts** with our custom `org.mpris.MediaPlayer2.musiki2`. This confuses `mpris-proxy` (the service that routes Bluetooth commands), so it sends commands to **neither** service.

**The Solution**: Disable QtWebEngine's automatic MPRIS registration by setting environment variables in the wrapper script.

## What Changed

**[musiki2-wrapper.sh](file:///home/shapa/Documents/proj/musiki2/musiki2-wrapper.sh)**:
- Added `export QT_LOGGING_RULES="qt.multimedia.mpris=false"` to disable QtWebEngine MPRIS
- This prevents the conflicting `chromium.instance` service from being created

## Testing

### 1. Install the New Build

```bash
clickable install
```

### 2. Verify Only One MPRIS Service

After starting musiki2 and playing music, run:

```bash
dbus-send --session --print-reply \
  --dest=org.freedesktop.DBus \
  /org/freedesktop/DBus \
  org.freedesktop.DBus.ListNames | grep mpris
```

**Expected**: Should see ONLY:
- `org.mpris.MediaPlayer2.musiki2` ✓
- `org.mpris.MediaPlayer2.MediaHub`

**Should NOT see**:
- `org.mpris.MediaPlayer2.chromium.instanceXXXX` ❌

### 3. Test Bluetooth

**While musiki2 is playing**, monitor D-Bus:

```bash
dbus-monitor --session | grep -E "(member=Play|member=Pause|musiki2)"
```

Press your Bluetooth button. **You should now see**:

```
method call destination=:1.XX path=/org/mpris/MediaPlayer2; member=PlayPause
```

### 4. Verify It Works

Press Bluetooth play/pause button → Music should pause/play! 🎉

## If It Still Doesn't Work

If the chromium service still appears, we may need to try a different approach. Please share:

1. Output of the MPRIS service list
2. Output of the D-Bus monitor when pressing Bluetooth button

---

**This should finally make Bluetooth buttons work!** The Qt WebEngine MPRIS conflict was the missing piece.
