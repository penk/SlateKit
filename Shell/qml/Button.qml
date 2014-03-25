import QtQuick 2.0
import "js/units.js" as Units

Item {
    id: button
    signal clicked()
    property string type: "default"

    height: Units.dp(50)
    width: Units.dp(75)

    Rectangle { 
        visible: (type === "default") ? true : false 
        anchors.fill: parent;
        color: "transparent";
        opacity: 0.3;

        MouseArea {
            anchors.fill: parent;
            onPressed: { parent.color = 'black'; } 
            onClicked: { button.clicked(); } 
            onReleased: { parent.color = 'transparent'; }
        }
    }
}
