import QtQuick 2.6
import QtQuick.Controls 2.1
import MeeGo.Connman 0.2 

Rectangle {
    width: 800
    height: 600
    color: 'white'

    Rectangle {
        id: control
        width: parent.width
        height: 50
        anchors {
            left: parent.left
            top: parent.top
        }
        Text {
            id: errorMsg
            anchors.centerIn: parent
        }
    }

    /*
    Switch {
        id: control
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }
        checked: true

        indicator: Rectangle {
            implicitWidth: 48
            implicitHeight: 26
            x: control.leftPadding
            y: parent.height / 2 - height / 2
            radius: 13
            color: control.checked ? "#17a81a" : "#ffffff"
            border.color: control.checked ? "#17a81a" : "#cccccc"

            Rectangle {
                x: control.checked ? parent.width - width : 0
                width: 26
                height: 26
                radius: 13
                color: control.down ? "#cccccc" : "#ffffff"
                border.color: control.checked ? (control.down ? "#17a81a" : "#21be2b") : "#999999"
            }
        }
        onCheckedChanged: {
            networkingModel.powered = control.checked
            if (control.checked) {
                networkingModel.requestScan()
            } else {
                wifiListView.visible = false
            }
        }
    }
    */

    Timer {
        id: scanTimer
        interval: 25000
        running: networkingModel.powered
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            networkingModel.requestScan()
            console.log('scan')
        }
    }

    TechnologyModel {
        id: networkingModel
        name: "wifi"
        property string networkName
    }

    ListView {
        id: wifiListView

        anchors {
            top: control.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        model: networkingModel
        delegate: Rectangle {
            height: 60
            width: parent.width

            Row {
                anchors.fill: parent
                spacing: 20

                Rectangle { 
                    width: 40
                    height: 20
                    color: 'transparent'
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        height: 20 
                        fillMode: Image.PreserveAspectFit 
                        source: (modelData.state == "online" || modelData.state == "ready") ? "tick.png" : ""
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Text {
                    text: modelData.name 
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 14
                    font.bold: (modelData.state == "online" || modelData.state == "ready") ? true : false
                }
            }
            Row {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 30
                }
                width: 50
                spacing: 10
                Rectangle {
                    width: 20
                    height: 20 
                    color: 'transparent'
                    anchors.verticalCenter: parent.verticalCenter
                    Image { 
                        height: 20
                        fillMode: Image.PreserveAspectFit
                        source: (modelData.security[0] == "none") ? "" : "security.png"
                        anchors.fill: parent
                    }
                }
                Image {
                    height: 20
                    fillMode: Image.PreserveAspectFit
                    source: if (modelData.strength >= 55 ) { return "wlan-strength4.png" }
                    else if (modelData.strength >= 50 ) { return "wlan-strength3.png" }
                    else if (modelData.strength >= 45 ) { return "wlan-strength2.png" }
                    else if (modelData.strength >= 30 ) { return "wlan-strength1.png" }
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (modelData.state == "idle" || modelData.state == "failure") {
                        networkingModel.networkName = modelData.name 
                        modelData.requestConnect()
                    }
                }
            }	

        }
    }

    UserAgent {
        id: userAgent
        onUserInputRequested: {
            overlay.visible = true;
            dialog.visible = true;
            passwordInput.text = "" 
            console.log('user input requested: ' + networkingModel.networkName)
            var view = {
                "fields": []
            };
            for (var key in fields) {
                view.fields.push({
                    "name": key,
                    "id": key.toLowerCase(),
                    "type": fields[key]["Type"],
                    "requirement": fields[key]["Requirement"]
                });
                console.log(key + ":");
                for (var inkey in fields[key]) {
                    console.log("    " + inkey + ": " + fields[key][inkey]);
                }
            }
        }
        onErrorReported: {
            console.log('Error: ' + error)
        }
    }

    Rectangle {
        id: overlay 
        visible: false
        anchors.fill: parent
        color: 'grey'
        opacity: 0.5 
    }

    Rectangle {
        id: dialog
        visible: false 
        anchors.centerIn: parent
        radius: 15
        width: 360
        height: 250
        color: 'white'
        MouseArea {
            anchors.fill: parent
        }
        Text { 
            id: dialogTitle
            anchors {
                top: parent.top
                topMargin: 15 
                horizontalCenter: parent.horizontalCenter
            }
            text: 'Enter the password for "' + networkingModel.networkName + '"'
            font.pointSize: 12
        }
        TextField {
            id: passwordInput
            anchors {
                top: dialogTitle.bottom
                horizontalCenter: parent.horizontalCenter
                margins: 10
                topMargin: 30
            }
            width: parent.width - 50
            height: 40
            font.pointSize: 16
            echoMode: showPassword.checked ? TextInput.Normal : TextInput.Password
        }
        CheckBox { 
            id: showPassword
            text: qsTr("Show password") 
            checked: false
            anchors {
                top: passwordInput.bottom
                left: passwordInput.left
                margins: 30
                leftMargin: 10
            }
        }
        Row {
            anchors {
                left: parent.left
                bottom: parent.bottom
            }
            height: 60
            width: parent.width
            spacing: 120
            Rectangle {
                height: 60
                width: 120
                color: 'transparent'
                Text {
                    text: 'Cancel' 
                    font.pointSize: 12
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dialog.visible = false
                        overlay.visible = false
                        userAgent.sendUserReply({})
                    }
                }
            }
            Rectangle {
                height: 60
                width: 120
                color: 'transparent'
                Text {
                    text: 'Join' 
                    font.pointSize: 12
                    font.bold: true
                    anchors.centerIn: parent
                    color: '#2872f6'
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dialog.visible = false
                        overlay.visible = false
                        userAgent.sendUserReply({"Passphrase": passwordInput.text })
                    }
                }
            }
        }
    }
}
