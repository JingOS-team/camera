import QtQuick 2.0
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12
import QtMultimedia 5.8

Column {
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

    signal previewClicked
    signal switchCameraClicked
    signal flashViewClicked
    signal flutterViewClicked
    signal focusLengthClicked
    signal focusLengthLongClicked
    signal cameraViewClicked
    signal videoViewClicked

    onPreviewUrlChanged: {

    }

    Component.onCompleted: {
        imageCapture.imageSaved.connect(imageCapturePath)
        videoRecorder.recorderStatusChanged.connect(createVideoThumbnail)
        CameraUtils.videoPreviewChanged.connect(videoThumbnailCompleted)
    }

    function videoThumbnailCompleted() {
        previewUrl = "file://" + CameraUtils.videoPreview
    }
    function imageCapturePath(requestId, path) {
        previewUrl = "file://" + path
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

    spacing: width / 2

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
        }
        Image {
            id: previewImage
            anchors.centerIn: parent
            source: previewUrl
            sourceSize: Qt.size(previewView.width, previewView.height)
            asynchronous: true
            cache: false
            visible: false
            fillMode: Image.PreserveAspectFit
        }
        Rectangle {
            id: imagemaskRect
            //            anchors.fill:parent
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
            maskSource: imagemaskRect
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var matchJpg = CameraUtils.lastCameraFilePath.search(".jpg")
                Qt.openUrlExternally(CameraUtils.lastCameraFilePath)
                //                if (matchJpg === null) {
                //                    Qt.openUrlExternally(videoRecorder.actualLocation)
                //                }
                //                else {
                //                    Qt.openUrlExternally("file://" + imageCapture.capturedImagePath)
                //                }
                previewClicked()
            }
        }
    }

    Item {
        id: switchCamera

        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        width: minCircle //root.width * 64/root.defaultWidth
        height: width

        BlurBackgroundView {
            anchors.fill: parent
            blurSourceView: viewfinder
            parentView: cameraPageRight
            blurX: switchCamera.x
            blurY: switchCamera.y
            backColor: isSwitchCamera ? "#66FFFFFF" : "#993C3C43"
        }
        Image {
            id: switchCameraImage
            anchors.centerIn: parent
            width: minImageWidth
            height: width
            source: switchCameraUrl
            sourceSize: Qt.size(switchCamera.width, switchCamera.height)
            asynchronous: true
            cache: false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (isSwitchCamera) {
                    switchCameraClicked()
                } else {
                    showPassiveNotification(i18n("switch camera fail"))
                }
            }
        }
    }

    property var flashUrlArray: [flashOffUrl, flashAutoUrl, flashOnUrl]

    Item {
        id: falshView
        property var supportModes: cameraFlash.supportedModes

        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        width: minCircle //root.width * 64/root.defaultWidth
        height: width

        Component {
            id: flashComponent

            Item {
                id: flashDelegate
                width: minCircle //root.width * 64/root.defaultWidth
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
                Image {
                    id: falshImage
                    anchors.centerIn: parent
                    height: minImageWidth
                    width: height
                    source: flashUrlArray[index]
                    sourceSize: Qt.size(falshView.width, falshView.height)
                    asynchronous: true
                    cache: false
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var imageSource = falshImage.source.toString()
                            switch (imageSource) {
                            case flashAutoUrl:
                                flashUrlArray = [flashAutoUrl, flashOnUrl, flashOffUrl]
                                break
                            case flashOnUrl:
                                flashUrlArray = [flashOnUrl, flashAutoUrl, flashOffUrl]
                                break
                            case flashOffUrl:
                                flashUrlArray = [flashOffUrl, flashAutoUrl, flashOnUrl]
                                break
                            }
                            flashViewClicked()
                        }
                    }
                }
            }
        }

        Row {
            id: flashLeftView

            property int modelCount: 1
            anchors {
                right: parent.right
            }
            width: parent.width * 3
            height: parent.height
            spacing: parent.width
            layoutDirection: Qt.RightToLeft

            Repeater {
                id: flashRepeater
                model: flashLeftView.modelCount
                delegate: flashComponent
            }
            //            Image {
            //                id: falshOnImage
            //                source: flashViewUrl
            //                sourceSize: Qt.size(falshView.width,falshView.height)
            //                asynchronous: true
            //                cache: false
            //            }
            //            Image {
            //                id: falshOffImage
            //                source: flashViewUrl
            //                sourceSize: Qt.size(falshView.width,falshView.height)
            //                asynchronous: true
            //                cache: false
            //            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (falshView.supportModes.length > 0) {
                    flashLeftView.modelCount = flashLeftView.modelCount !== 3 ? 3 : 1
                    flashViewClicked()
                }
            }
        }
    }

    Item {
        id: flutterView

        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        width: maxCircle //parent.width//root.width/12
        height: width
        Image {
            id: flutterImage
            anchors.centerIn: parent
            source: currentModeCamera ? captureShutterUrl : (isCameraRecoding ? recordingUrl : videoShutterUrl)
            sourceSize: Qt.size(flutterView.width, flutterView.height)
            asynchronous: true
            cache: false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                flutterViewClicked()
            }
        }
    }

    Item {
        id: focusLenghtView

        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        width: minCircle //root.width * 64/root.defaultWidth
        height: width

        BlurBackgroundView {
            anchors.fill: parent
            blurSourceView: viewfinder
            parentView: cameraPageRight
            blurX: focusLenghtView.x
            blurY: focusLenghtView.y
        }
        Text {
            id: focusLenghtImage
            anchors.centerIn: parent
            text: focusLengText
            color: "white"
            font.pixelSize: root.defaultFontSize - 4
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                focusLengthClicked()
            }
            onPressAndHold: {
                focusLengthLongClicked()
            }
        }
    }

    Item {
        id: cameraView

        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        width: minCircle //root.width * 64/root.defaultWidth
        height: width

        BlurBackgroundView {
            anchors.fill: parent
            blurSourceView: viewfinder
            parentView: cameraPageRight
            blurX: cameraView.x
            blurY: cameraView.y
            backColor: currentModeCamera ? "#993C3C43" : "#66FFFFFF"
        }
        Image {
            id: cameraImage
            anchors.centerIn: parent
            width: minImageWidth
            height: width
            source: captureUrl
            sourceSize: Qt.size(cameraView.width, cameraView.height)
            asynchronous: true
            cache: false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                cameraViewClicked()
            }
        }
    }

    Item {
        id: videoView

        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        width: minCircle //root.width * 64/root.defaultWidth
        height: width

        BlurBackgroundView {
            anchors.fill: parent
            blurSourceView: viewfinder
            parentView: cameraPageRight
            blurX: videoView.x
            blurY: videoView.y
            backColor: currentModeCamera ? "#66FFFFFF" : "#993C3C43"
        }
        Image {
            id: videoImage
            anchors.centerIn: parent
            height: width
            width: minImageWidth
            source: videoUrl
            sourceSize: Qt.size(videoView.width, videoView.height)
            asynchronous: true
            cache: false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                videoViewClicked()
            }
        }
    }
}
