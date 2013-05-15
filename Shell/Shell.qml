import QtQuick 2.0
import QtQuick.LocalStorage 2.0

import QtWebKit 3.0
import QtWebKit.experimental 1.0
import "script.js" as Tab 

Item {
    id: root 
    width: 960 
    height: 640 
    property string currentTab: ""
    property bool hasTabOpen: (tabModel.count !== 0) && (typeof(Tab.itemMap[currentTab]) !== "undefined")
    property string title: ""

    //FontLoader { id: fontAwesome; source: "http://netdna.bootstrapcdn.com/font-awesome/3.0/font/fontawesome-webfont.ttf" }
    FontLoader { id: fontAwesome; source: "icon/fontawesome-webfont.ttf" }  

    Component.onCompleted: {
        var db = LocalStorage.openDatabaseSync("shellbrowser", "0.1", "history db", 100000)
        db.transaction(
            function(tx) { tx.executeSql('CREATE TABLE IF NOT EXISTS history (url TEXT, title TEXT, icon TEXT, date INTEGER)')}
        );
    }

    function openNewTab(pageid, url) {
        //console.log("openNewTab: "+ pageid + ', currentTab: ' + currentTab);
        if (hasTabOpen) {      
            tabModel.insert(0, { "title": "Loading..", "url": url, "pageid": pageid, "favicon": "icon/favicon.png" } );
            // hide current tab and display the new
            Tab.itemMap[currentTab].visible = false;
        } else {
            tabModel.set(0, { "title": "Loading..", "url": url, "pageid": pageid, "favicon": "icon/favicon.png" } );
        }
        var webView = tabView.createObject(container, { id: pageid, objectName: pageid } );
        webView.url = url; // FIXME: should use loadUrl() wrapper 

        Tab.itemMap[pageid] = webView;
        currentTab = pageid;
        tabListView.currentIndex = 0 // move hightlight to top  
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
        root.title = Tab.itemMap[currentTab].title;
    }

    function closeTab(deleteIndex, pageid) { 
        //console.log('closeTab: ' + pageid + ' at ' + deleteIndex + ': ' + tabModel.get(deleteIndex))
        //console.log('\ttabListView.model.get(deleteIndex): ' + tabListView.model.get(deleteIndex).pageid)
        Tab.itemMap[pageid].visible = false; 
        tabModel.remove(deleteIndex);
        Tab.itemMap[pageid].destroy(); 
        delete(Tab.itemMap[pageid])

        if (hasTabOpen) { 
            // TODO: switch to previous tab? 
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
        url = url.replace( /^\s+/, "");
        url = url.replace( /\s+$/, "")
        url = url.replace( /(<([^>]+)>)/ig, ""); // remove <b> tag 
        if (url == "") return url;
        if (url[0] == "/") { return "file://"+url; }
        //FIXME: search engine support here
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
        //console.log('updateHistory: '+ url+', '+ date.getTime())
        var db = LocalStorage.openDatabaseSync("shellbrowser", "0.1", "history db", 100000)
        db.transaction(
            function(tx) {
                var result = tx.executeSql('delete from history where url=(?);',[url])
            }
        );
        db.transaction(
            function(tx) {
                var result = tx.executeSql('INSERT INTO history VALUES (?,?,?,?);',[url, title, icon, date.getTime()])
                if (result.rowsAffected < 1) {
                    console.log("Error inserting url: " + url)
                } else {
                    console.log("Insert into DB: " + url)
                }
            }
        );
    }

    function highlightTerms(text, terms) {
        if (text === undefined) {
            return ''
        }
        var highlighted = text.toString()
        highlighted = highlighted.replace(new RegExp(terms, 'ig'), '<b>$&</b>')
        return highlighted
    }

    function queryHistory(str)
    {
        var db = LocalStorage.openDatabaseSync("shellbrowser", "0.1", "history db", 100000)
        var result; 
        db.transaction(
            function(tx) {
                result = tx.executeSql("select * from history where url like ?", ['%'+str+'%']) // , ['ce'] ) 
                for (var i=0; i < result.rows.length; i++) {
                    console.log(result.rows.item(i).url)
                }
            }
        );
        historyModel.clear();
        for (var i=0; i < result.rows.length; i++) {
            historyModel.insert(0, {"url": highlightTerms(result.rows.item(i).url, str), 
            "title": result.rows.item(i).title});
        }
        return result;
    }

    Component {
        id: tabView
        WebView { 
            anchors.left: parent.left 
            anchors.top: parent.top
            anchors.fill: parent

            z: 2 // for drawer open/close control  
            anchors.topMargin: 40 // FIXME: should use navigator bar item
            //experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
            onLoadingChanged: { 
                urlText.text = Tab.itemMap[currentTab].url;
                if (loadRequest.status == WebView.LoadSucceededStatus) {
                    root.title = Tab.itemMap[currentTab].title;
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
                        source: hasTabOpen ? Tab.itemMap[model.pageid].icon : "icon/favicon.png";
                        anchors { top: parent.top; left: parent.left; margins: Tab.DrawerMargin; } 
                    }
                    Text { 
                        text: (typeof(Tab.itemMap[model.pageid]) !== "undefined" && Tab.itemMap[model.pageid].title !== "") ? 
                        Tab.itemMap[model.pageid].title : "Loading..";
                        color: "white"; 
                        anchors { top: parent.top; left: parent.left; margins: Tab.DrawerMargin; leftMargin: Tab.DrawerMargin+30 } 
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
                        }

                        MouseArea { 
                            anchors.fill: parent; 
                            onClicked: closeTab(model.index, model.pageid)
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
                    text: "\uF067"; font.family: fontAwesome.name; color: "white"; 
                    anchors { top: parent.top; left: parent.left; margins: Tab.DrawerMargin+2; leftMargin: Tab.DrawerMargin+10 }
                }
                Text { 
                    text: "New Tab"
                    color: "white"
                    anchors { top: parent.top; left: parent.left; margins: Tab.DrawerMargin; leftMargin: Tab.DrawerMargin+30 }
                }
                MouseArea { 
                    anchors.fill: parent;
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
            highlightFollowsCurrentItem: true 
        }
    }

    Rectangle {
        id: container 
        anchors.left: parent.left 
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        //color: "#E4E4E8" // light gray
        z: 1 
        radius: 3 

        Rectangle { 
            height: 40; width: parent.width; anchors.top: parent.top; anchors.left: parent.left
            radius: 3 
            gradient: Gradient { 
                GradientStop { position: 0.0; color: "#f8f8f8" } // "#FAFAFA" }
                //GradientStop { position: 0.5; color: "#E8E9EC" }
                GradientStop { position: 1.0; color: "#eaeaea" } // "#E2E3E7" }
            }
        }
        // Navigator Bar, should use verticalCenter: parent.verticalCenter
        // drawer button 
        Item { 
            id: drawerButton
            width: 30; height: 30; anchors { top: parent.top; left: parent.left; margins: Tab.DrawerMargin; topMargin: 5 } 
            Text { 
                text: (fontAwesome.status === FontLoader.Ready) ? "\uF0C9" : ""; 
                font { family: fontAwesome.name; pointSize: 28 } 
                color: "#AAAAAA" 
                style: Text.Sunken; styleColor: "gray"
            }
            MouseArea {
                anchors.fill: parent;
                anchors.margins: -5; // trick to handle touch 
                onClicked: { container.state == "closed" ? container.state = "opened" : container.state = "closed"; }
            }
        }

        Item {
            id: backButton
            width: 30; height: 30; anchors { top: parent.top; left: drawerButton.right; margins: Tab.DrawerMargin; topMargin: 5}
            Text { 
                text: "\uF060"
                font { family: fontAwesome.name; pointSize: 26 }
                color: hasTabOpen ? (Tab.itemMap[currentTab].canGoBack ? "#AAAAAA" : "lightgray") : "lightgray"
                style: Text.Sunken; styleColor: "gray"
            }
            MouseArea { 
                anchors.fill: parent; anchors.margins: -5; 
                onClicked: { if (Tab.itemMap[currentTab].canGoBack) Tab.itemMap[currentTab].goBack()  }
            }
        }
        // TODO: forward button? \uF061 

        Rectangle { 
            id: urlBar 
            anchors { left: backButton.right; top: parent.top; right: exportButton.left; margins: 6; rightMargin: 10 } 
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
                wrapMode: TextInput.Wrap
                anchors { fill: parent; margins: 5; rightMargin: 15 }
                onAccepted: { 
                    (Tab.TempUrl !== "") ? loadUrl(Tab.TempUrl) : loadUrl(text)
                    Tab.TempUrl = ""
                }
                Keys.onUpPressed: {
                    if (historyListView.currentIndex > 0) {
                        historyListView.currentIndex-- 
                    } else { historyListView.currentIndex = 0 }
                    Tab.TempUrl = historyListView.model.get(historyListView.currentIndex).url
                }
                Keys.onDownPressed: {
                    if (historyListView.currentIndex < historyModel.count-1) {
                        historyListView.currentIndex++ 
                    } else { historyListView.currentIndex = historyModel.count-1 }
                    Tab.TempUrl = historyListView.model.get(historyListView.currentIndex).url
                }
                Keys.onEscapePressed: { urlText.focus = false }
                onActiveFocusChanged: { 
                    // FIXME: use State to change property  
                    if (urlText.activeFocus) { urlText.selectAll(); parent.border.color = "#2E6FFD"; parent.border.width = 2;} 
                    else { parent.border.color = "black"; parent.border.width = 1; } 
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
                font { family: fontAwesome.name; pointSize: 20 }
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
                text: "\uF021"
                font { family: fontAwesome.name; pointSize: 20 }
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
                font { family: fontAwesome.name; pointSize: 20 }
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
            width: 30; height: 30; anchors { top: parent.top; right: parent.right; margins: Tab.DrawerMargin; topMargin: 5}
            Text { 
                text: "\uF045"
                font { family: fontAwesome.name; pointSize: 28 }
                color: "#AAAAAA" 
                style: Text.Sunken; styleColor: "gray"
            }
        }

        Rectangle {
            id: suggestionDialog
            visible: (urlText.focus && historyModel.count > 0)
            color: "lightgray"
            radius: 5 
            width: parent.width - 180
            height: historyModel.count * 40
            anchors { top: parent.top; topMargin: 50; left: parent.left; leftMargin: 100; }
            z: 5 // highest z index so far.. 

            Text { // caret-up 
                anchors.top: parent.top
                anchors.topMargin: -34
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: -30
                font { family: fontAwesome.name; pointSize: 50 }
                text: "\uF0D8"; 
                color: "lightgray" 
            }

            ListView { 
                id: historyListView
                anchors.fill: parent
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
                            anchors.fill: parent
                            anchors.margins: 10
                            text: model.url + ' - ' + model.title 
                            font.pointSize: 16 
                        }
                        MouseArea { 
                            anchors.fill: parent; 
                            onClicked: loadUrl(model.url) 
                        }
                    }
                }
                highlight: Rectangle { 
                    width: parent.width; height: Tab.DrawerHeight
                    color: "darkgray"
                }
            } // end of historyListView
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
