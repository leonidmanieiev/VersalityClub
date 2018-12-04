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

//request for user location
import "../"
import "../js/helpFunc.js" as Helper
import QtQuick 2.11
import QtQml 2.2
import QtPositioning 5.8
import QtLocation 5.9
import GeoLocation 1.0

Item
{
    property bool isGpsOff: false
    property string callFromPageName: ''
    readonly property int posTimeOut: 30*60000//minutes to milliseconds
    readonly property int posGetFar: 200//in meters

    id: userLocationItem
    enabled: true

    function disableUsability()
    {
        isGpsOff = true;
        Style.isLocated = false;
        //disable parent of userLocationItem which is mapPage or listViewPage
        userLocationItem.parent.parent.enabled = false;
    }

    function enableUsability()
    {
        isGpsOff = false;
        Style.isLocated = true;
        userLocationItem.parent.parent.enabled = true;
    }

    GeoLocationInfo
    {
        onPositionUpdated:
        {
            if(isGpsOff)
            {
                enableUsability();

                AppSettings.beginGroup("user");
                AppSettings.setValue("lat", getLat());
                AppSettings.setValue("lon", getLon());
                AppSettings.endGroup();
                userLocation.requestForPromotions();
                toastMessage.close();
            }
        }
    }

    PositionSource
    {
        property bool initialCoordSet: false
        property bool posMethodSet: false
        property string serverUrl: Style.allProms
        property string secret: AppSettings.value("user/hash")
        property real lat: position.coordinate.latitude
        property real lon: position.coordinate.longitude

        id: userLocation
        active: true
        updateInterval: 1000
        //using .nmea if OS is win, because win does not have GPS module
        nmeaSource: Qt.platform.os === "windows" ? "../output_new.nmea" : undefined

        //handling errors
        function sourceErrorMessage(sourceError)
        {
            var sem = '';

            switch(sourceError)
            {
                case PositionSource.AccessError:
                    sem = Style.noLocationPrivileges; break;
                case PositionSource.ClosedError:
                    sem = Style.turnOnLocationAndWait; break;
                case PositionSource.UnknownSourceError:
                    sem = Style.unknownPosSrcErr; break;
                case PositionSource.SocketError:
                    sem = Style.nmeaConnectionViaSocketErr; break;
                default: break;
            }

            return sem;
        }

        //setting positioning method or return false if no methods allow
        function isPositioningMethodSet(supportedPositioningMethods)
        {
            switch(supportedPositioningMethods)
            {
                case PositionSource.AllPositioningMethods:
                    preferredPositioningMethods=PositionSource.AllPositioningMethods; break;
                case PositionSource.SatellitePositioningMethods :
                    preferredPositioningMethods=PositionSource.SatellitePositioningMethods; break;
                case PositionSource.NonSatellitePositioningMethods:
                    preferredPositioningMethods=PositionSource.NonSatellitePositioningMethods; break;
                default: return false;
            }

            return true;
        }

        //check if user gets further than posGetFar(500) meters from initial position
        function isGetFar(curPosCoord)
        {
            var oldPos = QtPositioning.coordinate(AppSettings.value("user/lat"),
                                                  AppSettings.value("user/lon"));
            return curPosCoord.distanceTo(oldPos) > posGetFar;
        }

        //check if user set his initial position more than posTimeOut(30) minutes ago
        function isTimePassed()
        {
            var oldTime = AppSettings.value("user/timeCheckPoint");
            return Math.abs(new Date() - oldTime) > posTimeOut;
        }

        function updateUserMarker()
        {
            //if loader was mapPageLoader we calling user locariot marker setter
            if(callFromPageName === Style.mapPageId)
                parent.parent.parent.setUserLocationMarker(lat, lon, 0, false);
        }

        //for isGetFar() check
        function saveUserPositionInfo()
        {
            AppSettings.beginGroup("user");
            AppSettings.setValue("lat", lat);
            AppSettings.setValue("lon", lon);
            AppSettings.setValue("timeCheckPoint", new Date());
            AppSettings.endGroup();
        }

        //making request for promotions when started app but user did not move
        //so onPositionChanged won't emit
        function initialPromRequest()
        {
            //initial setting of user marker
            updateUserMarker();
            //saving initial position and timeCheckPoint of user
            saveUserPositionInfo();
            //making request for promotions which depend on position
            requestForPromotions();
        }

        //request promotion info
        function requestForPromotions()
        {
            var request = new XMLHttpRequest();
            var params = 'secret='+secret+'&lat='+AppSettings.value("user/lat")+
                         '&lon='+AppSettings.value("user/lon");

            console.log("request url: " + serverUrl + params);

            request.open('POST', serverUrl);
            request.onreadystatechange = function()
            {
                if(request.readyState === XMLHttpRequest.DONE)
                {
                    if(isNaN(AppSettings.value("user/lat")) || isNaN(AppSettings.value("user/lon")))
                    {
                        disableUsability();
                        console.log(Style.userLocationIsNAN);
                    }
                    else if(request.status === 200)
                    {
                        //saving response for further using
                        Style.promsResponse = request.responseText;
                    }
                }
                else console.log("Pending: " + request.readyState);
            }

            request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.send(params);
        }//function requestForPromotions()

        onSourceErrorChanged:
        {
            if(sourceError === PositionSource.NoError)
            {
                enableUsability();
                return;
            }

            toastMessage.setTextNoAutoClose(sourceErrorMessage(sourceError));
            disableUsability();
            stop();
        }

        onUpdateTimeout: toastMessage.setText(Style.unableToGetLocation)

        onPositionChanged:
        {
            if(posMethodSet)
            {
                if(Qt.platform.os === "windows" && !initialCoordSet)
                {
                    initialCoordSet = true;
                    initialPromRequest();
                }
                //update user coordinates
                else
                {
                    updateUserMarker();

                    if((isGetFar(position.coordinate) || isTimePassed()))
                    {
                        console.log("onPositionChanged (isGetFar: " + isGetFar(position.coordinate) +
                                    " | isTimePassed: " + isTimePassed()) + ")";
                        //out of date, saving timeCheckPoint and making request for promotions
                        saveUserPositionInfo();
                        requestForPromotions();
                    }
                }
            }
        }//onPositionChanged

        Component.onCompleted:
        {
            if(isPositioningMethodSet(supportedPositioningMethods))
            {
                if(Qt.platform.os !== "windows")
                {
                    //if loader is promotionPageLoader wee just need
                    //to save coords. Otherwise full circle
                    if(callFromPageName === Style.promotionPageId)
                        saveUserPositionInfo();
                    else initialPromRequest();
                }
                posMethodSet = true;
                //activating user location button
                Style.isLocated = true;
            }
            else toastMessage.setText(Style.estabLocationMethodErr)
        }
    }//PositionSource

    ToastMessage { id: toastMessage }

    Loader
    {
        id: userLocationLoader
        asynchronous: true
        anchors.fill: parent
        visible: status == Loader.Ready
    }
}
