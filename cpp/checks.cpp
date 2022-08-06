#include "checks.h"

#include <QDialog>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QCheckBox>
#include <QDialogButtonBox>
#include <QDir>
#include <QCoreApplication>
#include <QSettings>
#include <QAsemanApplication>
#include <QPixmap>
#include <QProcess>
#include <QMessageBox>
#include <QDebug>
#include <QRegExp>

void Checks::checkLinuxDesktopIcon()
{
    auto exePath = qApp->applicationFilePath();
    if (qEnvironmentVariableIsSet("APPIMAGE"))
        exePath = qEnvironmentVariable("APPIMAGE");

    QSettings settings(QAsemanApplication::homePath() + "/checks.ini", QSettings::IniFormat);
    if (settings.value("PreventLinuxDesktopWarn").toString() == exePath)
        return;

    const auto desktops = QDir(qApp->applicationDirPath()).entryList({"*.desktop"}, QDir::Files);
    if (desktops.count() != 1)
        return;

    const auto pngs = QDir(qApp->applicationDirPath()).entryList({"*.png"}, QDir::Files);
    if (pngs.count() != 1)
        return;

    auto check = new QCheckBox(QDialog::tr("Do not ask again"));
    auto label = new QLabel(QDialog::tr("Do you want to install application shortcut to the main meny?"));

    auto labelLayout = new QVBoxLayout;
    labelLayout->addWidget(label);
    labelLayout->addWidget(check);
    labelLayout->setSpacing(0);

    auto icon = new QLabel();
    icon->setPixmap(QPixmap(":/app/files/dialog-information.png").scaledToWidth(64, Qt::SmoothTransformation));

    auto centerLayout = new QHBoxLayout;
    centerLayout->addWidget(icon);
    centerLayout->addLayout(labelLayout);

    auto buttons = new QDialogButtonBox(QDialogButtonBox::Yes | QDialogButtonBox::No);

    auto layout = new QVBoxLayout;
    layout->addLayout(centerLayout);
    layout->addWidget(buttons);

    QDialog dialog;
    dialog.setLayout(layout);
    dialog.setWindowTitle(QDialog::tr("Shortcut"));
    dialog.connect(buttons, &QDialogButtonBox::accepted, &dialog, &QDialog::accept);
    dialog.connect(buttons, &QDialogButtonBox::rejected, &dialog, &QDialog::reject);
    dialog.connect(&dialog, &QDialog::accepted, [&](){
        auto app_install_path = QDir::homePath() + "/.local/share/applications/";
        auto icon_install_path = QDir::homePath() + "/.local/share/icons/";

        QDir().mkpath(app_install_path);
        QDir().mkpath(icon_install_path);

        QFile::remove(app_install_path + '/' + desktops.first());
        QFile::remove(icon_install_path + '/' + pngs.first());

        QFile f_in(qApp->applicationDirPath() + '/' + desktops.first());
        QFile f_out(app_install_path + '/' + desktops.first());
        if (QFile::copy(qApp->applicationDirPath() + '/' + pngs.first(), icon_install_path + '/' + pngs.first())
            && f_in.open(QFile::ReadOnly) && f_out.open(QFile::WriteOnly))
        {
            QMap<QString, QString> entries;
            entries["StartupNotify"] = "true";
            entries["Type"] = "Application";
            entries["Version"] = "1.0";
            entries["Exec"] = exePath + " --no-check-desktop-installation";
            entries["Icon"] = QString(pngs.first()).remove(".png");

            auto data = QString::fromUtf8(f_in.readAll());
            for (const auto &[k, v]: entries.toStdMap())
            {
                QRegExp rx(k + "=.+\\n");
                rx.setMinimal(true);

                data.remove(rx);
                data += k + "=" + v + "\n";
            }

            f_out.write(data.toUtf8());

            f_in.close();
            f_out.close();
        }
        else
        {
            QMessageBox::critical(Q_NULLPTR, QDialog::tr("Shortcut"), QDialog::tr("Failed to install application shortcut"));
            return;
        }

        QProcess::startDetached("update-icon-caches", {icon_install_path});
        QProcess::startDetached("xdg-desktop-menu", {"forceupdate", "--mode", "user"});

        settings.setValue("PreventLinuxDesktopWarn", exePath);
    });
    dialog.connect(&dialog, &QDialog::rejected, [&](){
        if (check->isChecked())
            settings.setValue("PreventLinuxDesktopWarn", exePath);
    });

    dialog.exec();
}
