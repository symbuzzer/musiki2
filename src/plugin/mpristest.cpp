#include "mpristest.h"
#include "mprisroot.h"
#include <QDebug>
#include <QDBusError>
#include <QDBusMessage>
#include <QDBusObjectPath>

MprisTest::MprisTest(QObject *parent)
    : QObject(parent)
    , m_registered(false)
    , m_playbackStatus("Stopped")
{
}

void MprisTest::setPlaybackStatus(const QString &status) {
    if (m_playbackStatus != status) {
        m_playbackStatus = status;
        emit playbackStatusChanged();
        
        // Signal D-Bus that property changed (optional but good practice)
        // For simple implementation we rely on QDBusConnection::ExportAllProperties
    }
}

bool MprisTest::registerService() {
    QDBusConnection bus = QDBusConnection::sessionBus();
    
    // 1. Register standard MPRIS service (for Sound Indicator)
    if (!bus.registerService("org.mpris.MediaPlayer2.musiki2")) {
        qWarning() << "Failed to register MPRIS service:" << bus.lastError().message();
        return false;
    }
    qDebug() << "✓ Service registered: org.mpris.MediaPlayer2.musiki2";
    
    // 2. Register Standard MPRIS Path (for Sound Indicator)
    if (!bus.registerObject("/org/mpris/MediaPlayer2", this,
                           QDBusConnection::ExportAllSlots |
                           QDBusConnection::ExportAllProperties |
                           QDBusConnection::ExportAllSignals)) {
        qWarning() << "Failed to register MPRIS object:" << bus.lastError().message();
        return false;
    }
    qDebug() << "✓ Object registered: /org/mpris/MediaPlayer2";
    
    // 3. Create MediaHub Session (for Bluetooth)
    // This is THE KEY! We must call CreateFixedSession to get a real session path
    qDebug() << "Creating MediaHub session for Bluetooth support...";
    
    QDBusMessage msg = QDBusMessage::createMethodCall(
        "com.lomiri.MediaHub.Service",
        "/com/lomiri/MediaHub/Service",
        "com.lomiri.MediaHub.Service",
        "CreateFixedSession"
    );
    msg << QString("musiki2");  // Session name
    
    QDBusMessage reply = bus.call(msg);
    
    if (reply.type() == QDBusMessage::ErrorMessage) {
        qWarning() << "Failed to create MediaHub session:" << reply.errorMessage();
        qWarning() << "Bluetooth media keys will NOT work!";
    } else {
        // Get the session object path from the reply
        QDBusObjectPath sessionPath = reply.arguments().at(0).value<QDBusObjectPath>();
        qDebug() << "✓ MediaHub session created:" << sessionPath.path();
        
        // 4. Register our MPRIS interface at the MediaHub session path
        if (!bus.registerObject(sessionPath.path(), this,
                               QDBusConnection::ExportAllSlots |
                               QDBusConnection::ExportAllProperties |
                               QDBusConnection::ExportAllSignals)) {
            qWarning() << "Failed to register at MediaHub session path:" << bus.lastError().message();
            qWarning() << "Bluetooth media keys may not work!";
        } else {
            qDebug() << "✓ MPRIS interface registered at MediaHub session!";
            qDebug() << "  Bluetooth media keys should now work!";
        }
    }
    
    qDebug() << "✓ MPRIS service is ready for Sound Indicator and Bluetooth!";
    qDebug() << "  Note: Bluetooth support requires bluetooth_monitor.sh to be running";
    
    m_registered = true;
    return true;
}

void MprisTest::Pause() {
    qDebug() << "★ Pause() called via D-Bus!";
    emit pauseRequested();
}

void MprisTest::Play() {
    qDebug() << "★ Play() called via D-Bus!";
    emit playRequested();
}

void MprisTest::PlayPause() {
    qDebug() << "★ PlayPause() called via D-Bus!";
    emit playPauseRequested();
}

void MprisTest::Next() {
    qDebug() << "★ Next() called via D-Bus!";
    emit nextRequested();
}

void MprisTest::Previous() {
    qDebug() << "★ Previous() called via D-Bus!";
    emit previousRequested();
}

void MprisTest::Stop() {
    qDebug() << "★ Stop() called via D-Bus!";
    emit stopRequested();
}

// Explicitly implement GetAll to satisfy mpris-proxy
// mpris-proxy often calls this to cache all properties at once
QVariantMap MprisTest::GetAll(const QString &interface_name) {
    QVariantMap props;
    
    if (interface_name == "org.mpris.MediaPlayer2") {
        props.insert("Identity", identity());
        props.insert("DesktopEntry", desktopEntry());
        props.insert("CanQuit", canQuit());
        props.insert("CanRaise", canRaise());
        props.insert("SupportedMimeTypes", QStringList());
        props.insert("SupportedUriSchemes", QStringList());
        props.insert("HasTrackList", false);
    } 
    else if (interface_name == "org.mpris.MediaPlayer2.Player") {
        props.insert("PlaybackStatus", playbackStatus());
        props.insert("CanControl", canControl());
        props.insert("CanPlay", canPlay());
        props.insert("CanPause", canPause());
        props.insert("CanGoNext", canGoNext());
        props.insert("CanGoPrevious", canGoPrevious());
        props.insert("Metadata", QVariantMap()); // Empty metadata for now
        props.insert("Volume", 1.0);
        props.insert("Position", 0);
        props.insert("MinimumRate", 1.0);
        props.insert("MaximumRate", 1.0);
        props.insert("Rate", 1.0);
    }
    
    return props;
}
