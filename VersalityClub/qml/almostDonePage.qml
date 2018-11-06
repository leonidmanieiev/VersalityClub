/****************************************************************************
**
** Copyright (C) 2018 Leonid Manieiev.
** Contact: leonid.manieiev@gmail.com
**
** This file is part of Versality Club.
**
** Versality Club is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** Versality Club is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
**
****************************************************************************/

//page where app tells how to use itself
import "../"
import "../js/helpFunc.js" as Helper
import Network 1.0
import QtQuick 2.11
import QtQuick.Controls 2.4

Page
{
    id: almostDodePage
    enabled: Style.isConnected
    height: Style.screenHeight
    width: Style.screenWidth

    //checking internet connetion
    NetworkInfo
    {
        onNetworkStatusChanged:
        {
            if(accessible === 1)
            {
                Style.isConnected = true;
                almostDodePage.enabled = true;
                toastMessage.setTextAndRun(qsTr("Internet re-established"));
            }
            else
            {
                Style.isConnected = false;
                almostDodePage.enabled = false;
                toastMessage.setTextAndRun(qsTr("No Internet connection"));
            }
        }
    }

    background: Rectangle
    {
        id: background
        anchors.fill: parent
        color: Style.mainPurple
    }

    ControlButton
    {
        id: startUsingAppButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Helper.toDp(parent.height/14, Style.dpi)
        buttonText: qsTr("Все понятно, начать работу!")
        labelContentColor: Style.backgroundWhite
        backgroundColor: Style.mainPurple
        setBorderColor: Style.backgroundWhite
        onClicked:
        {
            almostDonePageLoader.setSource("xmlHttpRequest.qml",
                                     { "serverUrl": 'http://patrick.ga:8080/api/user?',
                                       "functionalFlag": 'user'
                                     });
        }
    }

    ToastMessage { id: toastMessage }

    Component.onCompleted: PageNameHolder.clear()

    Loader
    {
        id: almostDonePageLoader
        asynchronous: true
        anchors.fill: parent
        visible: status == Loader.Ready
    }
}
