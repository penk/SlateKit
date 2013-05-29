var jsonData = {};
var zhuyinMapping = {
    ',':'ㄝ',
    '-':'ㄦ',
    '.':'ㄡ',
    '/':'ㄥ',
    '0':'ㄢ',
    '1':'ㄅ',
    '2':'ㄉ',
    '3':'ˇ',
    '4':'ˋ',
    '5':'ㄓ',
    '6':'ˊ',
    '7':'˙',
    '8':'ㄚ',
    '9':'ㄞ',
    ';':'ㄤ',
    'a':'ㄇ',
    'b':'ㄖ',
    'c':'ㄏ',
    'd':'ㄎ',
    'e':'ㄍ',
    'f':'ㄑ',
    'g':'ㄕ',
    'h':'ㄘ',
    'i':'ㄛ',
    'j':'ㄨ',
    'k':'ㄜ',
    'l':'ㄠ',
    'm':'ㄩ',
    'n':'ㄙ',
    'o':'ㄟ',
    'p':'ㄣ',
    'q':'ㄆ',
    'r':'ㄐ',
    's':'ㄋ',
    't':'ㄔ',
    'u':'ㄧ',
    'v':'ㄒ',
    'w':'ㄊ',
    'x':'ㄌ',
    'y':'ㄗ',
    'z':'ㄈ'
};

function query(str) {
    return jsonData[ [].map.call( str, function(i) { return zhuyinMapping[i] }).join('') ];
}

function loadJSON() {
    var xhr = new XMLHttpRequest();
    var response;
    xhr.open("GET", "./words.json", true); 
    xhr.onreadystatechange = function()
    {
        if ( xhr.readyState == xhr.DONE) {
            try { response = JSON.parse(xhr.responseText); } catch (e) { console.error(e) } 
            if (typeof response !== 'object') { console.log('Failed to load words.json: Malformed JSON'); }
            for (var s in response) { jsonData[s] = response[s]; }
        }
    }
    xhr.send();
/*
    xhr.open("GET", "./phrases.json", true);
    xhr.onreadystatechange = function()
    {
        if ( xhr.readyState == xhr.DONE) {
            try {  response = JSON.parse(xhr.responseText); } catch (e) { console.error(e) }
            if (typeof response !== 'object') {  onsole.log('Failed to load phrases.json: Malformed JSON'); }
            for (var s in response) { jsonData[s] = response[s]; }
            console.log('JSON loaded');
        }
    }
    xhr.send();
*/
}
