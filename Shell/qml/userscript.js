document.documentElement.addEventListener('click', (function(e) {
    var node = e.target;
    while(node) {
        if (node.tagName === 'A') {
            var link = new Object
            link.type = 'link'
            if (node.hasAttribute('target'))
                link.target = node.getAttribute('target');
            link.href = node.getAttribute('href');
            navigator.qt.postMessage( JSON.stringify(link) );
        }
        node = node.parentNode;
    }
}), true);

var hold;
function longPressed(x, y) { navigator.qt.postMessage('longpressed: '+x+', '+y) }
window.document.addEventListener('mousedown', (function(e) {
//    hold = setTimeout(longPressed, 800, e.clientX, e.clientY); 
    navigator.qt.postMessage('mousedown: '+e.clientX+', '+e.clientY)
}), true);
window.document.addEventListener('mouseup', (function() {
    clearTimeout(hold); 
}), true);
