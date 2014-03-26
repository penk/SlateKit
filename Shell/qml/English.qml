import QtQuick 2.0
import Fakekey 1.0 
import QtQuick.Window 2.0
import "js/units.js" as Units 
//download and install from: https://github.com/penk/SlateKit/tree/master/IME/fakekey

Rectangle { 

    property bool isShifted: false
    property bool inNumView: false
    property bool inPunView: false
    property bool isPortrait: (Screen.orientation == 1|| Screen.orientation == 4)

    Image {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
        source: 
        if (!inNumView && !inPunView && !isShifted) { 
            isPortrait ? 
            'layout/english2x-portrait.png' : 
            'layout/english2x.png' 
        }
        else if (inPunView) { 
            isPortrait ? 
            'layout/punctuation2x-portrait.png' : 
            'layout/punctuation2x.png' 
        } 
        else if (inNumView) { 
            isPortrait? 
            'layout/numeric2x-portrait.png' :
            'layout/numeric2x.png' 
        }
        else { 
            isPortrait? 
            'layout/capslock2x-portrait.png' : 
            'layout/capslock2x.png'
        }
    }

    Fakekey { id: fakekey } 
    //Item { id: fakekey; function sendKey(s) {console.log(s)} }

    Row { 
        id: row1
        anchors { top: parent.top; left: parent.left; leftMargin: isPortrait ? Units.dp(8) : Units.dp(13); topMargin: isPortrait ? Units.dp(5) : Units.dp(8) }
        spacing: isPortrait ? Units.dp(7) : Units.dp(11)
        Repeater {
            model: ["q1[", "w2]", "e3{", "r4}", "t5#", "y6%", "u7^", "i8*", "o9+", "p0="]
            Button { 
                onClicked: {
                    if (isShifted) { fakekey.sendKey(modelData[0][0].toUpperCase())} 
                    else if (inNumView) { fakekey.sendKey(modelData[1][0]) }
                    else if (inPunView) { fakekey.sendKey(modelData[2][0]) }
                    else { fakekey.sendKey(modelData[0][0]); }
                }
            }
        }
        Button { onClicked: fakekey.sendKey(':backspace')}
    }

    Row {
        id: row2 
        anchors { top: row1.bottom; left: parent.left; leftMargin: isPortrait ? Units.dp(31) : Units.dp(50); topMargin: isPortrait ? Units.dp(4.5) : Units.dp(8) }
        spacing: isPortrait ? Units.dp(7.5) : Units.dp(12)
        Repeater {
            model: ["a-_", "s/\\", "d:|", "f;~", "g(<", "h)>", "j$€", "k&£", "l@¥"]
            Button {
                onClicked: {
                    if (isShifted) { fakekey.sendKey(modelData[0][0].toUpperCase())}
                    else if (inNumView) { fakekey.sendKey(modelData[1][0]) }
                    else if (inPunView) { fakekey.sendKey(modelData[2][0]) }
                    else { fakekey.sendKey(modelData[0][0]); }
                }
            }
        }
        Button { width: isPortrait ? Units.dp(72.5) : Units.dp(116); onClicked: fakekey.sendKey(':enter') }
    }

    Row { 
        id: row3
        visible: !inNumView && !inPunView 
        anchors { top: row2.bottom; left: parent.left; leftMargin: isPortrait ? Units.dp(8) : Units.dp(13); topMargin: isPortrait ? Units.dp(4.5) : Units.dp(8) }
        spacing: isPortrait ? Units.dp(7.5) : Units.dp(12)
        Button { onClicked: { isShifted = !isShifted; } }
        Repeater {
            model: [ "z", "x", "c", "v", "b", "n", "m" ]
            Button {
                onClicked: {
                    if (isShifted) { fakekey.sendKey(modelData[0].toUpperCase()) }
                    else { fakekey.sendKey(modelData[0])} 
                }
            }
        }
        Button { width: isPortrait ? Units.dp(41) : Units.dp(66); onClicked: { if (isShifted) {fakekey.sendKey('!')} else {fakekey.sendKey(',')} } } 
        Button { width: isPortrait ? Units.dp(41) : Units.dp(66); onClicked: { if (isShifted) {fakekey.sendKey('?')} else {fakekey.sendKey('.')} } }
        Button { width: isPortrait ? Units.dp(53) : Units.dp(85); onClicked: { isShifted = !isShifted;} }
    }

    Row {
        id: row3_num
        visible: !isShifted && inNumView && !inPunView 
        anchors { top: row2.bottom; left: parent.left; leftMargin: isPortrait ? Units.dp(8) : Units.dp(13); topMargin: isPortrait ? Units.dp(4.5) : Units.dp(8) }
        spacing: isPortrait ? Units.dp(7.5) : Units.dp(12)
        Button { onClicked: { inNumView = false; inPunView = true; } }
        Button { width: isPortrait ? Units.dp(101) :Units.dp(162); onClicked: console.log('undo') }
        Repeater {
            model: [ ".", ",", "?", "!", "'" ]
            Button { onClicked: fakekey.sendKey(modelData[0]) } 
        }
        Button { width: isPortrait ? Units.dp(41) : Units.dp(66); onClicked: fakekey.sendKey('"')}
        Button { type: "block"; width: isPortrait ? Units.dp(40) : Units.dp(65) }
        Button { width: isPortrait ? Units.dp(52.5) : Units.dp(84); onClicked: {inNumView = false; inPunView = true;} }
    }

    Row {
        id: row3_pun
        visible: !isShifted && !inNumView && inPunView 
        anchors { top: row2.bottom; left: parent.left; leftMargin: isPortrait ? Units.dp(8) : Units.dp(13); topMargin: isPortrait ? Units.dp(4.5) : Units.dp(8) }
        spacing: isPortrait ? Units.dp(7.5) : Units.dp(12)
        Button { onClicked: { inNumView = true; inPunView = false; } }
        Button { width: isPortrait ? Units.dp(101) : Units.dp(162); onClicked: console.log('redo') }
        Repeater {
            model: [ ".", ",", "?", "!", "'" ]
            Button { onClicked: fakekey.sendKey(modelData[0]) }
        }
        Button { width: isPortrait ? Units.dp(41) : Units.dp(66); onClicked: fakekey.sendKey('"')}
        Button { type: "block"; width: isPortrait ? Units.dp(40) : Units.dp(65) }
        Button { width: isPortrait ? Units.dp(52.5) : Units.dp(84); onClicked: { inNumView = true; inPunView = false;} }
    }

    Row {
        id: row4
        anchors { top: row3.bottom; left: parent.left; leftMargin: isPortrait ? Units.dp(7.5) : Units.dp(12); topMargin: isPortrait ? Units.dp(5) : Units.dp(8) }
        spacing: isPortrait ? Units.dp(7.5) : Units.dp(12)
        Button { 
            width: isPortrait ? Units.dp(93.5) : Units.dp(150); 
            onClicked: { 
                isShifted = false; 
                if (inPunView) { inPunView = false; inNumView=false;} else {inNumView = !inNumView}; 
            }
        }
        Button { width: isPortrait ? Units.dp(57) : Units.dp(91); onClicked: keyboardLoader.source = 'Handwriting.qml'}
        Button { width: isPortrait ? Units.dp(263.5) : Units.dp(422); onClicked: fakekey.sendKey(' ') }
        Button { 
            width: isPortrait ? Units.dp(93.7) : Units.dp(150)
            onClicked: { 
                isShifted = false; 
                if (inPunView) {inPunView=false; inNumView=false; } else { inNumView = !inNumView }; 
            }
        }
        Button { onClicked: { keyboard.state = "hide" } }
    }
}
