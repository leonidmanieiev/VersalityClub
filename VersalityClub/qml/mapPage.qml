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

//main page in map view
import "../"
import "../js/helpFunc.js" as Helper
import QtQuick 2.11
import QtQml 2.11
import QtWebView 1.1
import QtQuick.Controls 2.4
import QtLocation 5.9
import QtPositioning 5.8
import QtQuick.Layouts 1.3

Page
{
    property bool locButtClicked: false
    property int defaultZoomLevel: 11
    readonly property int minZoomLevel: 8
    readonly property int maxZoomLevel: 19
    property real defaultLat: 59.933284
    property real defaultLon: 30.343614
    property bool allGood: false
    readonly property string tilesHost: "http://tiles.maps.sputnik.ru/"
    readonly property string mapCopyright: 'Tiles style by <a href="http://corp.sputnik.ru/maps"'
                                           +' style="color: '+Vars.fontsPurple+'">Cпутник</a> © '
                                           +'<a href="https://www.rt.ru/" style="color: '+
                                           Vars.fontsPurple+'">Ростелеком</a>'
    readonly property string mapDataCopyright: ' Data © <a href="https://www.openstreetmap.org/'
                                               +'copyright" style="color: '+Vars.fontsPurple+'">'
                                               +'OpenStreetMap</a>'
    readonly property int markerSize: Vars.screenWidth*0.1
    readonly property int fromButtonZoomLevel: 16
    readonly property int promsTilesItemHeight: popupWindow.height/3
    //enter window vars
    property bool isPopupOpened: false
    readonly property int popupWindowHeight: height*0.3
    readonly property int popupWindowDurat: 400
    readonly property real popupWindowOpacity: 0.8
    readonly property int popupShowTo: height-Vars.footerButtonsFieldHeight-popupWindowHeight
    readonly property int yToHide: height-Vars.footerButtonsFieldHeight-popupWindowHeight/2
    readonly property int yToInvisible: height-Vars.footerButtonsFieldHeight

    function setUserLocationMarker(lat, lon, _zoomLevel, follow)
    {
        if(locButtClicked)
        {
            userLocationMarker.coordinate =
                    QtPositioning.coordinate(lat, lon);
            userLocationMarker.visible = true;

            if(follow)
                mainMap.center = userLocationMarker.coordinate;

            if(_zoomLevel !== 0)
                mainMap.zoomLevel = _zoomLevel;
        }
    }

    //clusterization and model appling
    function clusterizeAndApply()
    {
        //clusterization accounding to current zoom level
        var clustersTextJson =
                PromotionClusters.clustering(Vars.allPromsData, mainMap.zoomLevel);

        /*/clusterization was unsuccessful
          check console log*/
        if(clustersTextJson.substring(0, 5) === "Error")
        {
            allGood = false;
            notifier.notifierText = Vars.smthWentWrong;
            notifier.visible = true;
            console.log("Parsing response " + clustersTextJson);
        }

        try {
            var promsJSON = JSON.parse(clustersTextJson);
            allGood = true;
            notifier.visible = false;
            //applying promotions at markers model
            Helper.promsJsonToListModelForMarkers(promsJSON);
        } catch (e) {
            allGood = false;
            notifier.notifierText = Vars.smthWentWrong;
            notifier.visible = true;
            console.log("Parsing response error");
        }
    }

    id: mapPage
    enabled: Vars.isConnected
    height: Vars.pageHeight
    width: Vars.screenWidth

    //checking internet connetion
    Network { toastMessage: toastMessage }

    FontLoader
    {
        id: regulatText
        source: "../fonts/Qanelas_Regular.ttf"
    }

    Map
    {
        id: mainMap
        minimumZoomLevel: minZoomLevel
        maximumZoomLevel: maxZoomLevel
        anchors.fill: parent
        width: Vars.screenWidth
        anchors.bottomMargin: Vars.footerButtonsFieldHeight
        center: QtPositioning.coordinate(defaultLat, defaultLon)
        zoomLevel: defaultZoomLevel
        plugin: Plugin
        {
            name: "osm"
            PluginParameter
            {
                id: param
                name: "osm.mapping.custom.host"
                value: tilesHost
            }
            PluginParameter
            {
                name: "osm.mapping.highdpi_tiles"
                value: "true"
            }
            PluginParameter
            {
                name: "osm.useragent"
                value: "VersalityClub"
            }
        }

        //necessary to display custom tiles
        Component.onCompleted:
        {
            for(var i_type in supportedMapTypes)
                if(supportedMapTypes[i_type].name.localeCompare("Custom URL Map") === 0)
                    activeMapType = supportedMapTypes[i_type];
        }

        MapQuickItem
        {
            id: userLocationMarker
            visible: false
            anchorPoint.x: userMarkerIcon.width*0.5
            anchorPoint.y: userMarkerIcon.height
            sourceItem: Image
            {
                id: userMarkerIcon
                source: "../icons/userLocationMarkerIcon.svg"
                sourceSize.width: markerSize
                sourceSize.height: markerSize
            }
        }

        //displays multiple promotion markers
        MapItemView
        {
            id: promMarkersView
            model: ListModel { id: promsMarkersModel }
            delegate: MapQuickItem
            {
                id: promMarkersDelegate
                //wait until get coords
                visible: allGood && lat ? true : false
                anchorPoint.x: markerSize*0.5
                anchorPoint.y: markerSize
                coordinate: QtPositioning.coordinate(lat, lon)
                sourceItem: Loader {
                    sourceComponent: cntOfChilds > 1 ? clusterMarker : promotionMarker
                }

                Component
                {
                    id: clusterMarker
                    ClusterMarker
                    {
                        size: markerSize
                        amountOfChilds: cntOfChilds
                    }
                }

                Component
                {
                    id: promotionMarker
                    PromotionMarker
                    {
                        size: markerSize
                        iconId: icon
                    }
                }

                //show promotion preview after click on mark
                MouseArea
                {
                    id: clickableMarkerArea
                    anchors.fill: parent
                    onClicked:
                    {
                        if(cntOfChilds > 1)
                        {
                            promsTilesListView.model = childs;
                            popupWindow.show();
                        }
                        else
                        {
                            PageNameHolder.push("mapPage.qml");
                            AppSettings.beginGroup("promo");
                            AppSettings.setValue("id", id);
                            AppSettings.endGroup();
                            mapPageLoader.setSource("xmlHttpRequest.qml",
                                                    { "api": Vars.promPreViewModel,
                                                      "functionalFlag": 'user/preprom'
                                                    });
                        }
                    }
                }
            }//delegate: MapQuickItem
        }//MapItemView

        onZoomLevelChanged:
        {
            //check if server responded
            if(Vars.allPromsData.length > 0)
                clusterizeAndApply()
        }
    }//Map

    Rectangle
    {
        id: copyrightTextBackground
        radius: Vars.defaultRadius
        width: childrenRect.width*1.05
        height: childrenRect.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: footerButton.top
        color: Vars.copyrightBackgroundColor

        Text
        {
            id: copyrightText
            anchors.centerIn: parent
            color: Vars.backgroundBlack
            textFormat: Text.RichText;
            text: mapCopyright+mapDataCopyright
            font.pixelSize: Helper.toDp(10, Vars.dpi)
            font.family: regulatText.name
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }//copyrightTextBackground

    Rectangle
    {
        id: popupWindow
        visible: false
        opacity: 0.9
        radius: Vars.defaultRadius
        width: parent.width;
        height: popupWindowHeight
        color: Vars.copyrightBackgroundColor
        anchors.horizontalCenter: parent.horizontalCenter

        NumberAnimation
        {
            id: popupAnim
            target: popupWindow
            property: "y"
            duration: popupWindowDurat
        }

        function show()
        {
            popupAnim.from = Vars.screenHeight;
            popupAnim.to = popupShowTo;
            popupAnim.start();
        }

        function hide()
        {
            popupAnim.from = popupWindow.y;
            popupAnim.to = Vars.screenHeight;
            popupAnim.start();
        }

        Rectangle
        {
            id: dragerLine
            width: parent.width*0.1
            height: parent.height*0.05
            anchors.top: parent.top
            anchors.topMargin: Vars.defaultRadius*0.5
            radius: Vars.defaultRadius
            anchors.horizontalCenter: parent.horizontalCenter
            color: Vars.darkGreyColor
        }

        MouseArea
        {
            id: drager
            width: parent.width
            height: Vars.defaultRadius
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            drag.target: popupWindow
            drag.axis: Drag.YAxis
            drag.minimumY: popupShowTo
            drag.maximumY: Vars.screenHeight
        }

        onYChanged:
        {
            //set flag if entire popup shows
            if(y === popupShowTo)
                isPopupOpened = true;
            else if(isPopupOpened === true)
            {
                //if user swipes popup down enought to automaticly hide it
                if(y > yToHide)
                    hide();
                //if popup hides enought to make it invisible
                if(y > yToInvisible)
                {
                    popupWindow.visible = false;
                    isPopupOpened = false;
                }
            }
            else if(isPopupOpened === false)
                //if popup shows enought to make it visible
                if(y <= yToInvisible)
                    popupWindow.visible = true;
        }

        ListView
        {
            id: promsTilesListView
            clip: true
            anchors.fill: parent
            anchors.topMargin: Vars.defaultRadius
            anchors.bottomMargin: Vars.defaultRadius
            contentHeight: promsTilesItemHeight
            delegate: promsTilesDelegate
        }
    }//popupWindow

    Component
    {
        id: promsTilesDelegate
        Column
        {
            width: popupWindow.width
            anchors.horizontalCenter: parent.horizontalCenter
            leftPadding: width*0.1
            bottomPadding: markerSize*0.25
            Rectangle
            {
                id: parentCategoryIcon
                height: markerSize
                width: parent.width
                radius: height*0.5
                color: "transparent"

                Image
                {
                    id: icon
                    source: "../icons/cat_"+cicon+".png"
                    width: markerSize
                    height: markerSize
                }

                Label
                {
                    id: promotionTitle
                    anchors.left: icon.right
                    anchors.leftMargin: parent.width*0.1
                    anchors.verticalCenter: parent.verticalCenter
                    text: ctitle
                    font.pixelSize: Helper.toDp(16, Vars.dpi)
                    font.bold: true
                    color: Vars.backgroundBlack
                }

                MouseArea
                {
                    id: promsTilesClickableArea
                    anchors.fill: parent
                    onClicked:
                    {
                        PageNameHolder.push("mapPage.qml");
                        AppSettings.beginGroup("promo");
                        AppSettings.setValue("id", cid);
                        AppSettings.endGroup();
                        mapPageLoader.setSource("xmlHttpRequest.qml",
                                                { "api": Vars.promPreViewModel,
                                                  "functionalFlag": 'user/preprom'
                                                  });
                    }
                }
            }//parentCategoryIcon
        }//Column
    }//promsTilesDelegate

    IconedButton
    {
        id: geoLocationButton
        enabled: Vars.isLocated
        width: Vars.footerButtonsHeight*0.9
        height: Vars.footerButtonsHeight*0.9
        buttonIconSource: "../icons/geo_location.png"
        anchors.right: parent.right
        anchors.rightMargin: parent.width*0.02
        anchors.verticalCenter: parent.verticalCenter
        clickArea.onClicked:
        {
            locButtClicked = true;
            setUserLocationMarker(AppSettings.value("user/lat"),
                                  AppSettings.value("user/lon"),
                                  fromButtonZoomLevel, true)
        }
    }

    //switch to listViewPage (proms as list)
    TopControlButton
    {
        id: showInListViewButton
        buttonWidth: Vars.screenWidth*0.57
        buttonText: Vars.showListView
        buttonIconSource: "../icons/show_listview.png"
        onClicked:
        {
            PageNameHolder.push("mapPage.qml");
            mapPageLoader.source = "listViewPage.qml";
        }
    }

    Image
    {
        id: background
        clip: true
        width: parent.width
        height: Vars.footerButtonsFieldHeight
        anchors.bottom: footerButton.bottom
        source: "../backgrounds/map_f.png"
    }

    FooterButtons { id: footerButton; pressedFromPageName: "mapPage.qml" }

    Component.onCompleted:
    {
        PageNameHolder.clear();
        //setting active focus for key capturing
        mapPage.forceActiveFocus();
        //start capturing user location and getting all promotions
        mapPageLoader.source = "userLocation.qml";
    }

    function runParsing()
    {
        if(Vars.allPromsData.substring(0, 6) !== 'PROM-1'
           && Vars.allPromsData.substring(0, 6) !== '[]')
        {      
            clusterizeAndApply();
        }
        else
        {
            notifier.notifierText = Vars.noSuitablePromsNearby;
            notifier.visible = true;
        }
    }

    StaticNotifier { id: notifier }

    ToastMessage { id: toastMessage }

    //workaround to wait until server sends pasponse
    Timer
    {
        id: waitForResponse
        running: Vars.allPromsData === '' ? false : true
        interval: 1
        onTriggered: runParsing()
    }

    Keys.onReleased:
    {
        //back button pressed for android and windows
        if (event.key === Qt.Key_Back || event.key === Qt.Key_B)
        {
            event.accepted = true;
            var pageName = PageNameHolder.pop();

            //if no pages in sequence
            if(pageName === "")
                appWindow.close();
            else mapPageLoader.source = pageName;

            //to avoid not loading bug
            mapPageLoader.reload();
        }
    }

    Loader
    {
        id: mapPageLoader
        asynchronous: true
        anchors.fill: parent
        visible: status == Loader.Ready

        function reload()
        {
            var oldSource = source;
            source = "";
            source = oldSource;
        }
    }
}
