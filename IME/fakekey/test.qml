import QtQuick 2.0
import Fakekey 1.0

// QML_IMPORT_TRACE=1 qmlscene test.qml -I . 

Item {

	width: 300
	height: 300

     Fakekey { 
         id: keyboard
     }

    TextInput { id: t; text: "let's see"; anchors.fill: parent }

	MouseArea {
		anchors.fill: parent
		onPressed: { mouse.accepted = true; t.focus = true;
			keyboard.sendKey(':backspace');
			keyboard.sendKey(':backspace');
			keyboard.sendKey(':backspace');

			keyboard.sendKey('r');
			keyboard.sendKey('o');
			keyboard.sendKey('c');
			keyboard.sendKey('k');
			keyboard.sendKey(':enter');
		}
	} 

}
