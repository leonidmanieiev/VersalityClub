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

//page where app tells how to use it
import "../"
import QtQuick 2.11
import QtQuick.Controls 2.4
import "../js/toDp.js" as Convert
import org.leonman.versalityclub 1.0

Page
{
    property string secret: ''

    id: almostDonePage
    width: Style.screenWidth
    height: Style.screenHeight

    Rectangle
    {
        id: area
        anchors.fill: parent
        color: "RED"
    }

    UserSettings { id: userSettings }

    Component.onCompleted:
    {
        userSettings.setValue("userHash", secret)
        console.log(secret);
    }
}
