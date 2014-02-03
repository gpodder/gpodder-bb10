#include <QGuiApplication>
#include <QQuickView>
#include <QFileInfo>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickView view;
    view.setSource(QUrl::fromLocalFile(QFileInfo("app/native/gpodder-ui-qml/touch/gpodder.qml").absoluteFilePath()));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.showFullScreen();
    return app.exec();
}
