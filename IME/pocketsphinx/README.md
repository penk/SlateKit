## PocketSphinx QML plugin

![pocketsphinx-qml](https://raw.github.com/penk/SlateKit/master/IME/pocketsphinx/screenshot.png)

### Dependencies 

    sudo apt-get install libqtgstreamer-0.10-0 libqtgstreamerutils-0.10-0 \
    libqtgstreamerui-0.10-0 qtgstreamer-plugins libgstreamer0.10-dev libqtgstreamer-dev \
    gstreamer0.10-pocketsphinx pocketsphinx-lm-wsj pocketsphinx-hmm-wsj1 \
    qt4-qmlviewer

### Compilation 

    qmake-qt4 -r 
    make

### Test

    qmlviewer test.qml
