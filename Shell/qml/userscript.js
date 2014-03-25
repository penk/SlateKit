window.document.addEventListener('click', (function(e) {
	if (e.srcElement.tagName.toLowerCase() === ('input'||'textarea')) {
		var inputContext = new Object({'type': 'input', 'state': 'show'})
		oxide.sendMessage('inputmethod', inputContext)
	}
}), true);

window.document.addEventListener('focus', (function(e) {
	if (e.srcElement.tagName.toLowerCase() === ('input'||'textarea')) {
		var inputContext = new Object({'type': 'input', 'state': 'show'})
		oxide.sendMessage('inputmethod', inputContext)
	}
}), true);

window.document.addEventListener('blur', (function(e) {
	var inputContext = new Object({'type': 'input', 'state': 'hide'})
	oxide.sendMessage('inputmethod', inputContext)
}), true);
