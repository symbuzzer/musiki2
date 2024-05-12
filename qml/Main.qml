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
import GSettings 1.0


MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'musiki2.symbuzzer'
    theme.name: "Lomiri.Components.Themes.SuruDark"
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

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

    Page {
        anchors.fill: parent
    
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

        onNavigationRequested: {
            var url = request.url.toString();
            if ((url.indexOf('https://music.youtube.com/') === 0 || url.indexOf('https://accounts.google.com/') === 0) && request.isMainFrame) {
                request.action = WebEngineNavigationRequest.AcceptRequest;
            } else if (url.indexOf('https://accounts.google.com/') === 0 && request.isMainFrame) {
                request.action = WebEngineNavigationRequest.AcceptRequest;
            } else {
                Qt.openUrlExternally(url);
                request.action = WebEngineNavigationRequest.IgnoreRequest;
            }
        }

            onRecentlyAudibleChanged: {
                if (webview.recentlyAudible) {
                    setAppLifecycleExemption();
                } else {
                    unsetAppLifecycleExemption();
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
        }
    }
