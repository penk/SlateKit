import "net/sourceforge/cmusphinx"
import QtQuick 1.0

Item {

property variant state: 1
width: 400
height: 300

    PocketSphinx {
	id: sphinx
	onRecognitionResultChanged: { input.text = input.text + result + "\n"; }
    }

    TextEdit { id: input; text: "PocketSphinx QML DEMO: \n\n"; 
	wrapMode: TextEdit.WordWrap; width: 300; anchors.left: parent.left; }

    Rectangle {
	border.color: "grey"; 
	width: 100
	height: 30
	anchors.right: parent.right;
	anchors.top: parent.top;
	anchors.margins: 10;

	Text { id: t; text: "Started" }
	    MouseArea { anchors.fill: parent; 
		onClicked: { 
			if (state==1) { sphinx.pause(); state = 0; t.text = "Paused"; } 
			else { sphinx.start(); state = 1; t.text = "Started"; } 
		}
	    }
	} 

}
