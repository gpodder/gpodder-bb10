#!/bin/bash
# gPodder 4 for Blackberry 10 and Playbook
# 2014-10-26 Thomas Perl <m@thp.io>
# Based on BB10 script: 2013-09-28 Thomas Perl <m@thp.io>

APP=gpodder-bb10
QT_VERSION=5.1.1
TARGETS="playbook bb10"

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 </path/to/keystore/files/>" 1>&2
    exit 1
fi

KEYSTORE_ROOT="$1"

# Files required in the keystore for signing
KEYSTORE_FILES="
author.p12
barsigner.csk
barsigner.db
"

# Directory where tools expect the keystore file
KEYSTORE_HOME=$HOME/.rim

# Hand-picked list of Qt libraries we don't need to ship
QT_LIBS_BLACKLIST="
libQt5MultimediaWidgets.so.5
libQt5Widgets.so.5
libQt5Test.so.5
libQt5QuickTest.so.5
libQt5QuickParticles.so.5
libQt5PrintSupport.so.5
"

find_qt_libs() {
    QT_INSTALL_LIBS=$1
    for file in $QT_INSTALL_LIBS/libQt5*.so.5; do
        QT_LIB_BASENAME=$(basename $file)
        case "$QT_LIBS_BLACKLIST" in
            *${QT_LIB_BASENAME}*)
                echo "Not packaging blacklisted Qt library: $file" 1>&2
                ;;
            *)
		echo "-e $file lib/$(basename $file)"
                ;;
        esac
    done
}

build_package() {
    echo "Running blackberry-nativepackager"
    blackberry-nativepackager \
	"$@" \
	${BAR_DESCRIPTOR} \
	$APP \
	${APP}.png \
	-e gpodder-ui-qml/touch gpodder-ui-qml/touch/ \
	-e gpodder-ui-qml/main.py gpodder-ui-qml/main.py \
	-e podcastparser/podcastparser.py gpodder-ui-qml/podcastparser.py \
        -e gpodder-core/src/gpodder gpodder-ui-qml/gpodder \
        $(find_qt_libs $QT_INSTALL_LIBS) \
	-e ${QT_INSTALL_PLUGINS} plugins/ \
	-e ${QT_INSTALL_QML} qml/
}

build_target() {
    TARGET=$1

    case $TARGET in
        playbook)
            . /opt/bbndk/bbndk-env.sh
            ;;
        bb10)
            . /opt/bb10ndk/bb10ndk-env.sh
            ;;
        *)
            echo "Invalid/unknown target: $TARGET" 1>&2
            exit 1
            ;;
    esac

    QMAKE=/opt/qt5-target-${TARGET}-${QT_VERSION}/bin/qmake

    QT_INSTALL_LIBS=$($QMAKE -query QT_INSTALL_LIBS)
    QT_INSTALL_PLUGINS=$($QMAKE -query QT_INSTALL_PLUGINS)
    QT_INSTALL_QML=$($QMAKE -query QT_INSTALL_QML)

    BAR_DESCRIPTOR=bar-descriptor.${TARGET}.xml
    BAR_VERSION=$(python tools/getversion.py $BAR_DESCRIPTOR)

    echo "Cleaning up build environment"
    make distclean || true
    echo "Running qmake"
    $QMAKE
    echo "Building application binary"
    make $APP

    DEBUG_TOKEN="$KEYSTORE_ROOT/debugtoken.bar"
    if [ -f "$DEBUG_TOKEN" ]; then
        echo "Building debug package with debug token $DEBUG_TOKEN"
	BAR=gpodder-${BAR_VERSION}-${TARGET}-debug.bar
	build_package -package $BAR -devMode -debugToken ${DEBUG_TOKEN}
    fi

    if [ -f "$KEYSTORE_ROOT/password.txt" \
         -a -f "$KEYSTORE_HOME/author.p12" \
         -a -f "$KEYSTORE_HOME/barsigner.csk" \
         -a -f "$KEYSTORE_HOME/barsigner.db" ]; then
        echo "Building release package"
        BAR=gpodder-${BAR_VERSION}-${TARGET}-release.bar

        build_package -package $BAR

        echo "Running blackberry-signer"
	blackberry-signer -storepass "$(cat $KEYSTORE_ROOT/password.txt)" $BAR
    fi
}

# Deploy signing files
mkdir -p $KEYSTORE_HOME
for keystore_file in $KEYSTORE_FILES; do
keystore_src="$KEYSTORE_ROOT/$keystore_file"
keystore_dst="$KEYSTORE_HOME/$keystore_file"
if [ -f "$keystore_src" -a ! -f "$keystore_dst" ]; then
    cp -v "$keystore_src" "$keystore_dst"
fi
done

for TARGET in $TARGETS; do
    build_target $TARGET
done

make distclean || true
