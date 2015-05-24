#include <QGuiApplication>
#include <QQuickView>
#include <QFileInfo>
#include <QFontDatabase>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Load libpython globally (so _sqlite3.so can be loaded)
    dlopen("/usr/lib/libpython3.2m.so.1.0", RTLD_GLOBAL | RTLD_NOW);

    QFontDatabase::addApplicationFont("app/native/gpodder-ui-qml/touch/icons/iconic_fill.ttf");
    QFontDatabase::addApplicationFont("app/native/gpodder-ui-qml/touch/fonts/source-sans-pro.extralight.ttf");

    QQuickView view;
    view.setSource(QUrl::fromLocalFile(QFileInfo("app/native/gpodder-ui-qml/touch/gpodder.qml").absoluteFilePath()));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.showFullScreen();
    return app.exec();
}
