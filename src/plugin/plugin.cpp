#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include "mpristest.h"

class MprisTestPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")
    
public:
    void registerTypes(const char *uri) override {
        Q_ASSERT(uri == QLatin1String("MprisTest"));
        qmlRegisterType<MprisTest>(uri, 1, 0, "MprisTest");
    }
};

#include "plugin.moc"
