/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

#ifndef CAMERAPHOTOSMODEL_H
#define CAMERAPHOTOSMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QStandardPaths>

class CameraPhotosModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit CameraPhotosModel(QObject *parent = nullptr);
    static CameraPhotosModel *instance();
    enum Roles { MediaUrlRole = Qt::UserRole + 1, MimeTypeRole, Thumbnail, ThumbnailPixmap, PreviewUrlRole, DurationRole, ItemTypeRole, FilesRole, FileCountRole, DateRole, SelectedRole, SourceIndex, DateTimeRole,MediaTypeRole };

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    bool is24HourFormat() const;
    Q_INVOKABLE bool loadCameraPath();
    Q_INVOKABLE int dataSize();
    Q_INVOKABLE bool removePhotoFile(int index,QString path);

private:
    QList<QString> m_medias;
    QString cameraDefaultDirPath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + "/camera";

signals:

};

#endif // CAMERAPHOTOSMODEL_H
