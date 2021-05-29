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

    QString cameraDefaultPath() {
//        QString suffix = ".jpg";
//        int cur = 0;
//        QString newFilePath = cameraDefaultDirPath+"/IMG_";
//        QFileInfo check(m_cameraDefaultPath);
//        while (check.exists()) {
//            m_cameraDefaultPath = QString("%1%2%3").arg(newFilePath, QString::number(cur), suffix);
//            check = QFileInfo(m_cameraDefaultPath);
//            cur++;
//        }
        return cameraDefaultDirPath;
    }

    QString videoPath() {
//        QString suffix = ".mp4";
//        int cur = 0;
//        QString newFilePath = cameraDefaultDirPath+"/VIDEO_";
//        QFileInfo check(m_videoPath);
//        while (check.exists()) {
//            m_videoPath = QString("%1%2%3").arg(newFilePath, QString::number(cur), suffix);
//            check = QFileInfo(m_videoPath);
//            cur++;
//        }
        return cameraDefaultDirPath;
    }

    QString lastCameraPreviewPath();
    QString lastCameraFilePath();

    void setCameraDefaultPath(QString path) {
        m_cameraDefaultPath = path;
        emit cameraDefaultPathChanged();
    }

    QString videoPreview() {
        return m_path;
    }
    void setVideoPreview(QString path) {
        m_path = path;
        emit videoPreviewChanged();
    }
private:
    QString m_path;
    QString m_cameraDefaultPath;
    QString m_videoPath;
    QString m_lastCameraPreviewPath;
public:
    QString cameraDefaultDirPath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + "/camera";
signals:
    void videoPreviewChanged();
    void cameraDefaultPathChanged();
    void videoPathChanged();
    void lastCameraPreviewPathChanged();
    void lastCameraFilePathChanged();

protected Q_SLOTS:
    void gotPreviewed(const KFileItem &item, const QPixmap &preview);

};

#endif // CAMERAUTILS_H
