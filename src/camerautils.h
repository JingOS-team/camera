/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

#ifndef CAMERAUTILS_H
#define CAMERAUTILS_H
#include <QObject>
#include <kdirmodel.h>
#include <QDebug>
#include <QFileInfo>
#include <QDir>
#include <QStandardPaths>

class CameraUtils : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString videoPreview READ videoPreview WRITE setVideoPreview NOTIFY videoPreviewChanged)
    Q_PROPERTY(QString cameraDefaultPath READ cameraDefaultPath WRITE setCameraDefaultPath NOTIFY cameraDefaultPathChanged)
    Q_PROPERTY(QString videoPath READ videoPath NOTIFY videoPathChanged)
    Q_PROPERTY(QString lastCameraPreviewPath READ lastCameraPreviewPath NOTIFY lastCameraPreviewPathChanged)
    Q_PROPERTY(QString lastCameraFilePath READ lastCameraFilePath NOTIFY lastCameraFilePathChanged)


public:
    CameraUtils(QObject *parent = 0);
    virtual ~CameraUtils();
    static CameraUtils *instance();
    Q_INVOKABLE void creatPreviewPic(QString path);
    Q_INVOKABLE void openPhotoUrl(QString path);
    Q_INVOKABLE void requestDbusWakeup(bool iswakup);
    Q_INVOKABLE void setDistanceValue(int value);

    QString cameraDefaultPath(){
        QDir cameraDir(cameraDefaultDirPath);
        bool isExists = cameraDir.exists();
        if(!isExists){
            bool isMkPath = cameraDir.mkpath(cameraDefaultDirPath);
        }
        return cameraDefaultDirPath;
    }

    QString videoPath(){
        QDir cameraDir(cameraDefaultDirPath);
        bool isExists = cameraDir.exists();
        if(!isExists){
            bool isMkPath = cameraDir.mkpath(cameraDefaultDirPath);
        }
        return cameraDefaultDirPath;
    }

    QString lastCameraPreviewPath();
    QString lastCameraFilePath();

    void setCameraDefaultPath(QString path){
        m_cameraDefaultPath = path;
        emit cameraDefaultPathChanged();
    }

    QString videoPreview(){
        return m_path;
    }
    void setVideoPreview(QString path){
        m_path = path;
        emit videoPreviewChanged();
    }
private:
    QString m_path;
    QString m_cameraDefaultPath;
    QString m_videoPath;
    QString m_lastCameraPreviewPath;
    QString m_thumbFilePath = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + "/video_thumb";
    uint m_nInhibitCookie;
    bool m_nIsInhibiting = false;
    int m_distanceValue = 0;

public:
    QString cameraDefaultDirPath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + "/camera";
signals:
    void videoPreviewChanged();
    void cameraDefaultPathChanged();
    void videoPathChanged();
    void lastCameraPreviewPathChanged();
    void lastCameraFilePathChanged();
    void quitApp();
    void pauseApp();

protected Q_SLOTS:
    void gotPreviewed(const KFileItem &item, const QPixmap &preview);

};

#endif // CAMERAUTILS_H
