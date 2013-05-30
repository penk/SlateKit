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

function getTerms(str) {
    var syllablesStr = [].map.call(str, function(i) { 
        switch(i) { 
            case ' ': 
                return '-'; 
                break;
            case '3':
            case '4': 
            case '6':
            case '7':
                return zhuyinMapping[i]+'-';
                break;
            default: 
                return zhuyinMapping[i];
        }
    }).join('');

    syllablesStr = syllablesStr.replace(/\-$/, '');
    console.log('Get terms for ' + syllablesStr + '.');
    return jsonData[ syllablesStr ];
}

function loadJSON() {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "./words.json", true); 
    xhr.onreadystatechange = function()
    {
        if ( xhr.readyState == xhr.DONE) {
            var response;
            try { response = JSON.parse(xhr.responseText); } catch (e) { console.error(e) } 
            if (typeof response !== 'object') { console.log('Failed to load words.json: Malformed JSON'); }
            for (var s in response) { jsonData[s] = response[s]; }
        }
    }
    xhr.send();

    var pxhr = new XMLHttpRequest();
    pxhr.open("GET", "./phrases.json", true);
    pxhr.onreadystatechange = function()
    {
        if (pxhr.readyState == xhr.DONE) {
            var response;
            try { response = JSON.parse(pxhr.responseText); } catch (e) { console.error(e) }
            if (typeof response !== 'object') {  onsole.log('Failed to load phrases.json: Malformed JSON'); }
            for (var s in response) { 
                jsonData[s] = response[s]; 
            }
            console.log('JSON loaded');
        }
    }
    pxhr.send();
}
