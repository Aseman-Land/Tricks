
exists($$PWD/qzxing/src/QZXing.pri) {
    CONFIG += qzxing_qml enable_encoder_qr_code
    DEFINES += QZXING_AVAILABLE
    include(qzxing/src/QZXing.pri)
}
