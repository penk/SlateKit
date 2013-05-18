var custom_element_node;
var frames = document.documentElement.getElementsByTagName('iframe');

function checkNode(e, node) {
    // hook for Open in New Tab (link with target)
    if (node.tagName === 'A') {
        var link = new Object({'type':'link'})
        if (node.hasAttribute('target'))
            link.target = node.getAttribute('target');
        link.href = node.getAttribute('href');
        navigator.qt.postMessage( JSON.stringify(link) );
    }

    // custom dialog for select input element
    if (node.tagName === 'SELECT') {
        var select = new Object({'type':'select', 'text': [], 'pageX': e.pageX, 'pageY': e.pageY}); 
        select.offsetHeight = node.offsetHeight
        // FIXME: get WebView scale 
        //select.screenWidth = screen.width 
        //select.innerWidth = window.innerWidth
        for (var i=0; i < node.options.length; i++) {
            select.text.push(node.options[i].text);
            if (node.options[i].selected) {
                select.selected = node.options[i].text;
            }
        }
        navigator.qt.postMessage( JSON.stringify(select) );
        custom_element_node = node;
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
    switch (data.type) {
        case 'select': {
            if (custom_element_node !== undefined) {
                custom_element_node.options[data.index].selected = true 

                // trigger onchange event 
                var evt = document.createEvent("HTMLEvents");
                evt.initEvent("change", false, true);
                custom_element_node.dispatchEvent(evt);
            }
            break;
        }
    }
}

// FIXME: experiementing on tap and hold 
var hold;
function longPressed(x, y) { navigator.qt.postMessage('longpressed: '+x+', '+y) }
window.document.addEventListener('mousedown', (function(e) {
    //    hold = setTimeout(longPressed, 800, e.clientX, e.clientY); 
    //    navigator.qt.postMessage('mousedown: '+e.clientX+', '+e.clientY)
}), true);
window.document.addEventListener('mouseup', (function() {
    clearTimeout(hold); 
}), true);
