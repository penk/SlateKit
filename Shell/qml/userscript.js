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
