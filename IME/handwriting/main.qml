import "../../Canvas"
import QtQuick 1.0 

Item {
    id:root
    width: 800 // 768
    height:480 // 263

    property variant resultArray: [];

    TextEdit { 
        id: input
        height: 217
        font.pointSize: 25;
        anchors.top: parent.top;
        anchors.left: parent.left;
        anchors.right: parent.right;
        text: ""
    }

    Rectangle { 

        width: 800 //768
        height: 263
        anchors.top: input.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;

    anchors.margins: 4
    Image { source: "asset/bg.png"; anchors.fill: parent; }

    Drawing {
            id:canvas
            width: 369;
            height: 263;
            x: 216
            y: 0
    }

    Column {
            id: rightColumn;
            width: 70;
            anchors.top: parent.top;
            anchors.right: parent.right;

            // FIXME: use Model of input Text / Button 
            Text { id: text1; font.family: "Helvetica"; font.pointSize: 38; MouseArea { anchors.fill: parent; onClicked: { input.text += text1.text; canvas.clear() } } } 
            Text { id: text2; font.family: "Helvetica"; font.pointSize: 38; MouseArea { anchors.fill: parent; onClicked: { input.text += text2.text; canvas.clear() } } } 
            Text { id: text3; font.family: "Helvetica"; font.pointSize: 38; MouseArea { anchors.fill: parent; onClicked: { input.text += text3.text; canvas.clear() } } }  
            Text { id: text4; font.family: "Helvetica"; font.pointSize: 38; MouseArea { anchors.fill: parent; onClicked: { input.text += text4.text; canvas.clear() } } }   
    }

    Column { 
            id: leftColumn; 
            width: 70;
            anchors.top: parent.top; 
            anchors.right: rightColumn.left; 
            anchors.rightMargin: 30;
            Text { id: text5; font.family: "Helvetica"; font.pointSize: 38; MouseArea { anchors.fill: parent; onClicked: { input.text += text5.text; canvas.clear() } } } 
            Text { id: text6; font.family: "Helvetica"; font.pointSize: 38; MouseArea { anchors.fill: parent; onClicked: { input.text += text6.text; canvas.clear() } } }
            Text { id: text7; font.family: "Helvetica"; font.pointSize: 38; MouseArea { anchors.fill: parent; onClicked: { input.text += text7.text; canvas.clear() } } } 
            Text { id: text8; font.family: "Helvetica"; font.pointSize: 38; MouseArea { anchors.fill: parent; onClicked: { input.text += text8.text; canvas.clear() } } } 
    }

    Item {
        id:clearbutton
        width:100
        height:65

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 100

        MouseArea {
            anchors.fill:parent
            onClicked: { if (text1.text == "") { input.text = input.text.slice(0, - 1); } canvas.clear(); } 
        }
    }

    Item {
        id:spacebutton
        width:200
        height:65

        anchors.left: parent.left
        anchors.top: clearbutton.bottom


        MouseArea {
            anchors.fill:parent
            onClicked: { input.text += " " } 
        }
    }

    }
}
