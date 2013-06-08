import QtQuick 2.0

Rectangle { 
    id: button
    property string label: ""
    signal clicked()

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#FFFFFF" }
        GradientStop { position: 0.5; color: "#FFFFFF" }
        GradientStop { position: 0.8; color: "#EEF1F5" }
        GradientStop { position: 1.0; color: "#D1D3D6" }
    }
    radius: 4.0
    height: 50; width: 220 
    Text { 
        anchors.centerIn: parent
        font { pixelSize: 20; bold: true } 
        text: button.label
    } 
    MouseArea {
        anchors.fill: parent;
        onClicked: { button.clicked(); } 
    }
}
