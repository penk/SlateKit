# QML Handwriting Example

![qml-handwriting](https://raw.github.com/penk/SlateKit/master/IME/handwriting/screenshot.png)

Handwriting recognition software panel based on QML, Zinnia, ShortStrawJS and Tegaki

### Dependency

    sudo apt-get install libzinnia-dev tegaki-zinnia-traditional-chinese 
    cd ../zinnia 
    qmake && make && sudo make install 
    cd - 
    
### Test 

    qmlscene main.qml 
