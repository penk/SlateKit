import "../../Canvas"
import QtQuick 1.0 

import "js/shortstraw.js" as Straw
import "js/script.js" as Script

import "org/slatekit/Zinnia/"

Canvas {
    id:canvas
    color: "#D0D4D8"

    property int paintX
    property int paintY
    property int count: 0
    property int lineWidth: 5
    property variant drawColor: "black"
    property variant ctx: getContext("2d");

    property int strokes: 0

    Zinnia { 
         id: zinnia
    }

    MouseArea {
        id:mousearea
        hoverEnabled:true
        anchors.fill: parent
        onClicked: drawPoint();
        onPositionChanged:  {
            if (mousearea.pressed) {
                drawLineSegment();
                Script.addItem(mouseX, mouseY);
            }
            paintX = mouseX;
            paintY = mouseY;

        }

        onReleased: {
            var array = Straw.shortStraw(Script.getList());

            ctx.beginPath();
            ctx.strokeStyle = 'red';
            ctx.moveTo(array[0].x, array[0].y);
            ctx.lineWidth = 2;
            for (var i = 0; i < array.length; i++) {
                console.log("strokes "+strokes+": " + array[i].x + ", "+ array[i].y );
                if (i>0) ctx.lineTo(array[i].x, array[i].y);
                var resultString = zinnia.query(strokes, array[i].x, array[i].y);
                resultArray = resultString.split("");

                // FIXME: use for loop ..
                text1.text = resultArray[0];
                text2.text = resultArray[2];
                text3.text = resultArray[4];
                text4.text = resultArray[6];
                text5.text = resultArray[8];
                text6.text = resultArray[10];
                text7.text = resultArray[12];
                text8.text = resultArray[14];
            }

            ctx.stroke();
            ctx.closePath();

            Script.clear();
            strokes++;
        }
    }

    function drawLineSegment() {
        ctx.beginPath();
        ctx.strokeStyle = drawColor
        ctx.lineWidth = lineWidth
        ctx.moveTo(paintX, paintY);
        ctx.lineTo(mousearea.mouseX, mousearea.mouseY);
        ctx.stroke();
        ctx.closePath();
    }

    function drawPoint() {
        ctx.lineWidth = lineWidth
        ctx.fillStyle = drawColor
        ctx.fillRect(mousearea.mouseX, mousearea.mouseY, 2, 2);
    }

    function clear() {
        strokes=0;
        text1.text = "";
        text2.text = "";
        text3.text = "";
        text4.text = "";
        text5.text = "";
        text6.text = "";
        text7.text = "";
        text8.text = "";

        // FIXME: if already cleared, delete last character in input box 
        zinnia.clear();
        ctx.clearRect(0, 0, width, height);
    }
}
