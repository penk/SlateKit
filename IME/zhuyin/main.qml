import QtQuick 2.0
import "lib/script.js" as JS

Item {
    id:root
    width: 600 
    height: 120
    property variant candidates: [];
    property variant lastTerm: "";
    property variant longestCommonTerms: "";

    Component.onCompleted: JS.loadJSON();

    TextInput { 
        id: t
        anchors { top: parent.top; left: parent.left; margins: 10} 
        width: 300; 
        height: 40;
        font.pointSize: 30
        text: "input here"
        onTextChanged: { 
            var input = t.text;
            if (input == "") lastTerm = longestCommonTerms = "";
            var syllablesInBuffer = [];
            if (input.search(/[ 3467]/) !== -1)
                syllablesInBuffer = input.match(/.+?[ 3467]/g);
            var last = input.split(/[ 3467]/)[input.split(/[ 3467]/).length -1 ]
            if (last !== "") syllablesInBuffer.push(last);
                
            var result;
            var candList = [''];
    
            do {
                result = JS.getTerms(syllablesInBuffer.join(''));
                if (result) {
                    candList.shift();
                    result.map( function(i) { candList.push(i[0]) });
                    console.log(candList);
                }

                //if (candList[0].length == lastTerm.length) {
                //    lastTerm = candList[0]; // update term with the same length  
                //} else 
                if (result == false || candList[0].length <= lastTerm.length) {
                    //longestCommonTerms += lastTerm; //XXX: time to clean? multiple popout 
                    console.log('\tPop out: ' + lastTerm);  
                    var i = lastTerm.length || 1;
                    while(i--)
                        syllablesInBuffer.shift();
                    if (syllablesInBuffer.length > lastTerm.length) {
                        lastTerm = "";
                    } 
                } else {
                    lastTerm = candList[0];
                }

                candidates = candList; 
            } while (syllablesInBuffer.length > 0)
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
            width: modelData.length * 40
            height: 80
            Text {
                id: text
                font.pointSize: 30
                text: modelData 
            }
        }
    }
}
