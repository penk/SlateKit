var custom_element_node;

document.documentElement.addEventListener('click', (function(e) {
    var node = e.target;
    while(node) {
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
            for (var i=0; i < node.options.length; i++) {
                select.text.push(node.options[i].text);
                if (node.options[i].hasAttribute('selected')) { // FIXME: mark selected option
                    select.selected = node.options[i].text;
                }
            }
            navigator.qt.postMessage( JSON.stringify(select) );
            custom_element_node = node;
        }

        node = node.parentNode;
    }
}), true);

navigator.qt.onmessage = function(ev) {
    var data = JSON.parse(ev.data)
    switch (data.type) {
        case 'select': {
            if (custom_element_node !== undefined)
                custom_element_node.options[data.index].selected = true 
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
