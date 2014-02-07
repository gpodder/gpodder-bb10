#include <QGuiApplication>
#include <QQuickView>
#include <QFileInfo>
#include <QFontDatabase>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QFontDatabase::addApplicationFont("app/native/gpodder-ui-qml/touch/icons/iconic_fill.ttf");
    QFontDatabase::addApplicationFont("app/native/gpodder-ui-qml/touch/fonts/source-sans-pro.extralight.ttf");

    QQuickView view;
    view.setSource(QUrl::fromLocalFile(QFileInfo("app/native/gpodder-ui-qml/touch/gpodder.qml").absoluteFilePath()));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.showFullScreen();
    return app.exec();
}
