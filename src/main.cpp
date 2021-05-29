// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QIcon>

#include <KAboutData>
#include <KLocalizedString>
#include <KLocalizedContext>

#include "plasmacamera.h"
#include "camerasettings.h"
#include "camerautils.h"

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#endif

constexpr auto URI = "org.kde.plasmacamera";

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    app.setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QCoreApplication::setOrganizationName("KDE");
    QCoreApplication::setOrganizationDomain("kde.org");
    QCoreApplication::setApplicationName("camera");
    QGuiApplication::setApplicationDisplayName("Camera");
    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("camera-photo")));

    KAboutData about(app.applicationName(), app.applicationDisplayName(), app.applicationVersion(), QString(),
                     KAboutLicense::GPL, i18n("© Plasma Mobile Developers"), QString());

    about.addAuthor(i18n("Marco Martin"), QString(), QStringLiteral("mart@kde.org"), QStringLiteral("https://notmart.org"));
    about.addAuthor(i18n("Jonah Brüchert"), QString(), QStringLiteral("jbb@kaidan.im"), QStringLiteral("https://jbbgameich.github.io"));
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

#ifdef Q_OS_ANDROID
    QtAndroid::requestPermissionsSync({"android.permission.CAMERA"});
#endif

    QQmlApplicationEngine engine;

    PlasmaCamera plasmaCamera;
    plasmaCamera.setAboutData(about);


    qmlRegisterSingletonInstance<PlasmaCamera>(URI, 1, 0, "PlasmaCamera", &plasmaCamera);
    qmlRegisterSingletonInstance<CameraSettings>(URI, 1, 0, "CameraSettings", CameraSettings::self());

    QObject::connect(QApplication::instance(), &QCoreApplication::aboutToQuit, QApplication::instance(), [] {
        CameraSettings::self()->save();
    });

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.rootContext()->setContextProperty("CameraUtils",CameraUtils::instance());



    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
