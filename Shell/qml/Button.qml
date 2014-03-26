import QtQuick 2.0
import QtQuick.Window 2.0
import "js/units.js" as Units

Item {
    id: button
    signal clicked()
    property string type: "default"
    property bool isPortrait: Screen.orientation == 1 || Screen.orientation == 4

    height: isPortrait ? Units.dp(32) : Units.dp(50)
    width: isPortrait ? Units.dp(47) : Units.dp(75)

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
