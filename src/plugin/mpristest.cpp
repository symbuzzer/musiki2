#include "mpristest.h"
#include "mprisroot.h"
#include <QDebug>
#include <QDBusError>

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
    
    // Try to register service name
    if (!bus.registerService("org.mpris.MediaPlayer2.musiki2")) {
        qWarning() << "Failed to register service:" << bus.lastError().message();
        return false;
    }
    
    qDebug() << "✓ Service registered: org.mpris.MediaPlayer2.musiki2";
    
    // Register this object with all interfaces
    if (!bus.registerObject("/org/mpris/MediaPlayer2", this,
                           QDBusConnection::ExportAllSlots |
                           QDBusConnection::ExportAllProperties |
                           QDBusConnection::ExportAllSignals)) {
        qWarning() << "Failed to register object:" << bus.lastError().message();
        bus.unregisterService("org.mpris.MediaPlayer2.musiki2");
        return false;
    }
    
    qDebug() << "✓ Object registered: /org/mpris/MediaPlayer2";
    qDebug() << "✓ MPRIS service is ready!";
    
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
