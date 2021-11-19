

/****************************************************************************
**
** Copyright (C) 2018 Jonah Brüchert
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
**               2020 Zhang He Gang <zhanghegang@jingos.com>
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
    property var pageActive: root.appActive

    title: i18n("Camera")

    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0
    topPadding: 0

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None //Kirigami.Settings.isMobile ? Kirigami.ApplicationHeaderStyle.None : Kirigami.ApplicationHeaderStyle.ToolBar
    onIsCurrentPageChanged: isCurrentPage && pageStack.depth > 1
                            && pageStack.pop()

    Connections {
        target: CameraUtils
        onQuitApp: {
            console.log("onQuitApp ing....isRecorder:"
                        + (camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus))
            if (camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus) {
                cameraRight.setVideoPreview()
                camera.videoRecorder.stop()
            }
        }

        onPauseApp: {
            console.log("onpauseapp:")
            if (camera.flash.mode !== Camera.FlashOff && mainCamera.captureMode !== Camera.CaptureStillImage) {
                camera.flash.mode = Camera.FlashOff
            }
            if (camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus) {
                cameraRight.setVideoPreview()
                camera.videoRecorder.stop()
            }
        }
        function onError(error) {
            console.warn("Error on the CameraUtils", error)
        }
    }

    onPageActiveChanged: {
        console.log(" active changed::" + pageActive)
        if (pageActive) {
            cameraRight.previewUrl = CameraUtils.lastCameraPreviewPath
            camera.start()
            camera.autoFocus()
        } else {
            CameraUtils.requestDbusWakeup(false)
            if (camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus) {
                cameraRight.setVideoPreview()
                camera.videoRecorder.stop()
            }
            camera.stop()
        }
    }

    Rectangle {
        id: cameraUI
        state: "PhotoCapture"

        anchors {
            fill: parent
            centerIn: parent
        }

        color: "black"

        onVisibleChanged: {
            console.log(" camera ui visible:::" + visible)
            if (visible) {
                cameraRight.previewUrl = CameraUtils.lastCameraPreviewPath
                if (cameraRight.flashModeCache !== -1) {
                    camera.flash.mode = cameraRight.flashModeCache
                    cameraRight.flashModeCache = -1
                }
                CameraUtils.setDistanceValue(1)
            } else {
                CameraUtils.setDistanceValue(40)
            }
        }

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
            property bool isSwitched: false
            property alias currentCaptureMode: mainCamera.captureMode

            onCurrentCaptureModeChanged: {
                if (currentCaptureMode === Camera.CaptureStillImage) {
                    CameraUtils.requestDbusWakeup(false)
                }
            }
            function manualFocus(x, y) {
                var normalizedPoint = viewfinder.mapPointToSourceNormalized(
                            Qt.point(x, y - viewfinder.y))
                if (normalizedPoint.x >= 0.0 && normalizedPoint.x <= 1.0
                        && normalizedPoint.y >= 0.0
                        && normalizedPoint.y <= 1.0) {
                    focusRingView.center = Qt.point(x, y)
                    //default brightness value
                    mainCamera.brightnessValue = 0
                    cameraPagebrightnessZoom.mSlideValue = 1
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

            Component.onCompleted: {
                autoFocus()
            }

            onCameraStateChanged: {
            }

            onCameraStatusChanged: {
                if (cameraStatus === Camera.ActiveStatus & switchLoader.active) {
                    loadSwitchView()
                }
            }

            captureMode: Camera.CaptureStillImage
            deviceId: CameraSettings.cameraDeviceId
            flash {
                id: cFlash
                mode: Camera.FlashOff
            }
            focus {
                id: cFocus
                focusMode: Camera.FocusContinuous
                focusPointMode: Camera.FocusPointAuto
            }
            imageCapture {
                id: imageCapture
            }

            videoRecorder {
                id: videoRecorder
            }
            imageProcessing {
                id: imageProcessing
                whiteBalanceMode: CameraImageProcessing.WhiteBalanceAuto //CameraSettings.whiteBalanceMode
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
            visible: cameraUI.state == "PhotoCapture" || cameraUI.state == "VideoCapture"
            // Workaround
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop //fill screen
            flushMode: VideoOutput.LastFrame //fix black screen
            source: mainCamera
        }

        PinchArea {
            anchors.centerIn: parent
            width: parent.width - 80
            height: parent.height - 80
            property real initialZoom
            property real minimumScale: 0.3
            property real maximumScale: 3.0
            property bool active: false
            enabled: camera.position !== Camera.FrontFace

            onPinchStarted: {
                active = true
                initialZoom = cameraPage.camera.digitalZoom
            }
            onPinchUpdated: {
                var scale = cameraPage.camera.maximumDigitalZoom / 2
                        * pinch.scale - cameraPage.camera.maximumDigitalZoom / 2
                var dzValue = Math.min(cameraPage.camera.maximumDigitalZoom,
                                       initialZoom + scale)
                cameraPage.camera.setDigitalZoom(Math.max(dzValue, 1))
            }
            onPinchFinished: {
                active = false
            }
            MouseArea {
                anchors.fill: parent
                property var startMouseY: 0

                onClicked: {
                }

                function openFocusUi(mouse) {
                    mainCamera.manualFocus(mouse.x, mouse.y)
                    if (cameraPage.camera.lockStatus === cameraPage.camera.Unlocked) {
                        cameraPage.camera.searchAndLock()
                    } else {
                        cameraPage.camera.unlock()
                    }
                }

                onPressed: {
                    startMouseY = mouse.y
                }

                onReleased: {
                    var offsetValue = mouse.y - startMouseY
                    cameraRight.resetUiStatus()
                    if (Math.abs(offsetValue) < 100) {
                        openFocusUi(mouse)
                    } else {
                        if (cameraRight.isCameraRecoding) {
                            return
                        }
                        if (offsetValue < 0) {
                            if (camera.captureMode !== Camera.CaptureVideo) {
                                loadSView()
                                cameraRight.startSwitchMode(2)
                            }
                        } else {
                            if (camera.captureMode !== Camera.CaptureStillImage) {
                                loadSView()
                                cameraRight.startSwitchMode(1)
                            }
                        }
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
            margins: Kirigami.Units.gridUnit * 2 * appScaleSize
        }
        width: Kirigami.Units.gridUnit * 2 * appScaleSize
        height: parent.height
        currentZoom: cameraPage.camera.digitalZoom
        maximumZoom: cameraPage.camera.maximumDigitalZoom
        onZoomTo: cameraPage.camera.setDigitalZoom(value)
        onCurrentZoomChanged: {
        }
    }

    Component {
        id: switchComponent
        Rectangle {
            id: contentRect
            property bool loadIsShow: switchLoader.active
            color: "#000000"
            width: cameraPage.width
            height: cameraPage.height

            onLoadIsShowChanged: {
                if (loadIsShow) {
                    contentViewAnima.from = 0
                    contentViewAnima.to = 1.0
                    contentViewAnima.start()
                }
            }
            NumberAnimation {
                id: contentViewAnima
                target: contentRect
                property: "opacity"
                from: 0
                to: 1.0
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }
    }

    Timer {
        id: switchTimer
        interval: 500
        onTriggered: {
            switchLoader.active = false
            camera.autoFocus()
        }
    }

    Loader {
        id: switchLoader
        sourceComponent: switchComponent
        active: true
    }

    function loadSwitchView() {
        if (switchTimer.running) {
            switchTimer.stop()
        }
        switchTimer.start()
    }

    function loadSView() {
        focusRingView.hide()
        camera.isSwitched = true
        switchLoader.active = true
    }

    CameraPageRight {
        id: cameraRight
        property bool rootActive: root.active
        property int currentSwitchMode: 0

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        width: 75 * appScaleSize
        height: parent.height * 5 / 6
        //TODO update last preview
        previewUrl: CameraUtils.lastCameraPreviewPath
        focusLengText: (cameraPage.camera.digitalZoom !== 0 ? (Math.round(cameraPage.camera.digitalZoom * 10) / 10.0).toFixed(1) + "X" : "1.0X")
        videoRecorder: camera.videoRecorder
        imageCapture: camera.imageCapture
        isCameraRecoding: camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus
        isSwitchCamera: camera.position !== Camera.UnspecifiedPosition
        currentModeCamera: camera.captureMode === Camera.CaptureStillImage

        cameraFlash: camera.flash

        onRootActiveChanged: {
            if (rootActive) {
                previewUrl = CameraUtils.lastCameraPreviewPath
            }
        }

        onIsCameraRecodingChanged: {
            CameraUtils.requestDbusWakeup(isCameraRecoding)
        }

        Timer {
            id: switchCameraTimer
            interval: 150
            onTriggered: {
                if (cameraRight.currentSwitchMode === 0) {
                    camera.position = camera.position
                            === Camera.FrontFace ? Camera.BackFace : Camera.FrontFace
                } else if (cameraRight.currentSwitchMode === 1) {
                    camera.captureMode = Camera.CaptureStillImage
                    camera.flash.mode = Camera.FlashOff
                } else if (cameraRight.currentSwitchMode === 2) {
                    camera.captureMode = Camera.CaptureVideo
                    camera.flash.mode = Camera.FlashOff
                }
            }
        }

        function startSwitchMode(switchMode) {
            if (!switchCameraTimer.running) {
                cameraRight.currentSwitchMode = switchMode
                switchCameraTimer.start()
            }
        }

        onPreviewClicked: {
            mainCamera.brightnessValue = 0
        }
        onSwitchCameraClicked: {
            loadSView()
            startSwitchMode(0)
            autoFocus()
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
                loadSView()
                startSwitchMode(1)
            }
        }

        onVideoViewClicked: {
            if (camera.captureMode !== Camera.CaptureVideo) {
                loadSView()
                startSwitchMode(2)
            }
        }

        onFocusLengthClicked: {
            cameraDigitalZoom.visible = !cameraDigitalZoom.visible
        }

        onFlashViewClicked: {
            switch (flashImageUrl) {
            case flashAutoUrl:
                camera.flash.mode = Camera.FlashAuto
                break
            case flashOnUrl:
                camera.flash.mode = currentModeCamera ? Camera.FlashOn : Camera.FlashVideoLight
                break
            case flashOffUrl:
                camera.flash.mode = Camera.FlashOff
                break
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
            recordingDurationSeconds = camera.videoRecorder.duration / 1000
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
            font.pixelSize: (root.defaultFontSize + 3) * appFontSize
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
                    cameraRight.startPlayVoice()
                    camera.imageCapture.captureToLocation(
                                CameraUtils.cameraDefaultPath)
                    cameraRight.setPhotoPreview()
                } else {
                    cameraRight.isSaveCaptureImage = false
                }
            } else if (camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus) {
                cameraRight.setVideoPreview()
                camera.videoRecorder.stop()
            } else if (camera.captureMode === Camera.CaptureVideo) {
                camera.videoRecorder.setOutputLocation(CameraUtils.videoPath)
                camera.videoRecorder.record()

                if (camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus) {
                } else {
                    console.log(" Failed to start recording")
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
            margins: Kirigami.Units.gridUnit * 1 * appScaleSize
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
            font.pixelSize: (defaultFontSize + 3) * appFontSize
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

        width: 176 * appScaleSize
        height: 22 * appScaleSize
        anchors {
            top: focusRingView.bottom
            horizontalCenter: focusRingView.horizontalCenter
        }
        visible: {
            if (!cameraRight.isFrontCamera) {
                return focusRingView.opacity === 1.0
            } else {
                return false
            }
        }

        onVisibleChanged: {
            if (visible) {
                console.log(" bright current value:" + cameraPage.camera.imageProcessing.brightness
                            + " mVisualPosition:" + mVisualPosition + " mSlideValue" + mSlideValue)
                currentZoom = cameraPage.camera.imageProcessing.brightness + 1
                mSlideValue = 1
            }
        }
        maximumZoom: 2.0
        onZoomTo: {
            focusRingView.managerTimer(false)
            cameraPage.camera.brightnessValue = value - 1
        }
        onZoomHovered: {
            focusRingView.managerTimer(isHovered)
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
}
