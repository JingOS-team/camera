

/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.4

Image {
    id: focusRing

    property point center

    function managerTimer(isStop) {
        if (hideTimer.running & isStop) {
            hideTimer.stop()
        } else {
            hideTimer.start()
        }
    }

    function show() {
        hideTimer.restart()
        //        rotationAnimation.restart();
        opacity = 1.0
    }

    x: center.x - width / 2.0
    y: center.y - height / 2.0
    width: 90 * appScaleSize //root.width * 180/root.defaultWidth
    height: width
    source: "qrc:/assets/focus_ring.png"
    asynchronous: true
    cache: false
    opacity: 0.0

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: {
            focusRing.opacity = 0.0
        }
    }

    //    RotationAnimator {
    //        id: rotationAnimation
    //        target: focusRing
    //        from: 0
    //        to: 90
    //        duration: 500
    ////        easing: Easing.InCirc
    //    }
}
