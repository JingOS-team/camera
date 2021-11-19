/****************************************************************************
**
** Copyright (C) 2018 Jonah Brüchert
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
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

import org.kde.kirigami 2.15 as Kirigami
import QtQuick 2.7
import QtMultimedia 5.8

import org.kde.plasmacamera 1.0

Kirigami.GlobalDrawer {
    id: drawer
    property var camera

    Component {
        id: devicesSubAction

        Kirigami.Action {
            property string value
            checked: value === CameraSettings.cameraDeviceId

            onTriggered: {
                CameraSettings.cameraDeviceId = value
            }
        }
    }

    Component {
        id: resolutionSubAction

        Kirigami.Action {
            property size value
            checked: value === CameraSettings.resolution

            onTriggered: {
                CameraSettings.resolution = value
            }
        }
    }

    actions: [
        Kirigami.Action {
            id: devicesAction
            text: i18n("Camera")
            iconName: "camera-photo-symbolic"
            Component.onCompleted: {
                var cameras = QtMultimedia.availableCameras
                var childrenList = []

                for (var i in cameras) {
                    childrenList[i] = devicesSubAction.createObject(devicesAction, {
                        value: cameras[i].deviceId,
                        text: "%1".arg(cameras[i].displayName)
                    })
                }
                devicesAction.children = childrenList
            }
        },
        Kirigami.Action {
            id: resolutionAction
            text: i18n("Resolution")
            iconName: "ratiocrop"
            Component.onCompleted: {
                var resolutions = drawer.camera.imageCapture.supportedResolutions
                var childrenList = []

                for (var i in resolutions) {
                    var pixels = resolutions[i].width * resolutions[i].height
                    var megapixels = Math.round(pixels / 10000) / 100

                    childrenList[i] = resolutionSubAction.createObject(resolutionAction, {
                        value: resolutions[i],
                        text: "%1 x %2 (%3 MP)".arg(resolutions[i].width).arg(resolutions[i].height).arg(megapixels)
                    })
                }
                resolutionAction.children = childrenList
            }
        },
        Kirigami.Action {
            id: wbaction
            text: i18n("White balance")
            iconName: "whitebalance"
            Kirigami.Action {
                iconName: "qrc:/assets/camera_auto_mode.png"
                onTriggered: CameraSettings.whiteBalanceMode = CameraImageProcessing.WhiteBalanceAuto
                text: i18n("Auto")
                checked: CameraSettings.whiteBalanceMode === CameraImageProcessing.WhiteBalanceAuto
            }
            Kirigami.Action {
                iconName: "qrc:/assets/camera_white_balance_sunny.png"
                onTriggered: CameraSettings.whiteBalanceMode = CameraImageProcessing.WhiteBalanceSunlight
                text: i18n("Sunlight")
                checked: CameraSettings.whiteBalanceMode === CameraImageProcessing.WhiteBalanceSunlight
            }
            Kirigami.Action {
                iconName: "qrc:/assets/camera_white_balance_cloudy.png"
                onTriggered: CameraSettings.whiteBalanceMode = CameraImageProcessing.WhiteBalanceCloudy
                text: i18n("Cloudy")
                checked: CameraSettings.whiteBalanceMode === CameraImageProcessing.WhiteBalanceCloudy
            }
            Kirigami.Action {
                iconName: "qrc:/assets/camera_white_balance_incandescent.png"
                onTriggered: CameraSettings.whiteBalanceMode = CameraImageProcessing.WhiteBalanceTungsten
                text: i18n("Tungsten")
                checked: CameraSettings.whiteBalanceMode === CameraImageProcessing.WhiteBalanceTungsten
            }
            Kirigami.Action {
                iconName: "qrc:/assets/camera_white_balance_flourescent.png"
                onTriggered: CameraSettings.whiteBalanceMode = CameraImageProcessing.WhiteBalanceFluorescent
                text: i18n("Fluorescent")
                checked: CameraSettings.whiteBalanceMode === CameraImageProcessing.WhiteBalanceFluorescent
            }
        },
        Kirigami.Action {
            text: i18n("Self-timer")
            iconName: "clock"
            enabled: !camera.selfTimerRunning

            Kirigami.Action {
                text: i18n("Off")
                onTriggered: camera.selfTimerDuration = 0
                checked: camera.selfTimerDuration === 0
            }
            Kirigami.Action {
                text: i18n("2 s")
                onTriggered: camera.selfTimerDuration = 2
                checked: camera.selfTimerDuration === 2
            }
            Kirigami.Action {
                text: i18n("5 s")
                onTriggered: camera.selfTimerDuration = 5
                checked: camera.selfTimerDuration === 5
            }
            Kirigami.Action {
                text: i18n("10 s")
                onTriggered: camera.selfTimerDuration = 10
                checked: camera.selfTimerDuration === 10
            }
            Kirigami.Action {
                text: i18n("20 s")
                onTriggered: camera.selfTimerDuration = 20
                checked: camera.selfTimerDuration === 20
            }
        },
        Kirigami.Action {
            text: i18n("About")
            iconName: "help-about"
            onTriggered: {
                while (pageStack.depth > 1)
                    pageStack.pop()

                pageStack.push(aboutPage)
            }
        }
    ]
}
