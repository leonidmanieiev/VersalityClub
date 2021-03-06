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

//top button
import "../"
import "../js/helpFunc.js" as Helper
import QtQuick 2.11
import QtQuick.Controls 2.4

RoundButton
{
    property string buttonText: ''
    property string buttonIconSource
    property alias iconAlias: topControlButtonIcon

    FontLoader
    {
        id: regularText;
        source: Vars.regularFont
    }

    id: topControlButton
    radius: height*0.5
    width: row.width*1.2
    height: Vars.screenHeight*0.05*Vars.iconHeightFactor
    opacity: pressed ? Vars.defaultOpacity : 1
    anchors.top: parent.top
    anchors.topMargin: parent.height*0.05
    anchors.horizontalCenter: parent.horizontalCenter
    contentItem: Item
    {
        Row
        {
            id: row
            spacing: topControlButton.radius
            anchors.centerIn: parent

            Text
            {
                id: buttonTextContent
                clip: true
                text: buttonText
                font.pixelSize: Helper.applyDpr(7, Vars.dpr)
                font.family: regularText.name
                color: Vars.whiteColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Image
            {
                id: topControlButtonIcon
                source: buttonIconSource
                sourceSize.width: topControlButton.radius
                sourceSize.height: topControlButton.radius
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    background: Rectangle
    {
        id: buttonBackground
        clip: true
        radius: parent.radius
        anchors.centerIn: parent
        /*swaped geometry and rotation is a
        trick for left to right gradient*/
        height: parent.width
        width: parent.height
        rotation: -90
        gradient: Gradient
        {
            GradientStop { position: 0.0; color: "#852970" }
            GradientStop { position: 1.0; color: "#5b1a5c" }
        }
    }
}
