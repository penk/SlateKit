document.documentElement.addEventListener('click', (function(e) {
    var node = e.target;
    while(node) {
        // hook for Open in New Tab (link with target)
        if (node.tagName === 'A') {
            var link = new Object
            link.type = 'link'
            if (node.hasAttribute('target'))
                link.target = node.getAttribute('target');
            link.href = node.getAttribute('href');
            navigator.qt.postMessage( JSON.stringify(link) );
        }

        // custom dialog for select input element
        if (node.tagName === 'SELECT') {
            var select = new Object; 
            select.type = 'select';
            select.text = [''];
            select.value = [''];
            for (var i=0; i < node.options.length; i++) {
                select.text.push(node.options[i].text);
                select.value.push(node.options[i].value); 
            }
            navigator.qt.postMessage( JSON.stringify(select));
        }

        node = node.parentNode;
    }
}), true);


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
