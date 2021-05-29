import QtQuick 2.0
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.15

Item {
    id: blurBackgroundView

    property var blurSourceView
    property var parentView
    property string backColor: "#66FFFFFF"
    property int blurX
    property int blurY
    property point blurPoint

    ShaderEffectSource {
        id: eff
        width: parent.width
        height: parent.height
        sourceItem: blurSourceView
        anchors.centerIn: parent
        visible: false
        sourceRect: getSourceRect()
        recursive: true

        //            Qt.rect( blurBackgroundView.mapToItem(blurSourceView).x,
        //                            blurBackgroundView.mapToItem(blurSourceView).y,
        //                            blurBackgroundView.width,
        //                            blurBackgroundView.height )
        function getSourceRect() {
            var mG = eff.mapToItem(blurSourceView, blurX, blurY)
            var mR = eff.mapToItem(blurSourceView, eff.x, eff.y)
            var px = parentView.x
            var py = parentView.y

            //            console.log("zhg---qml::blurX:"
            //                        +parentView.x + " blurY:"+parentView.y
            //                        +" mR::"+ mR
            //                        +" mG::"+ mG
            //                        )
            return Qt.rect(mR.x, mR.y, eff.width, eff.height)
        }
    }
    FastBlur {
        id: fastBlur
        anchors.fill: parent
        source: eff
        radius: 64
        cached: true
        visible: false
    }

    Rectangle {
        id: maskRect
        anchors.fill: fastBlur
        radius: width / 2
        visible: false
        clip: true
    }
    OpacityMask {
        id: mask
        anchors.fill: maskRect
        visible: true
        source: fastBlur
        maskSource: maskRect
    }
    Rectangle {
        anchors.fill: fastBlur
        radius: width / 2
        color: backColor
        clip: true
    }
}
