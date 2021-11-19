

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
import QtQuick 2.12
import org.kde.kirigami 2.15 as Kirigami
import QtMultimedia 5.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.15
import jingos.display 1.0

import org.kde.plasmacamera 1.0

Kirigami.ApplicationWindow {
    id: root

    property int defaultFontSize: 14 //theme.defaultFont.pointSize
    property int defaultWidth: 1920
    property int defaultHeight: 1200
    property var appScaleSize: JDisplay.dp(1.0) //width / 888
    property var appHeightScaleSize: JDisplay.dp(1.0) //height / 648
    property var appFontSize: JDisplay.sp(1.0)
    property var appActive

    width: root.screen.width
    height: root.screen.height
    pageStack.interactive: false
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None
    visibility: Window.FullScreen

    onActiveChanged: {
        if (active) {
            visibility = Window.FullScreen
        }
        appActive = active
    }

    Component {
        id: aboutPage

        AboutPage {}
    }

    function pushView() {
        CameraPhotosModel.loadCameraPath()
        if (CameraPhotosModel.dataSize() <= 0) {
            return
        }
        var lastIndex = CameraPhotosModel.dataSize() - 1
        var previousObj = applicationWindow().pageStack.layers.push(
                    cameraDetaileComponent, {
                        "startIndex": lastIndex,
                        "imagesModel": CameraPhotosModel,
                        "imageDetailTitle": i18n("Camera")
                    })
        previousObj.close.connect(popView)
        previousObj.deleteCurrentPicture.connect(previewPageDeletePicture)
    }

    function previewPageDeletePicture(index, path) {
        CameraPhotosModel.removePhotoFile(index, path)
    }

    function popView() {
        applicationWindow().pageStack.layers.pop()
    }

    pageStack.initialPage: Component {
        id: mainComponent
        CameraPage {
            id: cameraPageView
            width: root.width
            height: root.height
        }
    }

    Component {
        id: cameraDetaileComponent
        Kirigami.JImagePreviewItem {}
    }
}
