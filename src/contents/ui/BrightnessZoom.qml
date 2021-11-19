/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

import QtQuick 2.0
import QtQuick.Controls 2.15

Item {
    id:brightnessZoom

    property real currentZoom: 1
    property real maximumZoom: 2
    property real minimumZoom: 0
    property alias mVisualPosition: sliderView.visualPosition
    property alias mSlideValue: sliderView.value
    signal zoomTo(real value)
    signal zoomHovered(var isHovered)

    onXChanged: {
        eff.sourceRect = eff.getSourceRect()
        forceActiveFocus()
    }

    onYChanged: {
        eff.sourceRect = eff.getSourceRect()
        forceActiveFocus()
    }

    Slider {
        id:sliderView

        property int playPosition

        width: brightnessZoom.width
        height: brightnessZoom.height
        from: minimumZoom
        to: maximumZoom
        value:currentZoom
        touchDragThreshold: 1
        background: Rectangle {
            width: sliderView.availableWidth
            height: implicitHeight
            x: sliderView.leftPadding
            y: sliderView.topPadding + sliderView.availableHeight / 2 - height / 2
            implicitWidth: parent.width
            implicitHeight: 2
            radius: 2
            color: "#FFFFFF"
        }

        handle: Rectangle {
            id:handleRect
            x: sliderView.leftPadding + sliderView.visualPosition * (sliderView.availableWidth - width)
            y: sliderView.topPadding + sliderView.availableHeight / 2 - height / 2
            color: "#00FF0000"
            border.width: 0
            implicitWidth:  22 * appScaleSize
            implicitHeight: 22 * appScaleSize
            radius: height/2
            onXChanged: {
                eff.sourceRect = eff.getSourceRect()
            }
            ShaderEffectSource{
                id:eff
                width: parent.width
                height: parent.height
                sourceItem: viewfinder
                anchors.centerIn: parent
                onVisibleChanged: {
                    if(visible){
                        sourceRect = getSourceRect()
                    }
                }
                sourceRect: getSourceRect()
                recursive: true
                function getSourceRect(){
                    var mG = eff.mapToItem(viewfinder,handleRect.x,handleRect.y)
                    var mR = eff.mapToItem(viewfinder,eff.x,eff.y)
                    return Qt.rect(mR.x,mR.y,eff.width,eff.height)
                }
            }
            Image {
                id: lightImage
                anchors.centerIn: parent
                source:"qrc:/assets/light.png"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                width: 44 * appScaleSize
                height: width

            }
        }

        onMoved: {
            zoomTo(value)
        }
        onHoveredChanged: {
            zoomHovered(hovered)
        }

    }
}
