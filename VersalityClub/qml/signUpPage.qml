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

import "../"
import "../js/helpFunc.js" as Helper
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Page
{
    id: signUpPage
    enabled: Vars.isConnected
    height: Vars.screenHeight
    width: Vars.screenWidth

    Image
    {
        id: background
        clip: true
        width: parent.width
        height: parent.height
        source: "../backgrounds/sign_up_bg.png"
    }

    LogoAndPageTitle { pageTitleText: Vars.signupNoun }

    ColumnLayout
    {
        id: middleFieldsColumns
        width: parent.width*0.8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height*0.2
        spacing: Vars.screenHeight*0.04

        FontLoader
        {
            id: mediumText;
            source: Vars.mediumFont
        }

        CustomLabel
        {
            id: sexLabel
            labelText: Vars.sex
            labelColor: Vars.purpleTextColor
        }

        ControlButton
        {
            id: sexButton
            Layout.fillWidth: true
            Layout.topMargin: -Vars.pageHeight*0.02
            labelText: Vars.m_f
            labelColor: Vars.purpleTextColor
            buttonClickableArea.onClicked:
            {
                labelText === "М" ? labelText = "Ж" : labelText = "М"
                if(labelColor === Vars.errorRed) labelAlias.color = Vars.purpleTextColor;
            }
        }

        CustomLabel
        {
            id: dateofbirthLabel
            labelText: Vars.birthday
            labelColor: Vars.purpleTextColor
            Layout.topMargin: -Vars.pageHeight*0.02
        }

        CustomTextField
        {
            id: dateofbirthField
            Layout.fillWidth: true
            setTextColor: Vars.purpleTextColor
            setFillColor: Vars.whiteColor
            setBorderColor: Vars.purpleBorderColor
            inputMask: Vars.birthdayMask
            inputMethodHints: Qt.ImhDigitsOnly

            /*workaround. if use onPressed it will invoke
              keyboard that won't close by Qt.inputMethod.hide()*/
            MouseArea
            {
                anchors.fill: parent
                onClicked: birthdayPicker.visible = true
            }
        }

        CustomLabel
        {
            id: emailLabel
            labelText: Vars.email
            labelColor: Vars.purpleTextColor
        }

        CustomTextField
        {
            id: emailField
            Layout.fillWidth: true
            setFillColor: Vars.whiteColor
            setBorderColor: Vars.purpleBorderColor
            setTextColor: Vars.purpleTextColor
            placeholderText: Vars.emailPlaceHolderEnter
            inputMethodHints: Qt.ImhEmailCharactersOnly
            validator: RegExpValidator
            { regExp: Vars.emailRegEx }

            onPressed:
            {
                if(color === Vars.errorRed)
                {
                    text = '';
                    color = Vars.purpleTextColor;
                }
            }

            Keys.onReturnPressed: Qt.inputMethod.hide();
        }

        ControlButton
        {
            id: signUpButton
            Layout.fillWidth: true
            labelText: Vars.signup
            labelColor: Vars.whiteColor
            backgroundColor: Vars.purpleBorderColor
            Layout.topMargin: middleFieldsColumns.spacing
            buttonClickableArea.onClicked:
            {
                // get rid of bug when text is empty but displayText is not
                emailField.text = emailField.displayText;
                // close keyboard
                Qt.inputMethod.hide();

                //check for valid inputs (but not sex field, because apple said so)
                //if(sexButton.labelText === Vars.m_f)
                //    sexButton.labelColor = Vars.errorRed;
                if(dateofbirthField.text === '..')
                    dateofbirthField.color = Vars.errorRed;
                else if(emailField.acceptableInput === false)
                {
                    emailField.color = Vars.errorRed;
                    emailField.text = Vars.incorrectEmail;
                }
                else
                {
                    //block button to avoid multiple clicks
                    signUpButton.enabled = false;

                    //saving user info for further using
                    AppSettings.beginGroup("user");
                    AppSettings.setValue("email", emailField.text.toLowerCase());
                    AppSettings.setValue("sex", sexButton.labelText);
                    AppSettings.setValue("birthday", dateofbirthField.text);
                    AppSettings.endGroup();

                    // to show new user some help info about app
                    Vars.fromSignUp = true;

                    signUpPageLoader.setSource("xmlHttpRequest.qml",
                                               { "api": Vars.userSignup,
                                                 "functionalFlag": 'register' });
                }
            }
        }

        ControlBackButton
        {
            id: backButton
            onClicked: signUpPageLoader.source = "initialPage.qml";
        }
    }//middleFieldsColumns

    ScrollDatePicker
    {
        id: birthdayPicker
        visible: false
        anchors.centerIn: parent

        doneButton.onClicked:
        {
            //show date
            dateofbirthField.text = selectedDay+selectedMonth+selectedYear;
            dateofbirthField.color = Vars.purpleTextColor

            //save date fo futher usage
            AppSettings.beginGroup("user");
            AppSettings.setValue("birthday", dateofbirthField.text);
            AppSettings.endGroup();

            birthdayPicker.visible = false;
        }
    }

    Loader
    {
        id: signUpPageLoader
        asynchronous: true
        anchors.fill: parent
        visible: status == Loader.Ready
    }
}
