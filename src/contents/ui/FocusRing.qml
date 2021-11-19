

/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.4

Image {
    id: focusRing

    property point center

    function managerTimer(isStop) {
        if (hideTimer.running & isStop) {
            hideTimer.stop()
        } else {
            hideTimer.stop()
            hideTimer.start()
        }
    }

    function show() {
        hideTimer.restart()
        opacity = 1.0
    }
    function hide() {
        if (opacity === 1.0) {
            hideTimer.stop()
            opacity = 0.0
        }
    }

    x: center.x
    y: center.y
    width: 90 * appScaleSize
    height: width
    source: "qrc:/assets/focus_ring.png"
    asynchronous: true
    cache: false
    opacity: 0.0

    Timer {
        id: hideTimer
        interval: 3000
        onTriggered: {
            focusRing.opacity = 0.0
        }
    }
}
