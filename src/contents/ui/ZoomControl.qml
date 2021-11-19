

/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
**               2020 Zhang He Gang <zhanghegang@jingos.com>
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/
import QtQuick 2.0
import org.kde.kirigami 2.15 as Kirigami
import QtMultimedia 5.0
import QtQuick.Controls 2.15

Item {
    id: zoomControl

    property real currentZoom: 1
    property real maximumZoom: 1
    property real minimumZoom: 1
    property int minCircle: 23 * appScaleSize

    signal zoomTo(real value)

    onVisibleChanged: {
        if (visible && !hideTimer.running) {
            hideTimer.start()
        }
    }

    function managerTimer(isStop) {
        if (hideTimer.running & isStop) {
            hideTimer.stop()
        } else {
            hideTimer.stop()
            hideTimer.start()
        }
    }

    Timer {
        id: hideTimer
        interval: 4000
        onTriggered: visible = false
    }

    Rectangle {
        id: maxTip
        width: minCircle
        height: width
        color: "transparent"
        anchors {
            bottom: sliderView.top
            bottomMargin: 10 * appScaleSize
            horizontalCenter: parent.horizontalCenter
        }

        BlurBackgroundView {
            id: maxTipBlurBackground
            anchors.fill: parent
            blurSourceView: viewfinder
            parentView: zoomControl
            blurX: maxTip.x
            blurY: maxTip.y
        }

        Text {
            id: maxText
            anchors.centerIn: parent
            text: qsTr(maximumZoom + "X")
            font.pixelSize: (defaultFontSize - 4) * appFontSize
            color: "white"
        }
    }

    Slider {
        id: sliderView

        property int playPosition

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            margins: 0
        }
        width: zoomControl.width
        height: zoomControl.height / 3
        orientation: Qt.Vertical
        from: minimumZoom
        to: maximumZoom
        value: currentZoom
        background: Rectangle {
            width: implicitWidth
            height: sliderView.availableHeight
            x: sliderView.leftPadding + sliderView.availableWidth / 2 - width / 2
            y: sliderView.topPadding + sliderView.availableHeight / 2 - height / 2
            implicitWidth: 4 * appScaleSize
            implicitHeight: parent.height
            radius: height / 2
            color: "#66FFFFFF"

            Rectangle {
                width: parent.width
                height: (1 - sliderView.visualPosition) * parent.height
                anchors.bottom: parent.bottom
                color: "#F2FFFFFF"
                radius: width / 2
            }
        }

        handle: Rectangle {
            x: sliderView.leftPadding + sliderView.availableWidth / 2 - width / 2
            y: sliderView.topPadding + sliderView.visualPosition
               * (sliderView.availableHeight - height)
            color: "#FFFFFF"
            border.width: 0
            implicitWidth: minCircle - 3 * appScaleSize
            implicitHeight: minCircle - 3 * appScaleSize
            radius: height / 2
        }

        onMoved: {
            zoomControl.zoomTo(value)
            managerTimer(false)
        }
        onHoveredChanged: {
            managerTimer(hovered)
        }
    }

    Rectangle {
        id: minTip
        width: minCircle
        height: width
        color: "transparent"
        anchors {
            top: sliderView.bottom
            topMargin: 10 * appScaleSize
            horizontalCenter: parent.horizontalCenter
        }
        BlurBackgroundView {
            id: miniTipBlurBackground
            anchors.fill: parent
            blurSourceView: viewfinder
            parentView: zoomControl
            blurX: minTip.x
            blurY: minTip.y
        }
        Text {
            id: miniText
            anchors.centerIn: parent
            text: qsTr("1X")
            font.pixelSize: (defaultFontSize - 4) * appFontSize
            color: "white"
        }
    }
}
