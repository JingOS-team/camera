

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
import QtQuick 2.7
import QtMultimedia 5.15
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import org.kde.plasmacamera 1.0

Kirigami.Page {
    id: cameraPage

    property var camera: mainCamera

    title: i18n("Camera")

    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0
    topPadding: 0

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None //Kirigami.Settings.isMobile ? Kirigami.ApplicationHeaderStyle.None : Kirigami.ApplicationHeaderStyle.ToolBar
    onIsCurrentPageChanged: isCurrentPage && pageStack.depth > 1
                            && pageStack.pop()
    Rectangle {
        id: cameraUI
        state: "PhotoCapture"

        anchors {
            fill: parent
            centerIn: parent
        }

        color: "black"

        states: [
            State {
                name: "PhotoCapture"
                StateChangeScript {
                    script: {
                        cameraPage.camera.captureMode = Camera.CaptureStillImage
                        cameraPage.camera.start()
                    }
                }
            },
            State {
                name: "VideoCapture"
                StateChangeScript {
                    script: {
                        cameraPage.camera.captureMode = Camera.CaptureVideo
                        cameraPage.camera.start()
                    }
                }
            }
        ]

        Kirigami.Heading {
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
            text: {
                if (cameraPage.camera.availability === Camera.Unavailable)
                    return i18n("Camera not available")
                else if (cameraPage.camera.availability === Camera.Busy)
                    return i18n("Camera is busy. Is another application using it?")
                else if (cameraPage.camera.availability === Camera.ResourceMissing)
                    return i18n("Missing camera resource.")
                else if (cameraPage.camera.availability === Camera.Available)
                    return ""
            }
        }

        Camera {
            id: mainCamera

            property int selfTimerDuration: 0 // in seconds
            property bool selfTimerRunning: false
            property double brightnessValue: 0.0 //li
            property var supportResolutions: mainCamera.imageCapture.supportedResolutions
            property var currentResolution: Qt.size(1280, 720)

            function manualFocus(x, y) {
                var normalizedPoint = viewfinder.mapPointToSourceNormalized(
                            Qt.point(x, y - viewfinder.y))
                if (normalizedPoint.x >= 0.0 && normalizedPoint.x <= 1.0
                        && normalizedPoint.y >= 0.0
                        && normalizedPoint.y <= 1.0) {
                    focusRingView.center = Qt.point(x, y)
                    focusRingView.show()
                    autoFocusTimer.restart()
                    cFocus.focusMode = Camera.FocusAuto
                    cFocus.customFocusPoint = normalizedPoint
                    cFocus.focusPointMode = Camera.FocusPointCustom
                }
            }

            function autoFocus() {
                cFocus.focusMode = Camera.FocusContinuous
                cFocus.focusPointMode = Camera.FocusPointAuto
            }

            property var autoFocusTimer: Timer {
                interval: 5000
                onTriggered: camera.autoFocus()
            }

            onCameraStateChanged: {
                if (cameraState === Camera.ActiveState) {

                }
            }

            onCameraStatusChanged: {
                if (cameraStatus === Camera.ActiveStatus) {

                }
            }

            captureMode: Camera.CaptureStillImage
            deviceId: CameraSettings.cameraDeviceId
            flash {
                id: cFlash
                mode: Camera.FlashAuto
            }
            focus {
                id: cFocus
                focusMode: Camera.FocusContinuous
                focusPointMode: Camera.FocusPointAuto
                //                customFocusPoint: Qt.point(0.5, 0.5) // Focus relative to top-left corner
            }
            imageCapture {
                id: imageCapture
                //                capturedImagePath: CameraUtils.cameraDefaultPath
                //                resolution: mainCamera.currentResolution//CameraSettings.resolution
            }

            videoRecorder {
                id: videoRecorder
               }
            imageProcessing {
                id: imageProcessing
                whiteBalanceMode: CameraSettings.whiteBalanceMode
                brightness: mainCamera.brightnessValue
            }

            onError: {
                showPassiveNotification(
                            i18n("An error occurred: \"%1\". Please consider restarting the application if it stopped working.",
                                 errorString))
            }
        }

        VideoOutput {
            id: viewfinder
            visible: cameraUI.state == "PhotoCapture"
                     || cameraUI.state == "VideoCapture"

            // Workaround
            //            orientation: Kirigami.Settings.isMobile ? -90 : 0
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop //fill screen
            flushMode: VideoOutput.LastFrame //fix black screen
            source: mainCamera //cameraPage.camera
        }

        PinchArea {
            anchors.fill: parent
            property real initialZoom
            property real minimumScale: 0.3
            property real maximumScale: 3.0
            property bool active: false

            onPinchStarted: {
                active = true
                initialZoom = cameraPage.camera.digitalZoom
            }
            onPinchUpdated: {
                var scale = cameraPage.camera.maximumDigitalZoom / 8
                        * pinch.scale - cameraPage.camera.maximumDigitalZoom / 8
                cameraPage.camera.setDigitalZoom(
                            Math.min(cameraPage.camera.maximumDigitalZoom,
                                     cameraPage.camera.digitalZoom + scale))
            }
            onPinchFinished: {
                active = false
            }
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    mainCamera.manualFocus(mouse.x, mouse.y)
                    if (cameraPage.camera.lockStatus === cameraPage.camera.Unlocked) {
                        cameraPage.camera.searchAndLock()
                    } else {
                        cameraPage.camera.unlock()
                    }
                }
            }
        }
    }

    ZoomControl {
        id: cameraDigitalZoom
        visible: false
        anchors {
            left: parent.left
            margins: Kirigami.Units.gridUnit * 2
        }
        width: Kirigami.Units.gridUnit * 2
        height: parent.height
        currentZoom: cameraPage.camera.digitalZoom
        maximumZoom: cameraPage.camera.maximumDigitalZoom //Math.min(4.0, cameraPage.camera.maximumDigitalZoom)
        onZoomTo: cameraPage.camera.setDigitalZoom(value)
    }

    CameraPageRight {
        id: cameraRight
        anchors {
            right: parent.right
            rightMargin: cameraRight.width / 2
            verticalCenter: parent.verticalCenter
        }
        width: root.height / 12
        height: parent.height * 3 / 4
        //TODO update last preview
        previewUrl: CameraUtils.lastCameraPreviewPath
        focusLengText: (Math.round(
                            cameraPage.camera.digitalZoom * 10) / 10.0).toFixed(
                           1) + "X"
        videoRecorder: camera.videoRecorder
        imageCapture: camera.imageCapture
        isCameraRecoding: camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus
        isSwitchCamera: camera.position !== Camera.UnspecifiedPosition
        currentModeCamera: camera.captureMode === Camera.CaptureStillImage

        cameraFlash: camera.flash
        onSwitchCameraClicked: {
            camera.position = camera.position
                    === Camera.FrontFace ? Camera.BackFace : Camera.FrontFace
        }

        onFlutterViewClicked: {
            if (selfTimer.running) {
                selfTimer.stop()
            } else if ((camera.selfTimerDuration === 0)
                       || (camera.videoRecorder.recorderStatus
                           === CameraRecorder.RecordingStatus)) {
                selfTimer.onTriggered()
            } else {
                countdownTimer.remainingSeconds = camera.selfTimerDuration
                countdownTimer.start()
                selfTimer.start()
            }
        }

        onCameraViewClicked: {
            if (camera.captureMode !== Camera.CaptureStillImage) {
                camera.captureMode = Camera.CaptureStillImage
            }
        }

        onVideoViewClicked: {
            if (camera.captureMode !== Camera.CaptureVideo) {
                camera.captureMode = Camera.CaptureVideo
            }
        }

        onFocusLengthClicked: {

        }

        onFocusLengthLongClicked: {
            if (!cameraDigitalZoom.visible) {
                cameraDigitalZoom.visible = true
            }
        }
    }

    Timer {
        // counts the seconds from the beginning of the current video recording
        id: recordingDurationTimer
        interval: 1000
        running: camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus
        repeat: true
        property int recordingDurationSeconds: 0

        onTriggered: {
            recordingDurationSeconds++
        }

        onRunningChanged: {
            if (!running) {
                recordingDurationSeconds = 0
            }
        }
    }

    RowLayout {
        id: recordingFeedback
        visible: (camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus)
        spacing: 15 * appScaleSize

        anchors {
            //            left: parent.left
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            margins: root.height * 40 / root.defaultHeight
        }

        BlurBackgroundView {
            id: recordingBlur
            height: 15 * appScaleSize
            width: height
            blurX: recordingFeedback.x
            blurY: recordingFeedback.y
            blurSourceView: viewfinder
            parentView: recordingFeedback

            Rectangle {
                color: "#E95B4E"
                //                anchors.centerIn: recordingBlur
                x: (recordingBlur.width - width) / 2
                y: (recordingBlur.height - height) / 2
                radius: width / 2
                height: 10 * appScaleSize //root.height * 20/root.defaultHeight
                width: height
            }
        }

        Text {
            text: {
                "%1%2:%3".arg(
                            (Math.trunc(
                                 recordingDurationTimer.recordingDurationSeconds
                                 / 60) > 59) ? // display hour count only on demand
                                               (Math.trunc(
                                                    Math.trunc(
                                                        recordingDurationTimer.recordingDurationSeconds / 60) / 60) + ":") : "00" + ":").arg(
                            (((Math.trunc(
                                   recordingDurationTimer.recordingDurationSeconds
                                   / 60) % 60) < 10) ? "0" : "") + // zero padding
                            (Math.trunc(
                                 recordingDurationTimer.recordingDurationSeconds / 60) % 60)).arg(
                            (((recordingDurationTimer.recordingDurationSeconds
                               % 60) < 10) ? "0" : "") + // zero padding
                            (recordingDurationTimer.recordingDurationSeconds % 60))
            }
            font.pixelSize: root.defaultFontSize + 3
            color: "white"
        }
    }

    Timer {
        id: selfTimer
        interval: camera.selfTimerDuration * 1000
        running: false
        repeat: false

        onTriggered: {
            running = false

            if (camera.captureMode === Camera.CaptureStillImage) {
                if (camera.imageCapture.ready) {
                    camera.imageCapture.captureToLocation(
                                CameraUtils.cameraDefaultPath)
                    cameraRight.setPhotoPreview()
                    //                    previewArea.setPhotoPreview()
                    showPassiveNotification(i18n("Took a photo"))
                } else {
                    showPassiveNotification(i18n("Failed to take a photo"))
                }
            } else if (camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus) {
                camera.videoRecorder.stop()
                cameraRight.setVideoPreview()
                //                previewArea.setVideoPreview()
                showPassiveNotification(i18n("Stopped recording"))
            } else if (camera.captureMode === Camera.CaptureVideo) {
                camera.videoRecorder.setOutputLocation(CameraUtils.videoPath)
                camera.videoRecorder.record()

                if (camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus) {
                    showPassiveNotification(i18n("Started recording"))
                } else {
                    showPassiveNotification(i18n("Failed to start recording"))
                }
            }
        }

        onRunningChanged: {
            if (!running) {
                camera.selfTimerRunning = false
                selfTimerAnimation.stop()
                countdownTimer.stop()
                countdownTimer.remainingSeconds = camera.selfTimerDuration
                selfTimerIcon.opacity = 1
            } else {
                camera.selfTimerRunning = true
            }
        }
    }

    Timer {
        // counts the remaining seconds until the selfTimer invokes the capture action
        id: countdownTimer
        interval: 1000
        running: false
        repeat: true
        property int remainingSeconds: 0

        onTriggered: {
            remainingSeconds--
        }
    }

    RowLayout {
        id: selfTimerInfo
        visible: !(camera.selfTimerDuration === 0)
                 && !((camera.captureMode === Camera.CaptureVideo)
                      && (camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus))

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            margins: Kirigami.Units.gridUnit * 1
        }

        Kirigami.Icon {
            id: selfTimerIcon
            source: "alarm-symbolic"
            color: selfTimer.running ? "red" : "white"
            Layout.preferredWidth: Kirigami.Units.gridUnit
            Layout.preferredHeight: Kirigami.Units.gridUnit
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
        }

        Text {
            text: {
                if (selfTimer.running) {
                    "%1 s".arg(countdownTimer.remainingSeconds)
                } else {
                    "%1 s".arg(camera.selfTimerDuration)
                }
            }
            font.pixelSize: defaultFontSize + 3
            color: {
                if (selfTimer.running) {
                    "red"
                } else {
                    "white"
                }
            }
        }

        layer.enabled: selfTimerInfo.enabled
        layer.effect: DropShadow {
            color: Material.dropShadowColor
            samples: 30
            spread: 0.5
        }
    }

    Rectangle {
        id: selfTimerRectangle
        visible: selfTimer.running
        color: "transparent"
        border.color: "red"
        border.width: Kirigami.Units.gridUnit / 6
        opacity: 0

        anchors {
            fill: parent
            centerIn: parent
        }
    }

    BrightnessZoom {
        id: cameraPagebrightnessZoom
        width: 176 * appScaleSize //root.width * 364/root.defaultWidth
        height: 22 * appScaleSize
        anchors {
            top: focusRingView.bottom
            horizontalCenter: focusRingView.horizontalCenter
        }
        visible: focusRingView.opacity === 1.0
        onVisibleChanged: {
            if (visible) {
                currentZoom = cameraPage.camera.imageProcessing.brightness + 1
            }
        }
        maximumZoom: 2.0
        onZoomTo: {
            cameraPage.camera.brightnessValue = value - 1
        }
        onZoomHovered: {
            focusRingView.managerTimer(hovered)
        }
    }

    FocusRing {
        id: focusRingView
    }

    SequentialAnimation {
        id: selfTimerAnimation
        running: selfTimer.running
        loops: Animation.Infinite

        ParallelAnimation {
            OpacityAnimator {
                target: selfTimerIcon
                from: 0
                to: 1
                duration: 500
            }
            OpacityAnimator {
                target: selfTimerRectangle
                from: 0
                to: 1
                duration: 500
            }
        }

        ParallelAnimation {
            OpacityAnimator {
                target: selfTimerIcon
                from: 1
                to: 0
                duration: 500
            }
            OpacityAnimator {
                target: selfTimerRectangle
                from: 1
                to: 0
                duration: 500
            }
        }
    }

    PreviewArea {
        id: previewArea
        imageCapture: camera.imageCapture
        videoRecorder: camera.videoRecorder
        visible: false

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: Kirigami.Units.gridUnit
        }
    }
}
