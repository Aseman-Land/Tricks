#include "iosmanager.h"

#include <QUrl>
#include <QDesktopServices>
#include <QDebug>
#include <QTimer>
#include <QEventLoop>

#import <SafariServices/SafariServices.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

bool IOSManager::openUrlInSafari(const QString &str)
{
    auto url = QUrl(str).toNSURL();

    if ([SFSafariViewController class]) {

        QEventLoop loop;

        UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL:url];
        [controller presentViewController:viewController animated:YES completion: nil];

        auto t = new QTimer;
        t->connect(t, &QTimer::timeout, [&](){
            if (viewController.beingDismissed)
                loop.exit();
        });
        t->start(100);

        loop.exec();

        delete t;
        return true;
    } else {
        return false;
    }
}
