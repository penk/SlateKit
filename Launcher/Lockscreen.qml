import QtQuick 2.0
import "../Shell/qml/js/units.js" as Units
Rectangle { 
    id: toggleSwitch
    color: "#FEEB75" 
    property variant offset: Units.dp(50)
    FontLoader { id: fontAwesome; source: "../Shell/qml/icons/fontawesome-webfont.ttf" }
    Text { 
        id: shortTime 
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: Units.dp(50)
        }
        text: Qt.formatDateTime(new Date(), "hh:mm"); 
        font { 
            pointSize: Units.dp(45); 
            bold: true;
        }
    }
    Text {
        anchors {
            top: shortTime.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Units.dp(5)
        }
        text: Qt.formatDateTime(new Date(), "dddd, MMMM d"); 
        font.pointSize: Units.dp(20)
    }
    Text { 
        id: hint
        anchors { 
            //top: parent.top
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        text: "Unlock"
        font.pointSize: Units.dp(25)
        font.bold: true
        visible: false 
    }
    Text { 
        id: knob 
        y: parent.height - font.pointSize - offset 
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: fontAwesome.name
        font.pointSize: Units.dp(32)
        text: "\uf023"

        MouseArea {
            anchors.margins: Units.dp(-30)
            anchors.fill: parent
            drag.target: knob 
            drag.axis: Drag.YAxis
            drag.minimumY: toggleSwitch.height / 2 + offset
            drag.maximumY: toggleSwitch.height - knob.font.pointSize - offset 
            onPressed: hint.visible = true 
            onPositionChanged: if (knob.y < toggleSwitch.height - Units.dp(400) ) { toggleSwitch.visible = false; knob.y = drag.maximumY; hint.visible = false }
            onReleased: { bounce.restart(); hint.visible = false }
        }
        SequentialAnimation {
            id: bounce
            PropertyAnimation { target: knob; properties: "y"; to: toggleSwitch.height - knob.font.pointSize - offset; easing.type:Easing.InOutQuad; duration: 200  }
            PropertyAnimation { target: knob; properties: "y"; to: toggleSwitch.height - knob.font.pointSize - offset - Units.dp(30); easing.type:Easing.InOutQuad; duration: 50  }
            PropertyAnimation { target: knob; properties: "y"; to: toggleSwitch.height - knob.font.pointSize - offset; easing.type:Easing.InOutQuad; duration: 50  }

        }
    }
}
