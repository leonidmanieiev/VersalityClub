/****************************************************************************
**
** Copyright (C) 2019 Leonid Manieiev.
** Contact: leonid.manieiev@gmail.com
**
** This file is part of Versality.
**
** Versality is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** Versality is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Versality. If not, see <https://www.gnu.org/licenses/>.
**
****************************************************************************/

//temaplte popup - toast message
import "../"
import QtQuick 2.11
import QtQuick.Controls 2.4
import "../js/helpFunc.js" as Helper

Popup
{
    property color backgroundColor: Vars.toastGrey
    property bool needRedirect: false

    function setTextNoAutoClose(messageText)
    {
        toastMessage.closePolicy = Popup.NoAutoClose;
        popupContent.text = messageText;
        open();
    }

    function setText(messageText)
    {
        if(popupContent.text === '')
        {
            popupContent.text = messageText;
            open();
        }
    }

    function setTextAndRun(messageText, redirect)
    {
        if(popupContent.text === '')
        {
            needRedirect = redirect;
            popupContent.text = messageText;
            open();
            toastMessageTimer.running = true;
        }
    }

    FontLoader
    {
        id: regularText;
        source: Vars.regularFont
    }

    id: toastMessage
    x: (Vars.screenWidth - popupBackground.width) * 0.5
    y: Vars.pageHeight*0.8
    contentItem: Text
    {
        id: popupContent
        clip: true
        anchors.centerIn: popupBackground
        height: Helper.applyDpr(Vars.defaultFontPixelSize, Vars.dpr)
        width: text.length
        font.pixelSize: Helper.applyDpr(Vars.defaultFontPixelSize, Vars.dpr)
        font.family: regularText.name
        color: Vars.whiteColor
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
    background: Rectangle
    {
        id: popupBackground
        width: popupContent.width*1.2 < Vars.screenWidth*0.8
               ? popupContent.width*1.2 : Vars.screenWidth*0.8
        height: popupContent.height*2
        radius: parent.height*0.5
        color: backgroundColor
    }
    //Smoothed show up animation
    enter: Transition
    {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }
    //Smoothed hide out animation
    exit: Transition
    {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
    }

    onClosed:
    {
        popupContent.text = ''
        if(needRedirect)
            appWindowLoader.source = "mapPage.qml";
    }

    //defines period of time that popup is visiable
    Timer
    {
        id: toastMessageTimer
        interval: 3000
        onTriggered: toastMessage.close()
    }
}
