#include "appoptions.h"

#include <QTimer>

#ifndef QT_NO_SSL
#include <QSslCertificate>
#include <QSslSocket>
#include <QSslConfiguration>
#endif

AppOptions::AppOptions(QObject *parent) :
    QObject(parent)
{
    QMetaObject::invokeMethod(this, "reloadSettings", Qt::QueuedConnection);
}

void AppOptions::reloadSettings()
{
    auto sslCert = property("sslCertificate").toString();
    if (sslCert.length())
    {
#ifndef QT_NO_SSL
        QSslCertificate cert(sslCert.toUtf8());
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))
        QSslSocket::addDefaultCaCertificate(cert);
#endif
        QSslConfiguration configs = QSslConfiguration::defaultConfiguration();
        configs.setCaCertificates({cert});
#if QT_CONFIG(dtls) || defined(Q_CLANG_QDOC)
        QSslConfiguration::setDefaultDtlsConfiguration(configs);
#endif
        QSslConfiguration::setDefaultConfiguration(configs);
#endif
    }
}

AppOptions::~AppOptions()
{

}
