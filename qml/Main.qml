/*
 * Copyright (C) 2023  Rúben Carneiro
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * chatgpt is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Modified for musiki2 app by Ali BEYAZ under GNU GPL v3
 */


import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import Morph.Web 0.1
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtWebEngine 1.7
import QtMultimedia 5.12
import GSettings 1.0


MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'musiki2.symbuzzer'
    theme.name: "Lomiri.Components.Themes.SuruDark"
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    // Media player properties
    property bool isPlaying: false
    property bool ignoreCommands: false
    property string currentTitle: ""
    property string currentArtist: ""

    function checkAppLifecycleExemption() {
        const appidList = gsettings.lifecycleExemptAppids;
        if (!appidList) {
            return false;
        }
        return appidList.includes(Qt.application.name);
    }

    function setAppLifecycleExemption() {
        const appid = "musiki2.symbuzzer";
        if (!root.checkAppLifecycleExemption()) {
            const exemptedAppidList = gsettings.lifecycleExemptAppids || [];
            exemptedAppidList.push(appid);
            gsettings.lifecycleExemptAppids = exemptedAppidList;
        }
    }

    function unsetAppLifecycleExemption() {
        if (root.checkAppLifecycleExemption()) {
            const appidList = gsettings.lifecycleExemptAppids;
            const index = appidList.indexOf("musiki2.symbuzzer");
            const newList = appidList.slice();

            if (index > -1) {
              newList.splice(index, 1);
            }

            gsettings.lifecycleExemptAppids = newList;
        }
    }

    GSettings {
        id: gsettings
        schema.id: "com.canonical.qtmir"
    }

    // System media player - uses long silent audio to maintain MPRIS registration
    MediaPlayer {
        id: systemMediaPlayer
        audioRole: MediaPlayer.MusicRole
        volume: 0.0  // Silent
        autoPlay: false
        
        playlist: Playlist {
            id: dummyPlaylist
            playbackMode: Playlist.Loop
            
            onCurrentIndexChanged: {
                if (root.ignoreCommands || currentIndex === -1 || currentIndex === 1) return;
                
                console.log("System UI command detected, index:", currentIndex);
                if (currentIndex === 2) {
                    console.log("Forwarding NEXT");
                    webview.runJavaScript("window.mediaControlHandler.next()");
                } else if (currentIndex === 0) {
                    console.log("Forwarding PREVIOUS");
                    webview.runJavaScript("window.mediaControlHandler.previous()");
                }
                
                // Reset to middle index (1) immediately
                root.ignoreCommands = true;
                dummyPlaylist.currentIndex = 1;
                Qt.callLater(function() { root.ignoreCommands = false; });
            }
        }
        
        onPositionChanged: {
            // Loop silent audio before it ends (10min = 600s)
            if (position > 590000 && !root.ignoreCommands) {
                console.log("Looping silent audio (rewinding)");
                root.ignoreCommands = true;
                seek(0);
                play();
                Qt.callLater(function() { root.ignoreCommands = false; });
            }
        }

        onPlaybackStateChanged: {
            if (root.ignoreCommands) return;
            
            console.log("SystemMediaPlayer state change:", playbackState);
            if (playbackState === MediaPlayer.PlayingState && !root.isPlaying) {
                webview.runJavaScript("window.mediaControlHandler.play()");
            } else if (playbackState === MediaPlayer.PausedState && root.isPlaying) {
                webview.runJavaScript("window.mediaControlHandler.pause()");
            }
        }

        onStatusChanged: {
            if (status === MediaPlayer.EndOfMedia) {
                root.ignoreCommands = true;
                dummyPlaylist.currentIndex = 1;
                seek(0);
                play();
                Qt.callLater(function() { root.ignoreCommands = false; });
            }
        }
        
        Component.onCompleted: {
            dummyPlaylist.addItem(Qt.resolvedUrl("../assets/Youtube.wav"));
            dummyPlaylist.addItem(Qt.resolvedUrl("../assets/Youtube.wav"));
            dummyPlaylist.addItem(Qt.resolvedUrl("../assets/Youtube.wav"));
            dummyPlaylist.currentIndex = 1;
            console.log("System MediaPlayer initialized with 3-item dummy playlist centered at 1");
        }
    }

    // Timer to keep system player in sync with WebView state
    Timer {
        id: playbackSyncTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (root.ignoreCommands) return;
            
            var script = `
                (function() {
                    var pauseButton = document.querySelector('button[aria-label="Pause"]') || 
                                    document.querySelector('button[aria-label="pause"]');
                    return !!pauseButton;
                })();
            `;
            webview.runJavaScript(script, function(result) {
                var isCurrentlyPlaying = (result === "true" || result === true);
                root.isPlaying = isCurrentlyPlaying;
                
                // Keep system player state in sync so system UI shows correct buttons
                if (isCurrentlyPlaying && systemMediaPlayer.playbackState !== MediaPlayer.PlayingState) {
                    root.ignoreCommands = true;
                    systemMediaPlayer.play();
                    Qt.callLater(function() { root.ignoreCommands = false; });
                } else if (!isCurrentlyPlaying && systemMediaPlayer.playbackState === MediaPlayer.PlayingState) {
                    root.ignoreCommands = true;
                    systemMediaPlayer.pause();
                    Qt.callLater(function() { root.ignoreCommands = false; });
                }
            });
        }
    }


    Page {
        id: mainPage
        anchors.fill: parent
        
        Component.onCompleted: {
            console.log("Page component completed");
        }
    
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                if (webview.recentlyAudible) {
                    setAppLifecycleExemption();
                } else {
                    unsetAppLifecycleExemption();
                }
            }
        }
    
        Component.onDestruction: unsetAppLifecycleExemption()
    
        WebEngineView {
            id: webview
            anchors.fill: parent
            width: units.gu(45)
            height: units.gu(75)
            url: "https://music.youtube.com/"
            zoomFactor: 3.0 //scales the webpage on the device, range allowed from 0.25 to 5.0; the default factor is 1.0
            profile: webViewProfile

            onRecentlyAudibleChanged: {
                if (webview.recentlyAudible) {
                    setAppLifecycleExemption();
                } else {
                    unsetAppLifecycleExemption();
                }
            }

            onLoadingChanged: {
                console.log("WebView loading changed, status:", loadRequest.status);
                if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                    console.log("Page loaded successfully, calling injectMediaControlScript");
                    console.log("Function exists?", typeof mainPage.injectMediaControlScript);
                    mainPage.injectMediaControlScript();
                    console.log("Media Session API handlers injected");
                } else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                    console.log("Page load FAILED:", loadRequest.errorString);
                }
            }
        }
    
        WebEngineProfile {
            id: webViewProfile
            persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies;
            storageName: "Storage"
            httpCacheType: WebEngineProfile.DiskHttpCache; //cache qml content to file
            httpUserAgent: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.196 Mobile Safari/537.36";
            property alias dataPath: webViewProfile.persistentStoragePath
            dataPath: dataLocation
            persistentStoragePath: "/home/phablet/.cache/musiki2.symbuzzer/QtWebEngine"
    
        }
    
        ProgressBar {
            id: loadingIndicator
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            //aquire the webviews loading progress for the indicators value
            value: webview.loadProgress/100
            //hide loadingIndicator when page has been loaded successfully
            visible: webview.loadProgress === 100 ? false : true
        }
    
        Rectangle {
            //show placeholder while the page is loading to avoid ugly flickering of webview
            id: webViewPlaceholder
            anchors {
                top: loadingIndicator.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            z: 1
            color: Suru.backgroundColor
            visible: webview.loadProgress === 100 ? false : true
    
            BusyIndicator {
                id: busy
                anchors.centerIn: parent
            }
        }

        // Background how-to hint (appears on load)
    

        // Media control functions for system integration
        function injectMediaControlScript() {
            console.log("injectMediaControlScript called");
            var script = `
                (function() {
                    console.log('Setting up media controls...');
                    
                    // Set up Media Session API for system integration
                    if ('mediaSession' in navigator) {
                        console.log('Media Session API available');
                        
                        // Define action handlers
                        navigator.mediaSession.setActionHandler('play', function() {
                            console.log('Media Session: PLAY requested');
                            // YouTube Music uses a single toggle button for play/pause
                            var toggleButton = document.querySelector('button[aria-label="Play"]') || 
                                             document.querySelector('button[aria-label="Pause"]') ||
                                             document.querySelector('button[aria-label="play"]') ||
                                             document.querySelector('button[aria-label="pause"]') ||
                                             document.querySelector('.play-pause-button');
                            if (toggleButton) {
                                console.log('Clicking play/pause toggle button');
                                toggleButton.click();
                            } else {
                                console.log('Play/pause button not found');
                            }
                        });
                        
                        navigator.mediaSession.setActionHandler('pause', function() {
                            console.log('Media Session: PAUSE requested');
                            // YouTube Music uses a single toggle button for play/pause
                            var toggleButton = document.querySelector('button[aria-label="Play"]') || 
                                             document.querySelector('button[aria-label="Pause"]') ||
                                             document.querySelector('button[aria-label="play"]') ||
                                             document.querySelector('button[aria-label="pause"]') ||
                                             document.querySelector('.play-pause-button');
                            if (toggleButton) {
                                console.log('Clicking play/pause toggle button');
                                toggleButton.click();
                            } else {
                                console.log('Play/pause button not found');
                            }
                        });
                        
                        navigator.mediaSession.setActionHandler('previoustrack', function() {
                            console.log('Media Session: PREVIOUS requested');
                            var prevButton = document.querySelector('button[aria-label="Previous"]') || 
                                           document.querySelector('button[aria-label="previous"]') ||
                                           document.querySelector('.previous-button');
                            if (prevButton) {
                                console.log('Clicking previous button');
                                prevButton.click();
                            } else {
                                console.log('Previous button not found');
                            }
                        });
                        
                        navigator.mediaSession.setActionHandler('nexttrack', function() {
                            console.log('Media Session: NEXT requested');
                            var nextButton = document.querySelector('button[aria-label="Next"]') || 
                                           document.querySelector('button[aria-label="next"]') ||
                                           document.querySelector('.next-button');
                            if (nextButton) {
                                console.log('Clicking next button');
                                nextButton.click();
                            } else {
                                console.log('Next button not found');
                            }
                        });
                        
                        console.log('All Media Session handlers registered');
                        
                        // Update metadata periodically
                        setInterval(function() {
                            var titleElement = document.querySelector('.title.ytmusic-player-bar') ||
                                             document.querySelector('yt-formatted-string.title');
                            var artistElement = document.querySelector('.byline.ytmusic-player-bar') ||
                                              document.querySelector('yt-formatted-string.byline');
                            var artworkElement = document.querySelector('img.ytmusic-player-bar');
                            
                            if (titleElement && artistElement) {
                                navigator.mediaSession.metadata = new MediaMetadata({
                                    title: titleElement.textContent.trim(),
                                    artist: artistElement.textContent.trim(),
                                    artwork: artworkElement ? [{
                                        src: artworkElement.src,
                                        sizes: '512x512',
                                        type: 'image/jpeg'
                                    }] : []
                                });
                            }
                        }, 2000);
                    } else {
                        console.log('Media Session API NOT available');
                    }
                    
                    // Keep old handler for QML access
                    window.mediaControlHandler = {
                        play: function() {
                            var playButton = document.querySelector('button[aria-label="Play"]') || 
                                           document.querySelector('button[aria-label="play"]');
                            if (playButton) playButton.click();
                        },
                        pause: function() {
                            var pauseButton = document.querySelector('button[aria-label="Pause"]') || 
                                            document.querySelector('button[aria-label="pause"]');
                            if (pauseButton) pauseButton.click();
                        },
                        next: function() {
                            var nextButton = document.querySelector('button[aria-label="Next track"]') || 
                                           document.querySelector('button[aria-label="Next"]') || 
                                           document.querySelector('button[aria-label="next"]') ||
                                           document.querySelector('.next-button') ||
                                           document.querySelector('tp-yt-paper-icon-button[aria-label="Next"]');
                            if (nextButton) {
                                console.log('Clicking NEXT button');
                                nextButton.click();
                            } else {
                                console.log('NEXT button not found by any selector');
                            }
                        },
                        previous: function() {
                            var prevButton = document.querySelector('button[aria-label="Previous track"]') || 
                                           document.querySelector('button[aria-label="Previous"]') || 
                                           document.querySelector('button[aria-label="previous"]') ||
                                           document.querySelector('.previous-button') ||
                                           document.querySelector('tp-yt-paper-icon-button[aria-label="Previous"]');
                            if (prevButton) {
                                console.log('Clicking PREVIOUS button');
                                prevButton.click();
                            } else {
                                console.log('PREVIOUS button not found by any selector');
                            }
                        }
                    };
                    console.log('Media control handler initialized');
                })();
            `;
            console.log("Injecting media control script into WebView");
            webview.runJavaScript(script, function(result) {
                console.log("Script injection completed, result:", result);
            });
        }
    }

}
