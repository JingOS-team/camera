/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

import QtQuick 2.0
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.15

Item {
    id:blurBackgroundView

    property var blurSourceView;
    property var parentView;
    property string backColor : "#66FFFFFF"
    property int blurX
    property int blurY
    property point blurPoint

    Rectangle{
        anchors.fill:blurBackgroundView
        radius: width/2
        color: backColor
        clip: true
    }
}
