/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

#include "camerautils.h"
#include <QDebug>
#include <kio/previewjob.h>
#include <QDir>
#include <QStandardPaths>
#include <QUrl>
#include <QSize>
#include <QPixmap>
#include <QProcess>
#include <QDBusMessage>
#include <QCoreApplication>
#include <QDBusConnection>
#define UNICODE
#include <MediaInfo/MediaInfo.h>
#include <QApplication>
//#include <KService>
//#include <KIO/ApplicationLauncherJob>

CameraUtils::CameraUtils(QObject *parent)
{
    QDir cameraDir(cameraDefaultDirPath);
    bool isExists = cameraDir.exists();
    if(!isExists){
        bool isMkPath = cameraDir.mkpath(cameraDefaultDirPath);
        qDebug()<<Q_FUNC_INFO<<"isMkPath::"<<isMkPath ;
    }
}

CameraUtils::~CameraUtils(){

}

CameraUtils *CameraUtils::instance()
{
    static CameraUtils cameraUtils;
    return &cameraUtils;
}

void CameraUtils::creatPreviewPic(QString path){

    qDebug() << Q_FUNC_INFO << " path:"<<path;
    QDir dir(m_thumbFilePath + path);

    if (!dir.exists("preview.jpg"))
    {
        int angle = 0;
        MediaInfoLib::MediaInfo MI;
        if (MI.Open(path.toStdWString())) {
            QString rotationStr = QString::fromStdWString(MI.Get(MediaInfoLib::Stream_Video, 0, __T("Rotation")));
            angle = rotationStr.toDouble();
        }
        dir.mkpath(dir.absolutePath());
        QStringList plugins;
        plugins << KIO::PreviewJob::availablePlugins();
        KFileItemList list;
        if(!path.startsWith("file://")){
            path = "file://" + path;
        }
        list.append(KFileItem(QUrl(path),  QString(), angle));

        KIO::PreviewJob *job = KIO::filePreview(list, QSize(256, 256), &plugins);
        job->setIgnoreMaximumSize(true);
        job->setScaleType(KIO::PreviewJob::ScaleType::Unscaled);
        connect(job, &KIO::PreviewJob::gotPreview, this, &CameraUtils::gotPreviewed);
    }
}

void CameraUtils::gotPreviewed(const KFileItem &item, const QPixmap &preview)
{
    QDir dir(m_thumbFilePath + item.localPath());
    dir.mkpath(dir.absolutePath());
    if(item.mode() > 0){
        QTransform tranform;
        tranform.rotate(item.mode());
        QPixmap transPix = QPixmap(preview.transformed(tranform,Qt::SmoothTransformation));
        transPix.save(dir.absolutePath()+ "/preview.jpg", "JPG");

    } else {
        preview.save(dir.absolutePath()+ "/preview.jpg", "JPG");
    }
    setVideoPreview(dir.absolutePath()+ "/preview.jpg");
}

QString  CameraUtils::lastCameraPreviewPath(){
    QDir dir(cameraDefaultDirPath);
    QStringList nameFilters;
    nameFilters <<"*";

    QFileInfoList files =  dir.entryInfoList(nameFilters,QDir::Files|QDir::Readable,QDir::Time);
    if(files.size() > 0){
        QString lastFilePath = files.at(0).absoluteFilePath();
        if(lastFilePath.endsWith(".jpg")){
            m_lastCameraPreviewPath = "file://"+lastFilePath;
        }else{
            m_lastCameraPreviewPath = "file://"+m_thumbFilePath + lastFilePath + "/preview.jpg";
            if(!QFile(m_thumbFilePath + lastFilePath + "/preview.jpg").exists()){
                m_lastCameraPreviewPath = "qrc:/assets/pic.png";
                creatPreviewPic(lastFilePath);
            }
        }
    } else {
        m_lastCameraPreviewPath = "";
    }

    return m_lastCameraPreviewPath;
}

void CameraUtils::openPhotoUrl(QString path)
{
    QProcess process(this);
    QStringList arguments;//用于传参数
    QString program = "/usr/bin/jinggallery";
    arguments << path;
    process.startDetached(program, arguments);
}

void CameraUtils::requestDbusWakeup(bool iswakup)
{
    qDebug() << Q_FUNC_INFO << "  inhibit  " << iswakup << " m_nIsInhibiting " << m_nIsInhibiting;
    if(iswakup){
        if(!m_nIsInhibiting){
            // set screen live
            QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.PowerManagement",
                                                                  "/org/freedesktop/PowerManagement/Inhibit",
                                                                  "org.freedesktop.PowerManagement.Inhibit",
                                                                  "Inhibit");

            message << QCoreApplication::applicationFilePath();
            message << "Video Wake Lock";

            QDBusMessage response = QDBusConnection::sessionBus().call(message);

            if (response.type() == QDBusMessage::ReplyMessage){
                m_nIsInhibiting = true;
                m_nInhibitCookie = response.arguments().takeFirst().toUInt();
                qDebug() << Q_FUNC_INFO  <<"dbus Inhibit cookie =" << m_nInhibitCookie;
            } else {
                m_nIsInhibiting = false;
                qDebug() << Q_FUNC_INFO << "dbus Inhibit  value method called failed! " << response.type() << response.errorMessage();
            }
        }
    } else {
        if(m_nIsInhibiting){
            //set screen normal
            QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.PowerManagement",
                                                                  "/org/freedesktop/PowerManagement/Inhibit",
                                                                  "org.freedesktop.PowerManagement.Inhibit",
                                                                  "UnInhibit");

            message << m_nInhibitCookie;

            QDBusMessage response = QDBusConnection::sessionBus().call(message);

            if (response.type() == QDBusMessage::ReplyMessage){
                qDebug() << Q_FUNC_INFO  <<"dbus UnInhibit ok";
                m_nIsInhibiting = false;
            } else {
                qDebug() << Q_FUNC_INFO << "dbus UnInhibit fail " << response.type() << response.errorMessage();
            }
        }
    }
}

void CameraUtils::setDistanceValue(int value)
{
    qDebug() << Q_FUNC_INFO << " value::" << value << " m_value:" << m_distanceValue;
    if(value == m_distanceValue) {
        return;
    }
    QApplication::setStartDragDistance(value);
    m_distanceValue = value;
}

QString CameraUtils::lastCameraFilePath(){
    QDir dir(cameraDefaultDirPath);
    QStringList nameFilters;
    nameFilters <<"*";
    QFileInfoList files =  dir.entryInfoList(nameFilters,QDir::Files|QDir::Readable,QDir::Time);
    if(files.size() > 0){
        return "file://"+files.at(0).absoluteFilePath();
    }
    return "";
}


