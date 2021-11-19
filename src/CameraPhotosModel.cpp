/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

#include "CameraPhotosModel.h"
#include <QDateTime>
#include <QMimeDatabase>
#include <QMimeType>
#include <QFileInfo>
#include <KLocalizedString>
#define FORMAT24H "HH:mm:ss"
#define FORMAT12H "h:mm:ss ap"
#include <KSharedConfig>
#include <KConfigGroup>
#include <QDir>
#include <QDebug>
CameraPhotosModel::CameraPhotosModel(QObject *parent)
    : QAbstractListModel(parent)
{
    loadCameraPath();
}

CameraPhotosModel *CameraPhotosModel::instance()
{
    static CameraPhotosModel cameraPhotosModel;
    return &cameraPhotosModel;
}

QHash<int, QByteArray> CameraPhotosModel::roleNames() const
{
    auto hash = QAbstractItemModel::roleNames();
    // the url role returns the url of the cover image of the collection
    hash.insert(Roles::MediaUrlRole, "mediaurl");
    hash.insert(Roles::MimeTypeRole, "mimeType");
    hash.insert(Roles::DateTimeRole, "imageTime");
    hash.insert(Roles::PreviewUrlRole, "previewurl");
    hash.insert(Roles::MediaTypeRole, "mediaType");
    return hash;
}

QVariant CameraPhotosModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }
    int indexValue = index.row();
    switch (role) {

    case Roles::MediaUrlRole: {
        return m_medias.at(indexValue);
    }
    case Roles::PreviewUrlRole:{
        return m_medias.at(indexValue);
    }
    case Roles::DateTimeRole:
    {
        QString dateString;
        QDateTime currentDate =  QDateTime::currentDateTime();
        QString filePath = m_medias.at(indexValue);
        if(filePath.startsWith("file://")){
            filePath = filePath.mid(7);
        }
        QDateTime qdate = QFileInfo(filePath).lastModified();
        int dayoffset = qdate.daysTo(currentDate);
        bool getLocalTimeIs24 = is24HourFormat();
        QString currentDayString = getLocalTimeIs24 ? "hh:mm" : (QLatin1String("hh:mm") + " AP");

        if (dayoffset <= 7) {
            if (dayoffset < 1) {
                dateString = qdate.toString(currentDayString);
            } else if (dayoffset == 1) {
                dateString = i18n("yestday ")+ qdate.toString(currentDayString);
            } else {
                dateString =  qdate.toString("dddd " + currentDayString);
            }
        } else {
            int currentYear = currentDate.date().year();
            int dataYear = qdate.date().year();
            if (currentYear == dataYear) {
                dateString = qdate.toString("MM-dd " + currentDayString);
            } else {
                dateString = qdate.toString("yyyy-MM-dd " + currentDayString);

            }
        }
        qDebug()<<Q_FUNC_INFO << " timedate::" << dateString << " path:" << m_medias.at(indexValue)
               << " qdate::" <<qdate;
        return dateString;
    }
    case Roles::MimeTypeRole: {
        QMimeDatabase db;
        QMimeType type = db.mimeTypeForFile(m_medias.at(indexValue));
        return type.name();
    }
    case Roles::MediaTypeRole: {
        QMimeDatabase db;
        QMimeType type = db.mimeTypeForFile(m_medias.at(indexValue));
        int typeInt = 0;
        if(type.name().startsWith("image/")){
            typeInt = 0;
        } else if(type.name().startsWith("video/")){
            typeInt = 1;
        }
        return typeInt;
    }
    }
    return QVariant();
}

int CameraPhotosModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_medias.size();
}

bool CameraPhotosModel::is24HourFormat() const
{
    KSharedConfig::Ptr  m_localeConfig = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig);
    KConfigGroup  m_localeSettings = KConfigGroup(m_localeConfig, "Locale");

    QString m_currentLocalTime  =  m_localeSettings.readEntry("TimeFormat", QStringLiteral(FORMAT24H));
    return (m_currentLocalTime == FORMAT24H) ;
}

bool CameraPhotosModel::loadCameraPath()
{
    bool result = true;
    QDir dir(cameraDefaultDirPath);
    QStringList nameFilters;
    nameFilters <<"*";
    QFileInfoList files =  dir.entryInfoList(nameFilters,QDir::Files|QDir::Readable,QDir::Time | QDir::Reversed);
    m_medias.clear();
    foreach(auto file,files){
        m_medias.append("file://" + file.absoluteFilePath());
    }
    return result;
}

int CameraPhotosModel::dataSize()
{
    return m_medias.size();
}

bool CameraPhotosModel::removePhotoFile(int index,QString path)
{
    if(path.startsWith("file://")){
        path = path.mid(7);
    }
    bool dResult = QFile::moveToTrash(path);
    qDebug() << Q_FUNC_INFO << " delete result:" << dResult;
    if(dResult){
        beginRemoveRows({},index,index);
        m_medias.removeAt(index);
        endRemoveRows();
    }
    return dResult;
}


