import QtQuick 2.0
import Fakekey 1.0 
//download and install from: https://github.com/penk/SlateKit/tree/master/IME/fakekey

Rectangle { 

    property bool isShifted: false
    property bool inNumView: false
    property bool inPunView: false

    Image {
        anchors { left: parent.left; top: parent.top }
        source: if (!inNumView && !inPunView && !isShifted) 'layout/english.png' 
        else if (inPunView) 'layout/punctuation.png'
        else if (inNumView) 'layout/numeric.png'
        else 'layout/capslock.png'
    }

    Fakekey { id: fakekey } 
    //Item { id: fakekey; function sendKey(s) {console.log(s)} }

    Row { 
        id: row1
        anchors { top: parent.top; left: parent.left; leftMargin: 13; topMargin: 8 }
        spacing: 11
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
        anchors { top: row1.bottom; left: parent.left; leftMargin: 50; topMargin: 8 }
        spacing: 12
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
        Button { width: 116; onClicked: fakekey.sendKey(':enter') }
    }

    Row { 
        id: row3
        visible: !inNumView && !inPunView 
        anchors { top: row2.bottom; left: parent.left; leftMargin: 13; topMargin: 8 }
        spacing: 12
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
        Button { width: 66; onClicked: { if (isShifted) {fakekey.sendKey('!')} else {fakekey.sendKey(',')} } } 
        Button { width: 66; onClicked: { if (isShifted) {fakekey.sendKey('?')} else {fakekey.sendKey('.')} } }
        Button { width: 85; onClicked: { isShifted = !isShifted;} }
    }

    Row {
        id: row3_num
        visible: !isShifted && inNumView && !inPunView 
        anchors { top: row2.bottom; left: parent.left; leftMargin: 13; topMargin: 8 }
        spacing: 12
        Button { onClicked: { inNumView = false; inPunView = true; } }
        Button { width: 162; onClicked: console.log('undo') }
        Repeater {
            model: [ ".", ",", "?", "!", "'" ]
            Button { onClicked: fakekey.sendKey(modelData[0]) } 
        }
        Button { width: 66; onClicked: fakekey.sendKey('"')}
        Button { type: "block"; width: 65 }
        Button { width: 84; onClicked: {inNumView = false; inPunView = true;} }
    }

    Row {
        id: row3_pun
        visible: !isShifted && !inNumView && inPunView 
        anchors { top: row2.bottom; left: parent.left; leftMargin: 13; topMargin: 8 }
        spacing: 12
        Button { onClicked: { inNumView = true; inPunView = false; } }
        Button { width: 162; onClicked: console.log('redo') }
        Repeater {
            model: [ ".", ",", "?", "!", "'" ]
            Button { onClicked: fakekey.sendKey(modelData[0]) }
        }
        Button { width: 66; onClicked: fakekey.sendKey('"')}
        Button { type: "block"; width: 65 }
        Button { width: 84; onClicked: { inNumView = true; inPunView = false;} }
    }

    Row {
        id: row4
        anchors { top: row3.bottom; left: parent.left; leftMargin: 12; topMargin: 8 }
        spacing: 12
        Button { 
            width: 150; 
            onClicked: { 
                isShifted = false; 
                if (inPunView) { inPunView = false; inNumView=false;} else {inNumView = !inNumView}; 
            }
        }
        Button { width: 91; onClicked: keyboardLoader.source = 'Handwriting.qml'}
        Button { width: 422; onClicked: fakekey.sendKey(' ') }
        Button { 
            width: 150
            onClicked: { 
                isShifted = false; 
                if (inPunView) {inPunView=false; inNumView=false; } else { inNumView = !inNumView }; 
            }
        }
        Button { onClicked: { keyboard.state = "hide" } }
    }
}
