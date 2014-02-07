#include <QGuiApplication>
#include <QQuickView>
#include <QFileInfo>
#include <QFont>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QFont font("Slate Pro");
    font.setStretch(103);
    font.setWeight(30);
    app.setFont(font);
    QQuickView view;
    view.setSource(QUrl::fromLocalFile(QFileInfo("app/native/gpodder-ui-qml/touch/gpodder.qml").absoluteFilePath()));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.showFullScreen();
    return app.exec();
}
