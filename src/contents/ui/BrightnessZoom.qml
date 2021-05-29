import QtQuick 2.0
import QtQuick.Controls 2.15

Item {
    id: brightnessZoom

    property real currentZoom: 1
    property real maximumZoom: 2
    property real minimumZoom: 0

    signal zoomTo(real value)
    signal zoomHovered(var isHovered)

    onXChanged: {
        eff.sourceRect = eff.getSourceRect()
    }

    onYChanged: {
        eff.sourceRect = eff.getSourceRect()
    }

    Slider {
        id: sliderView

        property int playPosition

        width: brightnessZoom.width
        height: brightnessZoom.height
        from: minimumZoom
        to: maximumZoom
        value: currentZoom
        background: Rectangle {
            width: sliderView.availableWidth
            height: implicitHeight
            x: sliderView.leftPadding
            y: sliderView.topPadding + sliderView.availableHeight / 2 - height / 2
            implicitWidth: parent.width
            implicitHeight: 2
            radius: 2
            color: "#FFFFFF"

            //            Rectangle {
            //                width: sliderView.visualPosition * parent.width
            //                height: parent.height
            //                color: "#FFFFFF"
            //                radius: 2
            //            }
        }

        handle: Rectangle {
            id: handleRect
            x: sliderView.leftPadding + sliderView.visualPosition
               * (sliderView.availableWidth - width)
            y: sliderView.topPadding + sliderView.availableHeight / 2 - height / 2
            color: "#00FF0000"
            border.width: 0
            implicitWidth: 22 * appScaleSize
            implicitHeight: 22 * appScaleSize
            radius: height / 2
            onXChanged: {
                eff.sourceRect = eff.getSourceRect()
            }
            ShaderEffectSource {
                id: eff
                width: parent.width
                height: parent.height
                sourceItem: viewfinder
                anchors.centerIn: parent
                onVisibleChanged: {
                    if (visible) {
                        sourceRect = getSourceRect()
                    }
                }
                sourceRect: getSourceRect()
                recursive: true
                function getSourceRect() {
                    var mG = eff.mapToItem(viewfinder, handleRect.x,
                                           handleRect.y)
                    var mR = eff.mapToItem(viewfinder, eff.x, eff.y)
                    return Qt.rect(mR.x, mR.y, eff.width, eff.height)
                }
            }
            Image {
                id: lightImage
                anchors.centerIn: parent
                source: "qrc:/assets/light.png"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                width: 44
                height: 44
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
