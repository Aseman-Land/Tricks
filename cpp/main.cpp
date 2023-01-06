#include <QApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QAsemanCoreVersion>
#include <QQuickStyle>
#include <QFontDatabase>

#include "appoptions.h"
#include "trickstools.h"
#include "checks.h"
#include "systemcolors.h"

#ifdef QZXING_AVAILABLE
#include "QZXing.h"
#endif

#if !defined(APP_SECRET_ID) && defined(APP_SECRET_ID_INCLUDE)
#include APP_SECRET_ID_INCLUDE
#else
#define APP_SECRET_ID ""
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

#if (QT_VERSION >= QT_VERSION_CHECK(6, 0, 0))
    QQuickStyle::setStyle("QtQuick.Controls.IOSStyle");
#else
    QQuickStyle::setStyle("IOSStyle");
#endif

    qmlRegisterType<AppOptions>("Tricks", 1, 0, "AppOptions");
    qmlRegisterType<SystemColors>("Tricks", 1, 0, "SystemColors");
    qmlRegisterSingletonType<TricksTools>("Tricks", 1, 0, "TricksTools", create_trickstoole_singleton);
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
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
    app.setApplicationName("Tricks");
    app.setWindowIcon(QIcon(":/imports/globals/logo.png"));

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    if (!app.arguments().contains("--no-check-desktop-installation"))
        Checks::checkLinuxDesktopIcon();
#endif

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
    engine.rootContext()->setContextProperty("defaultLightHeader", SystemColors::defaultLightHeader());

    auto qzxing = false;

#ifdef QZXING_AVAILABLE
    QZXing::registerQMLTypes();
    QZXing::registerQMLImageProvider(engine);
    qzxing = true;
#endif

    engine.rootContext()->setContextProperty("qzxing", qzxing);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
