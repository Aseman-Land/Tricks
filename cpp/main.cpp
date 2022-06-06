#include <QApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QAsemanCoreVersion>

#include "appoptions.h"
#include "trickstools.h"

#ifndef APP_SECRET_ID
#include APP_SECRET_ID_INCLUDE
#endif

static QObject *create_trickstoole_singleton(QQmlEngine *, QJSEngine *)
{
    return new TricksTools;
}

int main(int argc, char *argv[])
{
    qputenv("QT_ANDROID_ENABLE_WORKAROUND_TO_DISABLE_PREDICTIVE_TEXT", "1");
    qputenv("QT_LOGGING_RULES", "qt.qml.connections=false");

#if !defined(Q_OS_LINUX) || defined(Q_OS_ANDROID)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
#if (QT_VERSION >= QT_VERSION_CHECK(5, 14, 0))
#ifdef Q_OS_ANDROID
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::Ceil);
#endif
#endif

    qmlRegisterType<AppOptions>("Tricks", 1, 0, "AppOptions");
    qmlRegisterSingletonType<TricksTools>("Tricks", 1, 0, "TricksTools", create_trickstoole_singleton);
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || (defined(Q_OS_LINUX) && defined(QT_DEBUG))
    qmlRegisterType(QUrl("qrc:/imports/components/TScrollViewMobile.qml"), "components", 1, 0, "TScrollView");
#elif defined(Q_OS_MACOS)
    qmlRegisterType(QUrl("qrc:/imports/components/TScrollViewDesktopClassic.qml"), "components", 1, 0, "TScrollView");
#else
    qmlRegisterType(QUrl("qrc:/imports/components/TScrollViewDesktop.qml"), "components", 1, 0, "TScrollView");
#endif

#ifdef QTFIREBASE_SUPPORT
    const auto qtFirebase = true;
    const QString qtFirebaseVersion = QTFIREBASE_VERSION;
#else
    const auto qtFirebase = false;
    const QString qtFirebaseVersion;
#endif

    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/imports/globals/logo.png"));

    QQmlApplicationEngine engine;
    engine.addImportPath(":/imports/");
    engine.rootContext()->setContextProperty("appBundleVersion", APP_BUNDLE_VERSION);
    engine.rootContext()->setContextProperty("appVersion", APP_VERSION);
    engine.rootContext()->setContextProperty("appUniqueId", APP_UNIQUEID);
    engine.rootContext()->setContextProperty("appDomain", APP_DOMAIN);
    engine.rootContext()->setContextProperty("appSecretId", APP_SECRET_ID);
    engine.rootContext()->setContextProperty("qtFirebase", qtFirebase);
    engine.rootContext()->setContextProperty("qtFirebaseVersion", qtFirebaseVersion);
    engine.rootContext()->setContextProperty("qtAsemanVersion", QASEMANCORE_VERSION_STR);
    engine.rootContext()->setContextProperty("qtVersion", qVersion());
    engine.rootContext()->setContextProperty("testMode", false);
    engine.rootContext()->setContextProperty("isAndroidStyle", false);
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
