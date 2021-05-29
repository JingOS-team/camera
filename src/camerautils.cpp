#include "camerautils.h"
#include <QDebug>
#include <kio/previewjob.h>
#include <QDir>
#include <QStandardPaths>
#include <QUrl>
#include <QSize>
#include <QPixmap>

CameraUtils::CameraUtils(QObject *parent)
{
    QDir cameraDir(cameraDefaultDirPath);
    bool isExists = cameraDir.exists();
    if (!isExists) {
        bool isMkPath = cameraDir.mkpath(cameraDefaultDirPath);
    }
}

CameraUtils::~CameraUtils() {

}

CameraUtils *CameraUtils::instance()
{
    static CameraUtils cameraUtils;
    return &cameraUtils;
}

void CameraUtils::creatPreviewPic(QString path) {

    QDir dir(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + path);

    if (!dir.exists("preview.jpg"))
    {
        dir.mkpath(dir.absolutePath());
        QStringList plugins;
        plugins << KIO::PreviewJob::availablePlugins();
        KFileItemList list;
        if (!path.startsWith("file://")) {
            path = "file://" + path;
        }
        list.append(KFileItem(QUrl(path),  QString(), 0));

        KIO::PreviewJob *job = KIO::filePreview(list, QSize(256, 256), &plugins);
        job->setIgnoreMaximumSize(true);
        job->setScaleType(KIO::PreviewJob::ScaleType::Unscaled);
        connect(job, &KIO::PreviewJob::gotPreview, this, &CameraUtils::gotPreviewed);
    }
}

void CameraUtils::gotPreviewed(const KFileItem &item, const QPixmap &preview)
{
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + item.localPath());
    dir.mkpath(dir.absolutePath());
    preview.save(dir.absolutePath()+ "/preview.jpg", "JPG");
    setVideoPreview(dir.absolutePath()+ "/preview.jpg");
}

QString  CameraUtils::lastCameraPreviewPath() {
    QDir dir(cameraDefaultDirPath);
    QStringList nameFilters;
    nameFilters <<"*";

//    nameFilters <<"*.mp4"<<"*.jpg"<<"*.mov"<<"*.webm"<<".png";
    QFileInfoList files =  dir.entryInfoList(nameFilters,QDir::Files|QDir::Readable,QDir::Time);
    if (files.size() > 0) {
        QString lastFilePath = files.at(0).absoluteFilePath();
        if (lastFilePath.endsWith(".jpg")) {
            m_lastCameraPreviewPath = "file://"+lastFilePath;
        } else {
            m_lastCameraPreviewPath = "file://"+QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + lastFilePath + "/preview.jpg";
        }
    }

    return m_lastCameraPreviewPath;
}

QString CameraUtils::lastCameraFilePath() {
    QDir dir(cameraDefaultDirPath);
    QStringList nameFilters;
    nameFilters <<"*";
    QFileInfoList files =  dir.entryInfoList(nameFilters,QDir::Files|QDir::Readable,QDir::Time);
    if (files.size() > 0) {
        return "file://"+files.at(0).absoluteFilePath();
    }
    return "";
}


