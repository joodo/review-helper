import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.13
import QtQuick.Layouts 1.13

import Minerdo 1.0
import "axios.js" as Axios

Page {
    id: notebookListPage

    signal reviewTriggered()
    signal editTriggered()
    signal newTriggered()

    header: ToolBar {
        id: toolBar
        readonly property real maxHeight: UI.dp(240)

        height: maxHeight

        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: "black"
            opacity: 0
            Image {
                Component.onCompleted: {
                    Axios.instance.get("https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&ensearch=1")
                    .then((response) => {
                              let url = response.data.images[0].url
                              url = "http://www.bing.com" + url
                              source = url
                          })
                }
                onStatusChanged: if (status === Image.Ready) backgroundShowAnimator.start()
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                opacity: .6
            }
            OpacityAnimator {
                id: backgroundShowAnimator
                duration: UI.cardExpandDuration
                target: backgroundRect
                to: ((toolBar.height - toolBar.implicitHeight) /
                     (toolBar.maxHeight - toolBar.implicitHeight))
                onFinished: backgroundRect.opacity = Qt.binding(() => (
                                                                    (toolBar.height - toolBar.implicitHeight) /
                                                                    (toolBar.maxHeight - toolBar.implicitHeight)))
            }
        }

        Label {
            fontSizeMode: Text.Fit
            anchors { left: parent.left; right: parent.right; top: parent.top }
            padding: UI.dp(18)
            font.pointSize: 30
            height: (toolBar.implicitHeight + toolBar.height) / 2
            text: {
                const date = new Date()
                const h = date.getHours()
                if (h < 12) {
                    qsTr("Good Morning.")
                } else if (h < 19) {
                    qsTr("Good Afternoon.")
                } else {
                    qsTr("Good Evening.")
                }
            }
        }

        RowLayout {
            anchors {
                right: parent.right; bottom: parent.bottom
            }
            CollapsableToolButton {
                icon.source: "qrc:/material-icons/library_books.svg"
                text: qsTr("Review All")
                state: toolBar.height < toolBar.maxHeight / 2? "collapse" : "expand"
                onClicked: {
                    Actions.setCurrentNotebook(-1)
                    if (Actions.pickRandomEntry()) {
                        notebookListPage.reviewTriggered()
                    } else {
                        UI.showMessage({
                                           "text": qsTr("There's no entry. Please create one.")
                                       })
                    }
                }
            }
            CollapsableToolButton {
                icon.source: "qrc:/material-icons/search.svg"
                text: qsTr("Search")
                state: toolBar.height < toolBar.maxHeight / 2? "collapse" : "expand"
                onClicked: {
                    searchPane.state = "show"
                }
            }
        }

        Pane {
            id: searchPane
            anchors.fill: parent
            visible: opacity !== 0
            state: "hide"
            Behavior on opacity { OpacityAnimator { duration: UI.controlsDuration } }
            TextField {
                id: searchField
                focus: true
                anchors.fill: parent
                background: Item {}
                topPadding: 0
                bottomPadding: 0
                placeholderText: qsTr("Search entries")
                selectByMouse: true
                color: Material.primaryTextColor
            }
            ToolButton {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                icon.source: "qrc:/material-icons/close.svg"
                icon.color: Material.primaryTextColor
                onClicked: searchPane.state = "hide"
            }

            NumberAnimation {
                id: collapseToolbarAnimation
                target: toolBar
                property: "height"
                to: toolBar.implicitHeight
                duration: UI.controlsDuration
                onFinished: {
                    searchPane.focus = true
                    searchField.focus = true
                }
            }

            states: [
                State {
                    name: "show"
                    PropertyChanges {
                        target: searchPane
                        opacity: 1
                    }
                    PropertyChanges {
                        target: collapseToolbarAnimation
                        running: true
                    }
                },
                State {
                    name: "hide"
                    PropertyChanges {
                        target: searchPane
                        opacity: 0
                    }
                }

            ]
        }
    }

    MouseArea {
        acceptedButtons: Qt.NoButton
        anchors.fill: parent
        z: 1
        onWheel: {
            wheel.accepted = false
            if (wheel.angleDelta.y < 0) {
                if (toolBar.height === toolBar.implicitHeight) return
                toolBar.height += wheel.angleDelta.y
                if (toolBar.height < toolBar.implicitHeight) {
                    toolBar.height = toolBar.implicitHeight
                }
            } else {
                if (scrollView.ScrollBar.vertical.position > 0) return
                toolBar.height += wheel.angleDelta.y
                if (toolBar.height > toolBar.maxHeight) {
                    toolBar.height = toolBar.maxHeight
                }
            }
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: contentItem.width
        padding: UI.dp(20)

        Flow {
            id: flow
            spacing: UI.dp(16)
            anchors { left: parent.left; right: parent.right }

            Repeater {
                model: States.notebookModel
                delegate: NotebookCard {
                    id: notebookCard
                    text: name
                    materialColor: color
                    onClicked: {
                        Actions.setCurrentNotebook(index)
                        if (Actions.pickRandomEntry()) {
                            notebookListPage.reviewTriggered()
                        } else {
                            UI.showMessage({
                                               "text": qsTr("There's no entry in this notebook. Click \"EDIT\" to create one.")
                                           })
                        }
                    }
                    onEditClicked: {
                        Actions.setCurrentNotebook(index)
                        notebookListPage.editTriggered()
                    }
                }
            }

            CreateCard {
                onClicked: notebookListPage.newTriggered()
            }
        }

    }

}
