#ifndef MPRISTEST_H
#define MPRISTEST_H

#include <QObject>
#include <QDBusConnection>

class MprisTest : public QObject {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.mpris.MediaPlayer2.Player")
    
    // Root MediaPlayer2 properties
    Q_PROPERTY(QString DesktopEntry READ desktopEntry CONSTANT)
    Q_PROPERTY(QString Identity READ identity CONSTANT)
    Q_PROPERTY(bool CanQuit READ canQuit CONSTANT)
    Q_PROPERTY(bool CanRaise READ canRaise CONSTANT)
    
    // Player properties
    Q_PROPERTY(QString PlaybackStatus READ playbackStatus WRITE setPlaybackStatus NOTIFY playbackStatusChanged)
    Q_PROPERTY(bool CanControl READ canControl CONSTANT)
    Q_PROPERTY(bool CanPlay READ canPlay CONSTANT)
    Q_PROPERTY(bool CanPause READ canPause CONSTANT)
    Q_PROPERTY(bool CanGoNext READ canGoNext CONSTANT)
    Q_PROPERTY(bool CanGoPrevious READ canGoPrevious CONSTANT)
    
public:
    explicit MprisTest(QObject *parent = nullptr);
    Q_INVOKABLE bool registerService();
    
    // Root MediaPlayer2 property getters
    QString desktopEntry() const { return "musiki2.symbuzzer_musiki2_1.1.0"; }
    QString identity() const { return "YouTube Music"; }
    bool canQuit() const { return false; }
    bool canRaise() const { return true; }
    
    // Player property getters
    QString playbackStatus() const { return m_playbackStatus; }
    bool canControl() const { return true; }
    bool canPlay() const { return true; }
    bool canPause() const { return true; }
    bool canGoNext() const { return true; }
    bool canGoPrevious() const { return true; }
    
    // Player property setters
    void setPlaybackStatus(const QString &status);
    
public slots:
    // MPRIS Player methods
    void Play();
    void Pause();
    void PlayPause();
    void Next();
    void Previous();
    void Stop();
    
signals:
    // Signals to QML
    void playRequested();
    void pauseRequested();
    void playPauseRequested();
    void nextRequested();
    void previousRequested();
    void stopRequested();
    
    // Property signals
    void playbackStatusChanged();
    
private:
    bool m_registered;
    QString m_playbackStatus;
};

#endif // MPRISTEST_H
