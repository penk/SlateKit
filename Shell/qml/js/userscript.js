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

function longPressed(x, y, element) { 
    longpressDetected = true; 
    //var element = document.elementFromPoint(x, y);

    // FIXME: should travel nodes to find links
    var data = new Object({'type': 'longpress', 'pageX': x, 'pageY': y})
    data.href = 'CANT FIND LINK'
    if (element.tagName === 'A') { 
        data.href = element.getAttribute('href');
    } else if (element.parentNode.tagName === 'A') { 
        data.href = element.parentNode.getAttribute('href');
    } 
/*
        var node = element.cloneNode(true);
        while(node) {
                if (node.tagName === 'A') { data.href = node.getAttribute('href'); } 
                node = node.parentNode;
        }
*/
    if (element.hasChildNodes()) {
        var children = element.childNodes;
        for (var i = 0; i < children.length; i++) {
            if(children[i].tagName === 'A') 
                data.href = children[i].getAttribute('href');
        }
    }
    navigator.qt.postMessage( JSON.stringify(data) );
}
document.addEventListener('touchstart', (function(event) {
    if (event.touches.length == 1) {
        currentTouch = event.touches[0];
        hold = setTimeout(longPressed, 800, currentTouch.clientX, currentTouch.clientY, event.target);
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


function distance(touch1, touch2) {
    return Math.sqrt(Math.pow(touch2.clientX - touch1.clientX, 2) +
                     Math.pow(touch2.clientY - touch1.clientY, 2));
}

document.addEventListener('touchmove', (function(event) {
    if ((event.changedTouches.length > 1) || (distance(event.changedTouches[0], currentTouch) > 3)) {
        clearTimeout(hold);
        currentTouch = null;
    }
}), true);