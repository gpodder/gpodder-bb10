#!/bin/bash
# gPodder 4 for Blackberry 10 - Packager script
# 2013-09-28 Thomas Perl <m@thp.io>

APP=gpodder-bb10

set -e

if [ "$QMAKE" = "" -o "$DEBUG_TOKEN" = "" ]; then
    cat <<EOF

    Please set these environment variables:

        QMAKE ............. Qt 5.1-for-BB10 qmake
        DEBUG_TOKEN ....... Debug token for deployment

EOF
    exit 1
fi

QT_INSTALL_LIBS=$($QMAKE -query QT_INSTALL_LIBS)
QT_INSTALL_PLUGINS=$($QMAKE -query QT_INSTALL_PLUGINS)
QT_INSTALL_QML=$($QMAKE -query QT_INSTALL_QML)

$QMAKE
make $APP

blackberry-nativepackager \
    -package ${APP}.bar \
    -devMode \
    -debugToken ${DEBUG_TOKEN} \
    bar-descriptor.xml \
    $APP \
    ${APP}.png \
    -e gpodder-ui-qml/index.qml gpodder-ui-qml/index.qml \
    -e gpodder-ui-qml/qml gpodder-ui-qml/qml/ \
    -e gpodder-ui-qml/main.py gpodder-ui-qml/main.py \
    $(for file in gpodder-core/src/*; do echo "-e $file gpodder-ui-qml/$(basename $file)"; done) \
    $(for file in ${QT_INSTALL_LIBS}/libQt5*.so.5; do echo "-e $file lib/$(basename $file)"; done) \
    -e ${QT_INSTALL_PLUGINS} plugins/ \
    -e ${QT_INSTALL_QML} qml/

