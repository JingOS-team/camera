

/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.0
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12
import QtMultimedia 5.15

Rectangle {

    id: cameraPageRight

    property string previewUrl: "qrc:/assets/camera_white_balance_sunny.png"
    property string switchCameraUrl: "qrc:/assets/switch_camera.png"
    property string flashAutoUrl: "qrc:/assets/switch_flash.png"
    property string flashOffUrl: "qrc:/assets/flash_off.png"
    property string flashOnUrl: "qrc:/assets/flash_on.png"

    property string captureUrl: "qrc:/assets/capture.png"
    property string videoUrl: "qrc:/assets/video.png"
    property string focusLengText: "1.0X"
    property bool currentModeCamera: true
    property bool isCameraRecoding
    property bool isSwitchCamera
    property bool isFrontCamera: camera.position === Camera.FrontFace
    property string videoShutterUrl: "qrc:/assets/video_shutter.png"
    property string recordingUrl: "qrc:/assets/recording.png"
    property string captureShutterUrl: "qrc:/assets/shutter.png"
    property var videoRecorder
    property var imageCapture
    property var cameraFlash
    property bool videoThumbnailRequested: false
    property bool showVideoPreview: false
    property int minCircle: 32 * appScaleSize
    property int minImageWidth: 22 * appScaleSize
    property int maxCircle: 50 * appScaleSize
    property var flashUrlArray: [flashOffUrl, flashAutoUrl, flashOnUrl]
    property bool isSaveCaptureImage: false
    property var flashModeCache

    signal previewClicked
    signal switchCameraClicked
    signal flashViewClicked(var flashImageUrl)
    signal flutterViewClicked
    signal focusLengthClicked
    signal focusLengthLongClicked
    signal cameraViewClicked
    signal videoViewClicked

    onPreviewUrlChanged: {
        previewAnima.running = true
    }

    Component.onCompleted: {
        imageCapture.imageSaved.connect(imageCapturePath)
        imageCapture.captureFailed.connect(imageCaptureFailed)
        videoRecorder.recorderStatusChanged.connect(createVideoThumbnail)
        CameraUtils.videoPreviewChanged.connect(videoThumbnailCompleted)
    }

    function videoThumbnailCompleted() {
        previewUrl = "file://" + CameraUtils.videoPreview
    }
    function imageCapturePath(requestId, path) {
        previewUrl = "file://" + path
        isSaveCaptureImage = false
    }

    function imageCaptureFailed(requestId, message) {
        isSaveCaptureImage = false
    }

    function setPhotoPreview() {
        showVideoPreview = false
    }

    function setVideoPreview() {
        videoThumbnailRequested = true
        showVideoPreview = true
    }
    function createVideoThumbnail() {
        if (videoThumbnailRequested
                && !(videoRecorder.recorderStatus === CameraRecorder.FinalizingStatus)) {
            CameraUtils.creatPreviewPic(videoRecorder.actualLocation)
            videoThumbnailRequested = false
        }
    }

    function resetUiStatus() {
        if (flashLeftView.modelCount !== 1) {
            flashLeftView.modelCount = 1
        }
    }

    function startPlayVoice() {
        if (playSoundShutter.hasAudio) {
            playSoundShutter.play()
        }
    }

    color: "#00ffffff"

    MouseArea {
        anchors.fill: parent
        onClicked: {

        }
    }

    Audio {
        id: playSoundShutter
        source: "qrc:/assets/camera-shutter.wav" //"file:///usr/share/sounds/freedesktop/stereo/camera-shutter.oga"
        onStatusChanged: {
            console.log(" sound status:::" + status + " error:" + errorString)
        }
    }

    Timer {
        id: flutterTimer
        interval: 1000
        onTriggered: {
            isSaveCaptureImage = false
        }
    }

    Column {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 20 * appScaleSize
        }
        width: parent.width
        spacing: isFrontCamera ? 76 * appHeightScaleSize : 35 * appHeightScaleSize

        Item {
            id: previewView

            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            width: maxCircle
            height: width
            clip: true

            BlurBackgroundView {
                anchors.fill: parent
                blurSourceView: viewfinder
                parentView: cameraPageRight
                blurX: previewView.x
                blurY: previewView.y
                visible: imageMask.visible
            }

            NumberAnimation {
                id: previewAnima
                target: imageMask
                property: "scale"
                from: 0.5
                to: 1
                duration: 250
                easing.type: Easing.InOutQuad
            }

            Image {
                id: previewImage
                anchors.centerIn: parent
                width: previewView.width
                height: previewView.height
                source: previewUrl
                asynchronous: true
                antialiasing: true
                cache: false
                visible: false
                fillMode: Image.PreserveAspectCrop
            }
            Rectangle {
                id: imagemaskRect
                anchors.centerIn: parent
                width: parent.width - 2 * appScaleSize
                height: width
                radius: width / 2
                visible: false
                clip: true
            }
            OpacityMask {
                id: imageMask
                anchors.fill: imagemaskRect
                anchors.centerIn: parent
                source: previewImage
                antialiasing: true
                maskSource: imagemaskRect
                visible: !isCameraRecoding
            }

            MouseArea {
                anchors.fill: parent
                enabled: !isCameraRecoding
                onClicked: {
                    resetUiStatus()
                    flashModeCache = cameraFlash.mode
                    if (cameraFlash.mode !== Camera.FlashOff) {
                        cameraFlash.mode = Camera.FlashOff
                    }
                    if (imageMask.visible) {
                        pushView()
                        previewClicked()
                    }
                }
            }
        }

        Item {
            id: switchCamera

            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            width: minCircle
            height: width

            BlurBackgroundView {
                anchors.fill: parent
                blurSourceView: viewfinder
                parentView: cameraPageRight
                blurX: switchCamera.x
                blurY: switchCamera.y
                backColor: isSwitchCamera ? "#66FFFFFF" : "#993C3C43"
                visible: switchCameraImage.visible
            }
            Image {
                id: switchCameraImage
                anchors.centerIn: parent
                width: minImageWidth
                height: width
                source: switchCameraUrl
                asynchronous: true
                cache: false
                visible: !isCameraRecoding
            }

            MouseArea {
                anchors.fill: parent
                enabled: !isCameraRecoding
                onClicked: {
                    resetUiStatus()
                    if (isSwitchCamera) {
                        switchCameraClicked()
                    }
                }
            }
        }

        Item {
            id: falshView
            property var supportModes: cameraFlash.supportedModes
            property var flashCurrentMode: cameraFlash.mode

            onFlashCurrentModeChanged: {
                switch (flashCurrentMode) {
                case Camera.FlashAuto:
                    flashUrlArray = [flashAutoUrl, flashOnUrl, flashOffUrl]
                    break
                case Camera.FlashOn:
                case Camera.FlashVideoLight:
                    flashUrlArray = [flashOnUrl, flashAutoUrl, flashOffUrl]
                    break
                case Camera.FlashOff:
                    flashUrlArray = [flashOffUrl, flashAutoUrl, flashOnUrl]
                    break
                }
            }

            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            width: minCircle
            height: width
            visible: !isFrontCamera

            Component {
                id: flashComponent

                Item {
                    id: flashDelegate
                    width: minCircle
                    height: width
                    BlurBackgroundView {
                        anchors.fill: parent
                        blurSourceView: viewfinder
                        parentView: cameraPageRight
                        blurX: flashDelegate.x
                        blurY: flashDelegate.y
                        backColor: flashLeftView.modelCount === 3 & index
                                   === 0 ? "#993C3C43" : (falshView.supportModes.length
                                                          > 0 ? "#66FFFFFF" : "#993C3C43")
                    }

                    visible: getVisble()
                    function getVisble() {
                        var value = false

                        if (currentModeCamera) {
                            value = true
                        } else if (falshImage.source != flashAutoUrl) {
                            value = true
                        } else {
                            value = false
                        }
                        return value
                    }
                    Image {
                        id: falshImage
                        anchors.centerIn: parent
                        height: minImageWidth
                        width: height
                        source: flashUrlArray[index]
                        asynchronous: true
                        cache: false

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var imageSource = falshImage.source.toString()
                                var flashStatus = 0
                                switch (imageSource) {
                                case flashAutoUrl:
                                    flashStatus = 2
                                    flashUrlArray = [flashAutoUrl, flashOnUrl, flashOffUrl]
                                    break
                                case flashOnUrl:
                                    flashStatus = 1
                                    flashUrlArray = [flashOnUrl, flashAutoUrl, flashOffUrl]
                                    break
                                case flashOffUrl:
                                    flashStatus = 0
                                    flashUrlArray = [flashOffUrl, flashAutoUrl, flashOnUrl]
                                    break
                                }
                                flashViewClicked(imageSource)
                                if (falshView.supportModes.length > 0) {
                                    flashLeftView.stopTimer()
                                    flashLeftView.modelCount
                                            = flashLeftView.modelCount !== 3 ? 3 : 1
                                }
                            }
                        }
                    }
                }
            }

            Timer {
                id: flashTimer
                interval: 5000
                onTriggered: {
                    if (flashLeftView.modelCount !== 1) {
                        flashLeftView.modelCount = 1
                    }
                }
            }

            Row {
                id: flashLeftView

                property int modelCount: 1
                property bool timerRunning: true
                anchors {
                    right: parent.right
                }
                width: parent.width * 3
                height: parent.height
                spacing: parent.width
                layoutDirection: Qt.RightToLeft
                visible: {
                    if (isFrontCamera) {
                        return false
                    }
                    return !isCameraRecoding
                }

                function stopTimer() {
                    if (flashTimer.running) {
                        flashTimer.stop()
                    }
                }
                Repeater {
                    id: flashRepeater
                    model: flashLeftView.modelCount
                    delegate: flashComponent
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: flashLeftView.visible
                onClicked: {
                    if (falshView.supportModes.length > 0) {
                        flashLeftView.modelCount = flashLeftView.modelCount !== 3 ? 3 : 1
                    }
                    if (flashLeftView.modelCount === 3) {
                        flashTimer.start()
                    } else {
                        flashTimer.stop()
                    }
                }
            }
        }

        Item {
            id: flutterView

            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            width: maxCircle
            height: width
            Image {
                id: flutterImage
                anchors.centerIn: parent
                width: flutterView.width
                height: flutterView.height
                antialiasing: true
                source: currentModeCamera ? captureShutterUrl : (isCameraRecoding ? recordingUrl : videoShutterUrl)
                asynchronous: true
                cache: false
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    resetUiStatus()
                    if (flutterTimer.running || switchLoader.active) {
                        return
                    }
                    flutterTimer.start()
                    playSoundShutter.stop()
                    if (currentModeCamera) {
                        if (isSaveCaptureImage) {
                            return
                        }
                        isSaveCaptureImage = true
                    }
                    flutterViewClicked()
                }
            }
        }

        Item {
            id: focusLenghtView

            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            width: minCircle
            height: width
            visible: !isFrontCamera

            BlurBackgroundView {
                anchors.fill: parent
                blurSourceView: viewfinder
                parentView: cameraPageRight
                blurX: focusLenghtView.x
                blurY: focusLenghtView.y
                visible: focusLenghtImage.visible
            }
            Text {
                id: focusLenghtImage
                anchors.centerIn: parent
                text: focusLengText
                color: "white"
                font.pixelSize: (root.defaultFontSize - 4) * appFontSize

                visible: {
                    if (isFrontCamera) {
                        return false
                    }
                    return !isCameraRecoding
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: focusLenghtImage.visible
                onClicked: {
                    resetUiStatus()
                    focusLengthClicked()
                }
                onPressAndHold: {
                    resetUiStatus()
                    focusLengthLongClicked()
                }
            }
        }

        Item {
            id: cameraView

            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            width: minCircle
            height: width

            BlurBackgroundView {
                anchors.fill: parent
                blurSourceView: viewfinder
                parentView: cameraPageRight
                blurX: cameraView.x
                blurY: cameraView.y
                backColor: currentModeCamera ? "#993C3C43" : "#66FFFFFF"
                visible: !isCameraRecoding
            }
            Image {
                id: cameraImage
                anchors.centerIn: parent
                width: minImageWidth
                height: width
                source: captureUrl
                asynchronous: true
                cache: false
                visible: !isCameraRecoding
            }

            MouseArea {
                anchors.fill: parent
                enabled: cameraImage.visible
                onClicked: {
                    resetUiStatus()
                    cameraViewClicked()
                }
            }
        }

        Item {
            id: videoView

            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            width: minCircle
            height: width

            BlurBackgroundView {
                anchors.fill: parent
                blurSourceView: viewfinder
                parentView: cameraPageRight
                blurX: videoView.x
                blurY: videoView.y
                backColor: currentModeCamera ? "#66FFFFFF" : "#993C3C43"
                visible: !isCameraRecoding
            }
            Image {
                id: videoImage
                anchors.centerIn: parent
                height: width
                width: minImageWidth
                source: videoUrl
                asynchronous: true
                cache: false
                visible: !isCameraRecoding
            }

            MouseArea {
                anchors.fill: parent
                enabled: videoImage.visible
                onClicked: {
                    resetUiStatus()
                    videoViewClicked()
                }
            }
        }
    }
}
