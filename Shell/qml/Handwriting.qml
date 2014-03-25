import QtQuick 2.0
import Fakekey 1.0
import Zinnia 1.0
import "../../IME/handwriting"
import "js/units.js" as Units

Rectangle {

    anchors.fill: parent
    color: "transparent"
    property variant candidates: [];

    Image {
        anchors.fill: parent
        source: "layout/handwriting2x.png"
    }

    Zinnia {
        id: zinnia
    }

    Fakekey { 
        id: fakekey
    }

    Writing { 
        anchors.left: backspaceButton.right 
        anchors.leftMargin: Units.dp(10);
        id:canvas
        width: Units.dp(360)
        height: Units.dp(220) 
    } 

    GridView { 
        id: selectionArea 
        interactive: false
        width: Units.dp(280); height: Units.dp(220); 
        cellWidth: Units.dp(140); cellHeight: Units.dp(60)
        anchors { left: canvas.right; top: parent.top; margins: Units.dp(10); }
        Component { 
            id: textDelegate
            Text { 
                width: Units.dp(140)
                font.pointSize: Units.dp(32)
                font.bold: true
                text: modelData 
                horizontalAlignment: Text.AlignHCenter
                MouseArea { 
                    width: Units.dp(140); height: Units.dp(60)
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
        width: Units.dp(130); height: Units.dp(50)
        onClicked: { keyboard.state = "hide" }
        anchors { top: parent.top; left: parent.left; leftMargin: Units.dp(13); topMargin: Units.dp(8) }  
    }
    Button {
        id: backspaceButton
        width: Units.dp(130); height: Units.dp(50)
        onClicked: { 
            if (candidates[0] !== undefined) { canvas.clear(); candidates = [] }
            else fakekey.sendKey(":backspace") 
        }
        anchors { top: parent.top; left: hideButton.right; leftMargin: Units.dp(13); topMargin: Units.dp(8) }
    }
    Button {
        id: spaceButton;
        width: Units.dp(275); height: Units.dp(50)
        onClicked: { fakekey.sendKey(' ') }
        anchors { top: hideButton.bottom; left: parent.left; leftMargin: Units.dp(13); topMargin: Units.dp(8) }
    }
    Button {
        id: returnButton;
        width: Units.dp(275); height: Units.dp(50)
        onClicked: { fakekey.sendKey(':enter') }
        anchors { top: spaceButton.bottom; left: parent.left; leftMargin: Units.dp(13); topMargin: Units.dp(8) }
    }
    Button {
        id: numButton
        width: Units.dp(130); height: Units.dp(50)
        onClicked: keyboardLoader.source = 'English.qml';
        anchors { top: returnButton.bottom; left: parent.left; leftMargin: Units.dp(13); topMargin: Units.dp(8) }
    }
    Button {
        width: Units.dp(130); height: Units.dp(50)
        onClicked: keyboardLoader.source = 'English.qml';
        anchors { top: returnButton.bottom; left: numButton.right; leftMargin: Units.dp(13); topMargin: Units.dp(8) }
    }
}
