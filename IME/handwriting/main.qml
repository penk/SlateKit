import QtQuick 2.0 
import Zinnia 1.0

Rectangle {

	width: 300
	height: 330 
	color: "#D0D4D8"
	property variant candidates: [];

	ListView { 
		orientation: ListView.Horizontal;
		width: 250; height: 30; 
		anchors { leftMargin: 10; left: parent.left; } 
		spacing: 10;
		Component { 
			id: textDelegate
			Text { 
				font.pointSize: 20
				text: modelData 
				MouseArea { 
					anchors.fill: parent; 
					onClicked: { console.log('sendKey: '+ modelData); 
						parent.color = "red";
					}
				}
			} 
		}
		model: candidates; 
		delegate: textDelegate;
	} 

	Zinnia { id: zinnia }

	Writing { 
		anchors.topMargin: 30;
		id:canvas
		anchors.fill: parent
	} 

	Rectangle { 
		width: 50; height: 30; 
		anchors { top: parent.top; right: parent.right }
		MouseArea { anchors.fill: parent; onClicked: canvas.clear(); }
		Text { text: "clear"; font.pointSize: 20 }
	}

}