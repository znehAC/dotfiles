/*
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2

import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
//import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "components"

PlasmaCore.ColorScope {
    id: root
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    width: 1600
    height: 900

    property string notificationMessage

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    PlasmaCore.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    Repeater {
        model: screenModel

        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
            sceneBackgroundType: config.type
            sceneBackgroundColor: config.color
            sceneBackgroundImage: config.background
        }
    }

    Clock {
        //visible: y > 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: units.smallSpacing * 3
    }


    StackView {
        id: mainStack
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: root.height

        focus: true //StackView is an implicit focus scope, so we need to give this focus so the item inside will have it


        Timer {
            //SDDM has a bug in 0.13 where even though we set the focus on the right item within the window, the window doesn't have focus
            //it is fixed in 6d5b36b28907b16280ff78995fef764bb0c573db which will be 0.14
            //we need to call "window->activate()" *After* it's been shown. We can't control that in QML so we use a shoddy timer
            //it's been this way for all Plasma 5.x without a huge problem
            running: true
            repeat: false
            interval: 200
            onTriggered: mainStack.forceActiveFocus()
        }

        initialItem: Login {
            id: userListComponent
            userListModel: userModel
            userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
            lastUserName: userModel.lastUser
            showUserList: {
                if ( !userListModel.hasOwnProperty("count")
                || !userListModel.hasOwnProperty("disableAvatarsThreshold"))
                    return (userList.y + mainStack.y) > 0

                if ( userListModel.count == 0 ) return false

                return userListModel.count <= userListModel.disableAvatarsThreshold && (userList.y + mainStack.y) > 0
            }

            notificationMessage: {
                var text = ""
                if (keystateSource.data["Caps Lock"]["Locked"]) {
                    text += i18nd("plasma_lookandfeel_org.kde.lookandfeel","Caps Lock is on")
                    if (root.notificationMessage) {
                        text += " • "
                    }
                }
                text += root.notificationMessage
                return text
            }

            actionItems: [
                ActionButton {
                    iconSource: "system-suspend"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Suspend")
                    onClicked: sddm.suspend()
                    enabled: sddm.canSuspend
                    visible: !inputPanel.keyboardActive
                },
                ActionButton {
                    iconSource: "system-reboot"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Restart")
                    onClicked: sddm.reboot()
                    enabled: sddm.canReboot
                    visible: !inputPanel.keyboardActive
                },
                ActionButton {
                    iconSource: "system-shutdown"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Shutdown")
                    onClicked: sddm.powerOff()
                    enabled: sddm.canPowerOff
                    visible: !inputPanel.keyboardActive
                },
                ActionButton {
                    iconSource: "system-search"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Different User")
                    onClicked: mainStack.push(userPromptComponent)
                    enabled: true
                    visible: !userListComponent.showUsernamePrompt && !inputPanel.keyboardActive
                }
            ]


            onLoginRequest: {
                root.notificationMessage = ""
                sddm.login(username, password, sessionButton.currentIndex)
            }
        }

        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration
            }
        }
    }

    Loader {
        id: inputPanel
        state: "hidden"
        property bool keyboardActive: item ? item.active : false
        onKeyboardActiveChanged: {
            if (keyboardActive) {
                state = "visible"
            } else {
                state = "hidden";
            }
        }
        source: "components/VirtualKeyboard.qml"
        anchors {
            left: parent.left
            right: parent.right
        }

        function showHide() {
            state = state == "hidden" ? "visible" : "hidden";
        }

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: mainStack
                    y: Math.min(0, root.height - inputPanel.height - userListComponent.visibleBoundary)
                }
                PropertyChanges {
                    target: inputPanel
                    y: root.height - inputPanel.height
                    opacity: 1
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: mainStack
                    y: 0
                }
                PropertyChanges {
                    target: inputPanel
                    y: root.height - root.height/4
                    opacity: 0
                }
            }
        ]
        transitions: [
            Transition {
                from: "hidden"
                to: "visible"
                SequentialAnimation {
                    ScriptAction {
                        script: {
                            inputPanel.item.activated = true;
                            Qt.inputMethod.show();
                        }
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            target: mainStack
                            property: "y"
                            duration: units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: inputPanel
                            property: "y"
                            duration: units.longDuration
                            easing.type: Easing.OutQuad
                        }
                        OpacityAnimator {
                            target: inputPanel
                            duration: units.longDuration
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            },
            Transition {
                from: "visible"
                to: "hidden"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            target: mainStack
                            property: "y"
                            duration: units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: inputPanel
                            property: "y"
                            duration: units.longDuration
                            easing.type: Easing.InQuad
                        }
                        OpacityAnimator {
                            target: inputPanel
                            duration: units.longDuration
                            easing.type: Easing.InQuad
                        }
                    }
                    ScriptAction {
                        script: {
                            Qt.inputMethod.hide();
                        }
                    }
                }
            }
        ]
    }


    Component {
        id: userPromptComponent
        Login {
            showUsernamePrompt: true
            notificationMessage: root.notificationMessage
            property string idx: "20"

            userListModel: QtObject {
                property string name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Another user")
                property string iconSource: ""
            }

            onLoginRequest: {
                root.notificationMessage = ""
                sddm.login(username, password, sessionButton.currentIndex)
            }

            actionItems: [
                ActionButton {
                    iconSource: "go-previous"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Back")
                    onClicked: mainStack.pop()
                }
            ]
        }
    }

    //Footer
    RowLayout {
        id: footer
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: units.smallSpacing
        }

        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration
            }
        }

        KeyboardButton {
        }

        SessionButton {
            id: sessionButton
        }

        Item {
            Layout.fillWidth: true
        }

    }

    Connections {
        target: sddm
        onLoginFailed: {
            notificationMessage = i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login Failed")
        }
        onLoginSucceeded: {
            //note SDDM will kill the greeter at some random point after this
            //there is no certainty any transition will finish, it depends on the time it
            //takes to complete the init
            mainStack.opacity = 0
            footer.opacity = 0
        }
    }

    onNotificationMessageChanged: {
        if (notificationMessage) {
            notificationResetTimer.start();
        }
    }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: notificationMessage = ""
    }

}
