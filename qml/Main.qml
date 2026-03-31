import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
  id: root
  width: 400
  height: 700
  visible: true
  title: "Mobile App"

  header: ToolBar {
    RowLayout {
      anchors.fill: parent
      Label {
        text: "Mobile App"
        font.pixelSize: 20
        font.bold: true
        Layout.alignment: Qt.AlignCenter
      }
    }
  }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 20

    Image {
      source: "qrc:/qt/qml/MobileApp/icons/icon.svg"
      sourceSize.width: 128
      sourceSize.height: 128
      Layout.alignment: Qt.AlignHCenter
    }

    Label {
      text: "Hello from Qt6!"
      font.pixelSize: 24
      Layout.alignment: Qt.AlignHCenter
    }

    Label {
      id: counterLabel
      text: "Count: 0"
      font.pixelSize: 18
      Layout.alignment: Qt.AlignHCenter
      property int count: 0
    }

    Button {
      text: "Tap me"
      Layout.alignment: Qt.AlignHCenter
      Layout.preferredWidth: 200
      onClicked: {
        counterLabel.count++
        counterLabel.text = "Count: " + counterLabel.count
      }
    }

    Label {
      text: Qt.platform.os
      font.pixelSize: 14
      opacity: 0.6
      Layout.alignment: Qt.AlignHCenter
    }
  }
}
