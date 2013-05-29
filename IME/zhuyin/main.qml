import QtQuick 2.0
import "lib/script.js" as JS

Item {
    id:root
    width: 600 
    height: 120
    property variant candidates: [];

    Component.onCompleted: JS.loadJSON();

    TextInput { 
        id: t
        anchors { top: parent.top; left: parent.left; margins: 10} 
        width: 300; 
        height: 40;
        font.pointSize: 30
        text: "input here"
        onTextChanged: { 
            var result = JS.query(t.text);
            if (result !== undefined) {
                candidates = result.map( function(i) { return i[0] });
                console.log(candidates);
            } else { candidates = [] } 
        }
    }

    ListView {
        id:view
        orientation: ListView.Horizontal;
        width: parent.width
        height: 80;
        anchors { top: t.bottom; left: parent.left } 
        model: candidates;  
        delegate: Rectangle {
            width:40
            height:80
            Text {
                anchors.fill: parent;
                anchors.margins: 5
                font.pointSize: 30
                text: modelData 
            }
        }
    }
}
