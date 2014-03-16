/*
 * Copyright 2013-2014 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

function elementContainedInBox(element, box) {
    var rect = element.getBoundingClientRect();
    return ((box.left <= rect.left) && (box.right >= rect.right) &&
            (box.top <= rect.top) && (box.bottom >= rect.bottom));
}

function getImgFullUri(uri) {
    if ((uri.slice(0, 7) === 'http://') ||
        (uri.slice(0, 8) === 'https://') ||
        (uri.slice(0, 7) === 'file://')) {
        return uri;
    } else if (uri.slice(0, 1) === '/') {
        var docuri = document.documentURI;
        var firstcolon = docuri.indexOf('://');
        var protocol = 'http://';
        if (firstcolon !== -1) {
            protocol = docuri.slice(0, firstcolon + 3);
        }
        return protocol + document.domain + uri;
    } else {
        var base = document.baseURI;
        var lastslash = base.lastIndexOf('/');
        if (lastslash === -1) {
            return base + '/' + uri;
        } else {
            return base.slice(0, lastslash + 1) + uri;
        }
    }
}

function getSelectedData(element) {
    var node = element;
    var data = new Object;

    var nodeName = node.nodeName.toLowerCase();
    if (nodeName === 'img') {
        data.img = getImgFullUri(node.getAttribute('src'));
    } else if (nodeName === 'a') {
        data.href = node.href;
        data.title = node.title;
    }

    // If the parent tag is a hyperlink, we want it too.
    var parent = node.parentNode;
    if ((nodeName !== 'a') && parent && (parent.nodeName.toLowerCase() === 'a')) {
        data.href = parent.href;
        data.title = parent.title;
        node = parent;
    }

    var boundingRect = node.getBoundingClientRect();
    data.left = boundingRect.left;
    data.top = boundingRect.top;
    data.width = boundingRect.width;
    data.height = boundingRect.height;

    node = node.cloneNode(true);
    // filter out script nodes
    var scripts = node.getElementsByTagName('script');
    while (scripts.length > 0) {
        var scriptNode = scripts[0];
        if (scriptNode.parentNode) {
            scriptNode.parentNode.removeChild(scriptNode);
        }
    }
    data.html = node.outerHTML;
    data.nodeName = node.nodeName.toLowerCase();
    // FIXME: extract the text and images in the order they appear in the block,
    // so that this order is respected when the data is pushed to the clipboard.
    data.text = node.textContent;
    var images = [];
    var imgs = node.getElementsByTagName('img');
    for (var i = 0; i < imgs.length; i++) {
        images.push(getImgFullUri(imgs[i].getAttribute('src')));
    }
    if (images.length > 0) {
        data.images = images;
    }

    return data;
}

function adjustSelection(selection) {
    // FIXME: allow selecting two consecutive blocks, instead of
    // interpolating to the containing block.
    var centerX = (selection.left + selection.right) / 2;
    var centerY = (selection.top + selection.bottom) / 2;
    var element = document.elementFromPoint(centerX, centerY);
    var parent = element;
    while (elementContainedInBox(parent, selection)) {
        parent = parent.parentNode;
    }
    element = parent;
    return getSelectedData(element);
}

function distance(touch1, touch2) {
    return Math.sqrt(Math.pow(touch2.clientX - touch1.clientX, 2) +
                     Math.pow(touch2.clientY - touch1.clientY, 2));
}

/*navigator.qt.onmessage = function(message) {
    var data = null;
    try {
        data = JSON.parse(message.data);
    } catch (error) {
        return;
    }
    if ('query' in data) {
        if (data.query === 'adjustselection') {
            var selection = adjustSelection(data);
            selection.event = 'selectionadjusted';
            navigator.qt.postMessage(JSON.stringify(selection));
        }
    }
}*/

document.documentElement.addEventListener('contextmenu', function(event) {
    var element = document.elementFromPoint(event.clientX, event.clientY);
    var data = getSelectedData(element);
    var w = document.defaultView;
    data['scaleX'] = w.outerWidth / w.innerWidth * w.devicePixelRatio;
    data['scaleY'] = w.outerHeight / w.innerHeight * w.devicePixelRatio;
    oxide.sendMessage('contextmenu', data);
});

document.defaultView.addEventListener('scroll', function(event) {
    oxide.sendMessage('scroll', {});
});
