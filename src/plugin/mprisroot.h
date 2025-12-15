#ifndef MPRISROOT_H
#define MPRISROOT_H

#include <QObject>
#include <QString>

class MprisRoot : public QObject {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.mpris.MediaPlayer2")
    
    Q_PROPERTY(bool CanQuit READ canQuit)
    Q_PROPERTY(bool CanRaise READ canRaise)
    Q_PROPERTY(bool HasTrackList READ hasTrackList)
    Q_PROPERTY(QString Identity READ identity)
    Q_PROPERTY(QString DesktopEntry READ desktopEntry)
    
public:
    explicit MprisRoot(QObject *parent = nullptr);
    
    // Properties
    bool canQuit() const { return false; }
    bool canRaise() const { return true; }
    bool hasTrackList() const { return false; }
    QString identity() const { return "YouTube Music"; }
    QString desktopEntry() const { return "musiki2"; }
    
public slots:
    void Raise() {}
    void Quit() {}
};

#endif // MPRISROOT_H
