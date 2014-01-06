import QtQuick 2.0
import Fakekey 1.0
import Zinnia 1.0
import "../../IME/handwriting"

Rectangle {

    anchors.fill: parent
    color: "transparent"
    property variant candidates: [];

    Image {
        anchors.fill: parent
        source: "layout/handwriting.png"
    }

    Zinnia {
        id: zinnia
    }

    Fakekey { 
        id: fakekey
    }

    Writing { 
        anchors.left: backspaceButton.right 
        anchors.leftMargin: 10;
        id:canvas
        width: 360
        height: 220 
    } 

    GridView { 
        id: selectionArea 
        interactive: false
        width: 280; height: 220; 
        cellWidth: 140; cellHeight: 60
        anchors { left: canvas.right; top: parent.top; margins: 10; }
        Component { 
            id: textDelegate
            Text { 
                width: 140
                font.pointSize: 32 
                font.bold: true
                text: modelData 
                horizontalAlignment: Text.AlignHCenter
                MouseArea { 
                    width: 140; height: 60
                    anchors { left: parent.left; top: parent.top }
                    onClicked: { 
                        fakekey.sendKey(modelData); canvas.clear(); 
                        if (candidates[0] !== undefined) candidates = []; 
                    }
                }
            } 
        }
        model: candidates; 
        delegate: textDelegate;
    }

    Button { 
        id: hideButton; 
        width: 130; height: 50
        onClicked: { keyboard.state = "hide" }
        anchors { top: parent.top; left: parent.left; leftMargin: 13; topMargin: 8 }  
    }
    Button {
        id: backspaceButton
        width: 130; height: 50
        onClicked: { 
            if (candidates[0] !== undefined) { canvas.clear(); candidates = [] }
            else fakekey.sendKey(":backspace") 
        }
        anchors { top: parent.top; left: hideButton.right; leftMargin: 13; topMargin: 8 }
    }
    Button {
        id: spaceButton;
        width: 275; height: 50
        onClicked: { fakekey.sendKey(' ') }
        anchors { top: hideButton.bottom; left: parent.left; leftMargin: 13; topMargin: 8 }
    }
    Button {
        id: returnButton;
        width: 275; height: 50
        onClicked: { fakekey.sendKey(':enter') }
        anchors { top: spaceButton.bottom; left: parent.left; leftMargin: 13; topMargin: 8 }
    }
    Button {
        id: numButton
        width: 130; height: 50
        onClicked: keyboardLoader.source = 'English.qml';
        anchors { top: returnButton.bottom; left: parent.left; leftMargin: 13; topMargin: 8 }
    }
    Button {
        width: 130; height: 50
        onClicked: keyboardLoader.source = 'English.qml';
        anchors { top: returnButton.bottom; left: numButton.right; leftMargin: 13; topMargin: 8 }
    }
}
