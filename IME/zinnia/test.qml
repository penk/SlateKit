import "org/slatekit/Zinnia"
import QtQuick 1.0

Item {

	width: 300
	height: 300

     Zinnia { 
         id: zinnia
     }

    Text { id: t }

	MouseArea {
		anchors.fill: parent
		onClicked: { console.log(zinnia.query(0, 65, 104)); 
                    t.text = zinnia.query(0, 205.14581599629005, 102);
         } 
	} 

}
