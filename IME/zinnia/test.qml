import QtQuick 2.0
import Zinnia 1.0

// QML_IMPORT_TRACE=1 qmlscene test.qml -I . 

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
