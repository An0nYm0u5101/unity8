/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root

    width: childrenRect.width
    height: childrenRect.height

    signal triggeredAction(var data)

    property alias model: actionRepeater.model

    Button {
        id: moreButton
        property bool expanded: false

        objectName: "button1"
        text: !expanded ? i18n.tr("More...") : i18n.tr("Less...")
        gradient: UbuntuColors.orangeGradient
        onClicked: expanded = !expanded
        width: c.maxWidth
    }

    Column {
        id: c
        property real maxWidth: -1
        anchors.top: moreButton.bottom
        anchors.topMargin: spacing
        objectName: "buttonColumn"
        spacing: height > 0 ? units.gu(1) : 0
        width: maxWidth

        Repeater {
            id: actionRepeater

            delegate: Button {
                objectName: "button" + index
                text: modelData.label || ""
                iconSource: modelData.icon || ""
                gradient: UbuntuColors.orangeGradient
                height: moreButton.expanded ? implicitHeight : 0
                width: implicitWidth < parent.width ? parent.width : implicitWidth
                visible: height > 0
                Component.onCompleted: {
                    c.maxWidth = Math.max(c.maxWidth, implicitWidth);
                }
                onClicked: {
                    root.triggeredAction(modelData)
                }
            }
        }
    }
}
