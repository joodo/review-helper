import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.13
import QtQuick.Controls.Material.impl 2.12
import QtQuick.Layouts 1.13

import Minerdo 1.0

Pane {
    id: noteBookCard

    property string text
    property int color
    signal clicked()
    signal editClicked()

    height: UI.dp(184); width: UI.cardWidth
    padding: 0
    hoverEnabled: true
    Material.elevation: noteBookCard.hovered? 4:0
    Behavior on Material.elevation { NumberAnimation { duration: UI.controlsDuration }}

    background: Rectangle {
        color: Material.color(noteBookCard.color, UI.backgroundShade)
        radius: UI.dp(8)
        border.color: Material.color(Material.Grey)
        border.width: 1

        layer.enabled: noteBookCard.enabled && noteBookCard.Material.elevation > 0
        layer.effect: ElevationEffect {
            elevation: noteBookCard.Material.elevation
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: noteBookCard.clicked()
    }

    Label {
        x: UI.dp(16); y: UI.dp(16)
        font.pointSize: 24
        text: noteBookCard.text
    }

    Button {
        flat: true
        text: qsTr("Edit")
        anchors { bottom: parent.bottom; right: parent.right; rightMargin: UI.dp(16) }
        visible: noteBookCard.hovered
        background: Item {}
        highlighted: hovered
        onClicked: noteBookCard.editClicked()
    }
}
