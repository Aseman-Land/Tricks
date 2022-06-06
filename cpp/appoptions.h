#ifndef APPOPTIONS_H
#define APPOPTIONS_H

#include <QObject>

class AppOptions : public QObject
{
    Q_OBJECT
public:
    AppOptions(QObject *parent = Q_NULLPTR);
    virtual ~AppOptions();

private Q_SLOTS:
    void reloadSettings();
};

#endif // APPOPTIONS_H
