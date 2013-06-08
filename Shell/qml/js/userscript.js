var frames = document.documentElement.getElementsByTagName('iframe');

function checkNode(e, node) {
    // hook for Open in New Tab (link with target)
    if (node.tagName === 'A') {
        var link = new Object({'type':'link', 'pageX': e.pageX, 'pageY': e.pageY})
        if (node.hasAttribute('target'))
            link.target = node.getAttribute('target');
        link.href = node.getAttribute('href');
        navigator.qt.postMessage( JSON.stringify(link) );
    }
}

for (var i=0; i<frames.length; i++) {
    if(typeof(frames[i].contentWindow.document)!=="undefined") 
    frames[i].contentWindow.document.addEventListener('click', (function(e) { 
        var node = e.target; 
        while(node) { 
            checkNode(e, node);
            node = node.parentNode; 
        } 
    }), true);
}

// virtual keyboard hook
window.document.addEventListener('click', (function(e) { 
    if (e.srcElement.tagName === ('INPUT'||'TEXTAREA')) {
        var inputContext = new Object({'type':'input', 'state':'show'})
        navigator.qt.postMessage(JSON.stringify(inputContext))
    }
}), true); 
window.document.addEventListener('focus', (function() { 
    if (e.srcElement.tagName === ('INPUT'||'TEXTAREA')) {
        var inputContext = new Object({'type':'input', 'state':'show'})
        navigator.qt.postMessage(JSON.stringify(inputContext))
    }
}), true);
window.document.addEventListener('blur', (function() {
    var inputContext = new Object({'type':'input', 'state':'hide'})
    navigator.qt.postMessage(JSON.stringify(inputContext))
}), true);

document.documentElement.addEventListener('click', (function(e) {
    var node = e.target;
    while(node) {
        checkNode(e, node);
        node = node.parentNode;
    }
}), true);

navigator.qt.onmessage = function(ev) {
    var data = JSON.parse(ev.data)
    if (data.type == 'readability') {

        readStyle='style-novel';
        readSize='size-large';
        readMargin='margin-wide';

        _readability_script = document.createElement('SCRIPT');
        _readability_script.type = 'text/javascript';
        _readability_script.text = data.content;
        document.getElementsByTagName('head')[0].appendChild(_readability_script);
    }
}

// FIXME: experiementing on tap and hold 
var hold;
var longpressDetected = false; 
var currentTouch = null;

function longPressed(x, y) { 
    longpressDetected = true; 
    var element = document.elementFromPoint(x, y);

    // FIXME: should travel nodes to find links
    if (element.tagName === 'A') { 
            var data = new Object({'type': 'longpress', 'pageX': x, 'pageY': y})
            data.href = element.getAttribute('href');
            navigator.qt.postMessage( JSON.stringify(data) );
        }
}
document.addEventListener('touchstart', (function(currentTouchevent) {
    if (event.touches.length == 1) {
            currentTouch = event.touches[0];
            hold = setTimeout(longPressed, 800, currentTouch.clientX, currentTouch.clientY);
        }
}), true);

document.addEventListener('touchend', (function(event) {
    if (longpressDetected) {
            longpressDetected = false
            event.preventDefault();
        }
    currentTouch = null;
    clearTimeout(hold); 
}), true);
