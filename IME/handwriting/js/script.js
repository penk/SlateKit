var myArray = new Array();

function getList() {
    return myArray
}

function addItem(x, y) {
    myArray.push({'x':x, 'y':y})
}

function clear() {
    myArray = [];
}
