import QtQuick 2.1
import Qt.WebSockets 1.0
import QtMultimedia 5.0
import QtQuick.Controls 1.3

/*
{"type": "ticking", "payload": {"participants_text": "620,810", "tick_mac": "ed293d6957c75ce3a11a41ee49c1fdf7b2c034ff", "seconds_left": 57.0, "now_str": "2015-04-06-16-46-30"}}
*/

Rectangle {
    id: root
    width: 200
    height: 250
    color: "purple"

    property var currMin: 60
    property var lastMin: 60
    property var participantCount: 0
    property var last: 0
    property var threshold: 5

    WebSocket {
        id: socket

        url: "wss://wss.redditmedia.com/thebutton?h=eed0ca06fe84db967651236fcf38846ee813dd61&e=1428591465"

        onTextMessageReceived: {
            var packet = JSON.parse(message)
            messageBox.text = packet.payload.seconds_left
            var curr = packet.payload.seconds_left
            participantCount = packet.payload.participants_text

            if(curr < lastMin) {
                lastMin = curr
            }

            /* Record the last value */
            if(curr >= last) {
                //fileio.write("/var/tmp/button-data.txt", 
                //              last 
                //              + ":" 
                //              +  packet.payload.participants_text
                //              + ":" 
                //              +  packet.payload.tick_mac
                //              + ":" 
                //              +  packet.payload.now_str
                //            );

                if(lastMin < currMin) {
                    currMin = lastMin
                    newLow.play()
                }

            }
            /* Record complete message */
            //fileio.write("/var/tmp/button-data-total.txt", message)

            if(curr > 51) {
                root.color = "#820080"
            } else if(curr > 41) {
                root.color = "#0083C7"
            } else if(curr > 31) {
                root.color = "#02be01"
            } else if(curr > 21) {
                root.color = "#E5D900"
            } else if(curr > 11) {
                root.color = "#e59500"
            } else if(curr <= 11) {
                root.color = "red"
            }

            if(curr == 51 && threshold > 4) {
                audio50Mark.play()
            } else if(curr == 41 && threshold > 3) {
                audio40Mark.play()
            } else if(curr == 31 && threshold > 2) {
                audio30Mark.play()
            } else if(curr == 21 && threshhold > 1) {
                audio20Mark.play()
            } else if(curr == 11 && threshhold > 0) {
                audio10Mark.play()
            }

            last = curr
        }

        onStatusChanged: {
            if(socket.status == WebSocket.Error) {
                console.log("Error: " + socket.errorString)
            } else if(socket.status == WebSocket.Open) {
                console.log("Socket Open")
            } else if(socket.status == WebSocket.Closed) {
                messageBox.text += "Socket Closed"
            }
        }
        active: true
    }

    Text {
        id: messageBox
        font.family: "Helvetica"
        font.pointSize: 128
        text: "xxx"
        anchors.top: parent.top
        anchors.horizontalCenter: root.horizontalCenter
    }
    Text {
        id: currMinBox
        font.family: "Helvetica"
        font.pointSize: 32
        text: currMin
        anchors.topMargin: 10
        anchors.top: messageBox.bottom
        anchors.horizontalCenter: root.horizontalCenter
    }
    Text {
        id: participantBox
        font.family: "Helvetica"
        font.pointSize: 16
        text: participantCount
        anchors.topMargin: 10
        anchors.top: currMinBox.bottom
        anchors.horizontalCenter: root.horizontalCenter
    }
    ComboBox {
        width: 50
        currentIndex: 5 
        model: [ "Off", "1", "2", "3", "4", "5" ]
        anchors.topMargin: 10
        anchors.top: participantBox.bottom
        anchors.horizontalCenter: root.horizontalCenter
        onCurrentIndexChanged: threshold = currentIndex
    }

    SoundEffect {
        id: audio50Mark
        source: "../audio/50mark.wav"
    }
    SoundEffect {
        id: audio40Mark
        source: "../audio/40mark.wav"
    }
    SoundEffect {
        id: audio30Mark
        source: "../audio/30mark.wav"
    }
    SoundEffect {
        id: audio20Mark
        source: "../audio/20mark.wav"
    }
    SoundEffect {
        id: audio10Mark
        source: "../audio/10mark.wav"
    }
    SoundEffect {
        id: newLow
        source: "../audio/new_low.wav"
        volume: 0.4
    }
}
