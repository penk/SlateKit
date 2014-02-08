import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0
import QtQuick.Window 2.0

import QtWebKit 3.0
import QtWebKit.experimental 1.0
import "js/script.js" as Tab 

Window {
    id: root 
    height: 600; width: 960
    visible: true
    property string currentTab: ""
    property bool hasTabOpen: (tabModel.count !== 0) && (typeof(Tab.itemMap[currentTab]) !== "undefined")
    property bool readerMode: false 

    FontLoader { id: fontAwesome; source: "icons/fontawesome-webfont.ttf" }  

    Component.onCompleted: {
        var db = getDatabase(); 
        if (Tab.ReopenPreviousTab) {
            db.transaction(
                function(tx) {
                    var result = tx.executeSql("SELECT * FROM previous"); 
                    for (var i=0; i < result.rows.length; i++) {
                        // FIXME: favicon doesn't display when re-open 
                        console.log('open previous closed page: ' + result.rows.item(i).url)
                        openNewTab('page-'+salt(), result.rows.item(i).url)
                    }
                    // FIXME: should match opened urls, not just drop 
                    tx.executeSql("DROP TABLE IF EXISTS previous");
                }
            );
        }
        bounce.start()
    }
    Component.onDestruction: { 
        var db = getDatabase(); 
        if (Tab.ReopenPreviousTab) {
            for (var openedUrl in Tab.itemMap) {
                db.transaction(
                    function(tx) { 
                        tx.executeSql('insert into previous values (?);',[Tab.itemMap[openedUrl].url]);
                        console.log('saving existing page: ' + Tab.itemMap[openedUrl].url)
                    }
                );
            }
        }
    }

    SequentialAnimation { 
        id: bounce 
        PropertyAnimation { target: container; properties: "anchors.leftMargin"; to: Tab.DrawerWidth; duration: 200; easing.type: Easing.InOutQuad; }
        PropertyAnimation { target: container; properties: "anchors.leftMargin"; to: "0"; duration: 400; easing.type: Easing.InOutQuad; }
    } 

    function getDatabase() {
        var db = LocalStorage.openDatabaseSync("slatekit-shell", "0.1", "history db", 100000);
        db.transaction(
            function(tx) { 
                tx.executeSql('CREATE TABLE IF NOT EXISTS history (url TEXT, title TEXT, icon TEXT, date INTEGER)');
            }
        );
        db.transaction(function(tx) {tx.executeSql('CREATE TABLE IF NOT EXISTS previous (url TEXT)'); });
        return db;
    }
    function openNewTab(pageid, url) {
        //console.log("openNewTab: "+ pageid + ', currentTab: ' + currentTab);
        if (hasTabOpen) {      
            tabModel.insert(0, { "title": "Loading..", "url": url, "pageid": pageid, "favicon": "icons/favicon.png" } );
            // hide current tab and display the new
            Tab.itemMap[currentTab].visible = false;
        } else {
            tabModel.set(0, { "title": "Loading..", "url": url, "pageid": pageid, "favicon": "icons/favicon.png" } );
        }
        var webView = tabView.createObject(container, { id: pageid, objectName: pageid } );
        webView.url = url; // FIXME: should use loadUrl() wrapper 

        Tab.itemMap[pageid] = webView;
        currentTab = pageid;
        tabListView.currentIndex = 0 // move highlight to top  
    }

    function switchToTab(pageid) {
        //console.log("switchToTab: "+ pageid + " , from: " + currentTab + ' , at ' + tabListView.currentIndex);
        if (currentTab !== pageid ) { 
            Tab.itemMap[currentTab].visible = false;
            currentTab = pageid;
        }
        Tab.itemMap[currentTab].visible = true;
        // assign url to text bar
        urlText.text = Tab.itemMap[currentTab].url;
    }

    function closeTab(deleteIndex, pageid) { 
        //console.log('closeTab: ' + pageid + ' at ' + deleteIndex + ': ' + tabModel.get(deleteIndex))
        //console.log('\ttabListView.model.get(deleteIndex): ' + tabListView.model.get(deleteIndex).pageid)
        Tab.itemMap[pageid].visible = false; 
        tabModel.remove(deleteIndex);
        Tab.itemMap[pageid].destroy(); 
        delete(Tab.itemMap[pageid])

        if (hasTabOpen) { 
            // FIXME: after closed, Qt 5.1 doesn't change tabListView.currentIndex  
            if (tabModel.count == 1 && tabListView.currentIndex == 1) tabListView.currentIndex = 0;  
            currentTab = tabListView.model.get( tabListView.currentIndex ).pageid
            switchToTab(currentTab)
        } else {
            urlText.text = "";
            currentTab = ""; // clean currentTab 
        }
    } 

    function salt(){
        var salt = ""
        for( var i=0; i < 5; i++ ) {
            salt += Tab.RandomString.charAt(Math.floor(Math.random() * Tab.RandomString.length));
        }
        return salt
    }

    function fixUrl(url) {
        url = url.replace( /^\s+/, "").replace( /\s+$/, ""); // remove white space
        url = url.replace( /(<([^>]+)>)/ig, ""); // remove <b> tag 
        if (url == "") return url;
        if (url[0] == "/") { return "file://"+url; }
        if (url[0] == '.') { 
            var str = Tab.itemMap[currentTab].url.toString();
            var n = str.lastIndexOf('/');
            return str.substring(0, n)+url.substring(1);
        }
        //FIXME: search engine support here
        if (url.indexOf('.') < 0) { return "https://duckduckgo.com/?q="+url; }
        if (url.indexOf(":")<0) { return "http://"+url; }
        else { return url;}
    }

    function loadUrl(url) {
        if (hasTabOpen) {
            Tab.itemMap[currentTab].url = fixUrl(url)
        } else { 
            openNewTab("page"+salt(), fixUrl(url));
        }
        Tab.itemMap[currentTab].focus = true;
    }
    function updateHistory(url, title, icon) { 
        var date = new Date();
        var db = getDatabase();
        db.transaction(
            function(tx) {
                var result = tx.executeSql('delete from history where url=(?);',[url])
            }
        );
        db.transaction(
            function(tx) {
                var result = tx.executeSql('insert into history values (?,?,?,?);',[url, title, icon, date.getTime()])
                if (result.rowsAffected < 1) {
                    console.log("Error inserting url: " + url)
                } else {
                }
            }
        );
    }

    function highlightTerms(text, terms) {
        if (text === undefined || text === '') {
            return ''
        }
        var highlighted = text.toString()
        highlighted = highlighted.replace(new RegExp(terms, 'ig'), '<b>$&</b>')
        return highlighted
    }

    function queryHistory(str) {
        var db = getDatabase();
        var result; 
        db.transaction(
            function(tx) {
                result = tx.executeSql("select * from history where url like ?", ['%'+str+'%']) 
            }
        );
        historyModel.clear();
        historyListView.currentIndex = 0;
        for (var i=0; i < result.rows.length; i++) {
            historyModel.insert(0, {"url": highlightTerms(result.rows.item(i).url, str), 
            "title": result.rows.item(i).title});
        }
        historyListView.currentIndex = 0;
    }

    function toggleReaderMode() {
        if (readerMode) {
            Tab.itemMap[currentTab].reload();
        } else { 
            // FIXME: dirty hack to load js from local file 
            var xhr = new XMLHttpRequest;
            xhr.open("GET", "./js/readability.js");
            xhr.onreadystatechange = function() {
                if (xhr.readyState == XMLHttpRequest.DONE) {
                    var read = new Object({'type':'readability', 'content': xhr.responseText });
                    Tab.itemMap[currentTab].experimental.postMessage( JSON.stringify(read) );
                }
            }
            xhr.send();
        }
        readerMode = !readerMode; 
    }

    Component {
        id: tabView
        WebView { 
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            anchors.bottom: Tab.EnableVirtualKeyboard ? keyboard.top : parent.bottom 
            z: 2 // for drawer open/close control  
            anchors.topMargin: 40 // FIXME: should use navigator bar item

            MouseArea { 
                id: contextOverlay; 
                anchors.fill: parent; 
                enabled: contextMenu.visible
                onClicked: contextMenu.visible = false 
            }
            
            Rectangle{
                id: contextMenu
                visible: false 
                width: 250; height: 230
                color: "gray"
                radius: 5 
                Text {  
                    id: contextUrl
                    color: "white"
                    wrapMode: Text.WrapAnywhere 
                    anchors { 
                        top: parent.top; left: parent.left; right: parent.right; 
                        margins: 20; topMargin: 10
                    }
                }
                Column {
                    id: contextButtons
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    ContextButton { 
                        label: "Open"; 
                        onClicked: { Tab.itemMap[currentTab].url = contextUrl.text; contextMenu.visible = false }
                    }
                    ContextButton { 
                        label: "Open in New Tab"; 
                        onClicked: { bounce.start(); openNewTab("page"+salt(), contextUrl.text); contextMenu.visible = false }
                    }
                    // FIXME: clipboard?
                    ContextButton { label: "Copy"; onClicked: { console.log('Copy: ' + contextUrl.text); contextMenu.visible = false } }
                }
            }

            // FIXME: calculate scale, and position of screen
            function updateContextMenu(X, Y, url) {
                contextMenu.x = X; contextMenu.y = Y
                if (X + contextMenu.width/2 > root.width) {
                    contextMenu.x = root.width - contextMenu.width - 30
                } else if (X - contextMenu.width/2 < 0) { 
                    contextMenu.x = 30
                } else { 
                    contextMenu.x = X - contextMenu.width/2 - 10;
                }
                if (Y - contextMenu.height - 40 < 0) {
                    contextMenu.y = Y + 5
                } else { 
                    contextMenu.y = Y - contextMenu.height - 20
                }
                contextMenu.visible = true
                contextUrl.text = url
            }

            //property real scale: experimental.test.contentsScale
            //experimental.devicePixelRatio: 2.0; 

            experimental.itemSelector: PopOver {}
            experimental.preferences.fullScreenEnabled: true;
            experimental.preferences.developerExtrasEnabled: true;

            experimental.userScripts: [Qt.resolvedUrl("js/userscript.js")];
            experimental.preferences.navigatorQtObjectEnabled: true;
            experimental.onMessageReceived: {
                console.log('onMessageReceived: ' + message.data );
                var data = null
                try {
                    data = JSON.parse(message.data)
                } catch (error) {
                    console.log('onMessageReceived: ' + message.data );
                    return
                }
                switch (data.type) {
                    case 'link': {
                        updateContextMenu(data.pageX, data.pageY, data.href) 
                        if (data.target === '_blank') { // open link in new tab
                            bounce.start()
                            openNewTab('page-'+salt(), data.href)
                        }
                        break;
                    } 
                    case 'longpress': {
                        updateContextMenu(data.pageX, data.pageY, fixUrl(data.href));
                    }
                    case 'input': {
                        keyboard.state = data.state;
                        break;
                    }
                }
            }
            //experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"

            onLoadingChanged: { 
                contextMenu.visible = false;
                readerMode = false;
                urlText.text = Tab.itemMap[currentTab].url;
                if (loadRequest.status == WebView.LoadSucceededStatus) {
                    updateHistory(Tab.itemMap[currentTab].url, Tab.itemMap[currentTab].title, Tab.itemMap[currentTab].icon)
                }
            }

        }
    }

    Rectangle {
        id: drawer
        anchors.left: parent.left
        anchors.top: parent.top
        width: Tab.DrawerWidth
        height: parent.height
        color: "#33343E" 

        ListModel { id: tabModel }

        Component {
            id: tabDelegate
            Row {
                spacing: 10
                Rectangle {
                    width: Tab.DrawerWidth
                    height: Tab.DrawerHeight
                    color: "transparent"
                    Image { 
                        height: 16; width: 16; 
                        source: hasTabOpen ? Tab.itemMap[model.pageid].icon : "icons/favicon.png";
                        anchors { top: parent.top; left: parent.left; margins: Tab.DrawerMargin; } 
                    }
                    Text { 
                        text: (typeof(Tab.itemMap[model.pageid]) !== "undefined" && Tab.itemMap[model.pageid].title !== "") ? 
                        Tab.itemMap[model.pageid].title : "Loading..";
                        color: "white"; 
                        anchors { top: parent.top; left: parent.left; margins: Tab.DrawerMargin; 
                        leftMargin: Tab.DrawerMargin+30; right: parent.right } 
                        elide: Text.ElideRight 
                    }
                    MouseArea { 
                        anchors { top: parent.top; left: parent.left; bottom: parent.bottom; right: parent.right; rightMargin: 40}
                        onClicked: { 
                            tabListView.currentIndex = index;
                            switchToTab(model.pageid);
                        }
                    }

                    Rectangle {
                        width: 40; height: 40
                        color: "transparent"
                        anchors { right: parent.right; top: parent.top}
                        Text {  // closeTab button
                            visible: tabListView.currentIndex === index
                            anchors { top: parent.top; right: parent.right; margins: Tab.DrawerMargin }
                            text: "\uF057"
                            font.family: fontAwesome.name
                            font.pointSize: 16
                            color: "gray"

                            MouseArea { 
                                anchors.fill: parent; 
                                onClicked: closeTab(model.index, model.pageid)
                            }
                        }
                    }
                }
            }
        }
        ListView {
            id: tabListView
            anchors.fill: parent

            // new tab button 
            header: Rectangle { 
                width: Tab.DrawerWidth
                height: Tab.DrawerHeight
                color: "transparent"
                Text { 
                    text: "\uF067"; font.family: fontAwesome.name; color: "white"; font.pointSize: 14
                    anchors { top: parent.top; left: parent.left; margins: Tab.DrawerMargin+2; leftMargin: Tab.DrawerMargin+10 }
                }
                Text { 
                    text: "<b>New Tab</b>"
                    color: "white"
                    font.pointSize: 15
                    anchors { top: parent.top; left: parent.left; margins: Tab.DrawerMargin; leftMargin: Tab.DrawerMargin+30 }
                }
                MouseArea { 
                    anchors.fill: parent;
                    enabled: (container.state == "opened") 
                    onClicked: {
                        openNewTab("page-"+salt(), Tab.HomePage); 
                    }
                }
            }

            model: tabModel
            delegate: tabDelegate 
            highlight: 

            Rectangle { 
                width: Tab.DrawerWidth; height: Tab.DrawerHeight 
                gradient: Gradient {
                    GradientStop { position: 0.1; color: "#1F1F23" }
                    GradientStop { position: 0.5; color: "#28282F" }
                    GradientStop { position: 0.8; color: "#2A2B31" }
                    GradientStop { position: 1.0; color: "#25252A" }

                }
            }
            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
            //    NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 400 }
            }

            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce }
            }
            highlightMoveDuration: 2
            highlightFollowsCurrentItem: true 
        }
    }

    Rectangle {
        id: container 
        anchors.left: parent.left 
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        color: "#6B6C71" 
        z: 1 
        RadialGradient {
            visible: (typeof(Tab.itemMap[currentTab])==="undefined")
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 1.0; color: "#FF000000" }
            }
            verticalOffset: -150
            horizontalRadius: root.width - 250 
            verticalRadius: root.height - 220
        }

        Text {
            visible: (typeof(Tab.itemMap[currentTab])==="undefined")
            anchors.centerIn: parent
            text: "SlateKit Shell"
            color: "#4D4E51"
            font.pointSize: 80
            font.bold: true 
            style: Text.Sunken; styleColor: "#FF000000"
        }

        Item { 
            id: keyboard 
            z: 5
            width: 960
            height: 240 
            state: "hide"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -240
            Loader { 
                id: keyboardLoader
                anchors.fill: parent
                source: Tab.EnableVirtualKeyboard ? "English.qml" : ""
            }
            states: [ State { name: "show" }, State { name: "hide" } ]
            transitions: [ 
                Transition {
                    from: "show"; to: "hide"
                    PropertyAnimation { target: keyboard; properties: "anchors.bottomMargin"; to: "-240"; duration: 150; easing.type: Easing.InOutQuad; }
                },
                Transition {
                    from: "hide"; to: "show"
                    PropertyAnimation { target: keyboard; properties: "anchors.bottomMargin"; to: "0"; duration: 50; easing.type: Easing.InOutQuad;}
                }
            ]
        }

        Rectangle { 
            height: 40; width: parent.width; anchors.top: parent.top; anchors.left: parent.left
            gradient: Gradient { 
                GradientStop { position: 0.0; color: "#ffffff" } 
                GradientStop { position: 1.0; color: "#eaeaea" } 
            }
        }
        // Navigator Bar, should use verticalCenter: parent.verticalCenter
        // drawer button 
        Item { 
            id: drawerButton
            width: 30; height: 30; anchors { top: parent.top; left: parent.left; margins: Tab.DrawerMargin; topMargin: 5 } 
            Text { 
                id: drawerButtonIcon
                text: (fontAwesome.status === FontLoader.Ready) ? "\uF0C9" : ""; 
                font { family: fontAwesome.name; pointSize: 28 } 
                color: "#AAAAAA" 
                style: Text.Sunken; styleColor: "gray"
            }
            MouseArea {
                anchors.fill: parent;
                anchors.margins: -5; // trick to handle touch 
                onPressed: drawerButtonIcon.color = "#FED164"; 
                onClicked: { container.state == "closed" ? container.state = "opened" : container.state = "closed"; }
                onReleased: drawerButtonIcon.color = "#AAAAAA";
            }
        }

        Item {
            id: backButton
            width: 30; height: 30; anchors { top: parent.top; left: drawerButton.right; margins: Tab.DrawerMargin; topMargin: 7}
            Text { 
                id: backButtonIcon
                text: "\uF053" 
                font { family: fontAwesome.name; pointSize: 26 }
                color: hasTabOpen ? (Tab.itemMap[currentTab].canGoBack ? "#AAAAAA" : "lightgray") : "lightgray"
                style: Text.Sunken; styleColor: "gray"
            }
            MouseArea { 
                anchors.fill: parent; anchors.margins: -5; 
                onPressed: backButtonIcon.color = "#FED164";
                onClicked: { if (Tab.itemMap[currentTab].canGoBack) Tab.itemMap[currentTab].goBack()  }
                onReleased: backButtonIcon.color = "#AAAAAA";
            }
        }
        // TODO: forward button? \uF061 

        Rectangle { 
            id: urlBar 
            anchors { left: backButton.right; top: parent.top; right: exportButton.left; margins: 6; rightMargin: 14; } 
            color: "white"
            height: 25 
            border { width: 1; color: "black" }
            radius: 5 
            width: parent.width - 60

            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                radius: 3

                width: hasTabOpen ?  parent.width / 100 * Math.max(5, Tab.itemMap[currentTab].loadProgress) : 0 
                color: "#FED164" // light yellow 
                opacity: 0.4
                visible: hasTabOpen ? Tab.itemMap[currentTab].loading : false 
            }

            TextInput { 
                id: urlText
                text: hasTabOpen ? Tab.itemMap[currentTab].url : ""
                anchors { left: parent.left; top: parent.top; right: stopButton.left; margins: 5; }
                height: parent.height
                clip: true
                onAccepted: { 
                    loadUrl(urlText.text)
                    urlText.text = urlText.text;
                }
                Keys.onEscapePressed: { urlText.focus = false; }
                onActiveFocusChanged: { 
                    // FIXME: use State to change property  
                    if (urlText.activeFocus) { 
                        urlText.selectAll(); parent.border.color = "#2E6FFD"; parent.border.width = 2;
                        keyboard.state = 'show'
                    } else { 
                        parent.border.color = "black"; parent.border.width = 1; 
                        keyboard.state = 'hide'
                    }
                }
                onTextChanged: {
                    if (urlText.activeFocus && urlText.text !== "") {
                        queryHistory(urlText.text)
                    } else { historyModel.clear() }
                }
            }            

            Text {
                id: stopButton
                anchors { right: urlBar.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                text: "\uF00D"
                font { family: fontAwesome.name; pointSize: 18 }
                color: "gray"
                visible: ( hasTabOpen && Tab.itemMap[currentTab].loadProgress < 100 && !urlText.focus) ? 
                true : false
                MouseArea {
                    anchors { fill: parent; margins: -10; }
                    onClicked: { Tab.itemMap[currentTab].stop(); }
                }
            }
            Text {
                id: reloadButton
                anchors { right: urlBar.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                text: "\uF01E"
                font { family: fontAwesome.name; pointSize: 16 }
                color: "gray"
                visible: ( hasTabOpen && Tab.itemMap[currentTab].loadProgress == 100 && !urlText.focus ) ? 
                true : false 
                MouseArea {
                    anchors { fill: parent; margins: -10; }
                    onClicked: { Tab.itemMap[currentTab].reload(); }
                }
            }
            Text {
                id: clearButton
                anchors { right: urlBar.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                text: "\uF057"
                font { family: fontAwesome.name; pointSize: 18 }
                color: "gray"
                visible: urlText.focus
                MouseArea {
                    anchors { fill: parent; margins: -10; }
                    onClicked: { urlText.text = ""; }
                }
            }
        }

        Item {
            id: exportButton
            width: 30; height: 30; anchors { top: parent.top; right: parent.right; margins: Tab.DrawerMargin; topMargin: 6}
            Text { 
                id: exportButtonIcon
                text: "\uF013"
                font { family: fontAwesome.name; pointSize: 28 }
                color: (readerMode && hasTabOpen) ? "#FED164" : "#AAAAAA" 
                style: Text.Sunken; styleColor: "gray"
            }
            MouseArea {
                anchors.fill: parent; anchors.margins: -5
                onClicked: if (hasTabOpen) toggleReaderMode();
            }
        }

        Item { 
            id: suggestionContainer
            width: root.width - 180 + 24
            height: suggestionDialog.height + 24 + 30 
            anchors { top: parent.top; topMargin: 22; left: parent.left; leftMargin: 100; }
            visible: (urlText.focus && historyModel.count > 0)
            z: 5

            Rectangle {
                id: suggestionDialog
                color: "lightgray"
                radius: 5 
                anchors.centerIn: parent 
                width: root.width - 180 
                height: (historyModel.count > 3) ? ((historyModel.count <= 8) ? historyModel.count * 40 : 330) : 120
                anchors { top: parent.top; topMargin: 50; left: parent.left; leftMargin: 100; }

                Text { // caret-up 
                    anchors.top: parent.top
                    anchors.topMargin: -34
                    anchors.left: parent.horizontalCenter
                    anchors.leftMargin: -30
                    font { family: fontAwesome.name; pointSize: 53 }
                    text: "\uF0D8"; 
                    color: "lightgray" 
                }

                ListView { 
                    id: historyListView
                    anchors.fill: parent
                    anchors.topMargin: 15 
                    anchors.bottomMargin: 15
                    clip: true
                    model: historyModel 
                    delegate: historyDelegate
                    ListModel { 
                        id: historyModel
                    }
                    Component {
                        id: historyDelegate
                        Rectangle { 
                            color: "transparent"
                            height: Tab.DrawerHeight
                            width: parent.width 
                            Text {                          
                                anchors {                       
                                    top: parent.top; left: parent.left; right: parent.right
                                    margins: 8; leftMargin: 10;
                                }                               
                                text: '<b>'+ model.title +'<b>' 
                                font.pointSize: 14    
                                elide: Text.ElideRight          
                            }  
                            Text {                          
                                anchors {                       
                                    top: parent.top; left: parent.left; right: parent.right
                                    margins: 8;          
                                    topMargin: 26; leftMargin: 10;
                                }                               
                                color: "#565051" // darkgray    
                                text: model.url                 
                                font.pointSize: 10    
                                elide: Text.ElideMiddle         
                            }
                            MouseArea { 
                                anchors.fill: parent; 
                                onClicked: loadUrl(model.url) 
                            }
                        }
                    }
                    highlight: Rectangle { 
                        color: "darkgray"
                    }
                    highlightMoveDuration: 2
                } // end of historyListView
            }

        }

        DropShadow {
            id: suggestionShadow;                
            z: 5
            visible: (urlText.focus && historyModel.count > 0)
            anchors.fill: source
            cached: true;                          
            horizontalOffset: 3;
            verticalOffset: 3;                         
            radius: 12.0;
            samples: 16;
            color: "#80000000";
            smooth: true;
            source: suggestionContainer;
        }

        MouseArea { 
            z: (container.state == "opened") ? 3 : 1
            anchors.fill: parent
            anchors.topMargin: 40 
            onClicked: { container.state == "closed" ? container.state = "opened" : container.state = "closed"; }
        }
        states: [
            State{
                name: "opened"
                PropertyChanges { target: container; anchors.leftMargin: Tab.DrawerWidth }
            },
            State {
                name: "closed"
                PropertyChanges { target: container; anchors.leftMargin: 0 }
            }
        ]
        transitions: [
            Transition {
                to: "*"
                NumberAnimation { target: container; properties: "anchors.leftMargin"; duration: 300; easing.type: Easing.InOutQuad; }
            }
        ]
    }
}
