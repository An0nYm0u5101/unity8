import QtQuick 2.0
import QtTest 1.0
import Ubuntu.Components 0.1
import "../../../Dash"
import "CardHelpers.js" as Helpers

Rectangle {
    id: root
    width: units.gu(80)
    height: units.gu(72)
    color: "#88FFFFFF"

    property string defaultLayout: '
    {
      "schema-version": 1,
      "template": {
        "category-layout": "grid",
        "card-layout": "vertical",
        "card-size": "medium",
        "overlay-mode": null,
        "collapsed-rows": 2
      },
      "components": {
        "title": null,
        "art": {
            "aspect-ratio": 1.0,
            "fill-mode": "crop"
        },
        "subtitle": null,
        "mascot": null,
        "emblem": null,
        "old-price": null,
        "price": null,
        "alt-price": null,
        "rating": {
          "type": "stars",
          "range": [0, 5],
          "full": "image://theme/rating-star-full",
          "half": "image://theme/rating-star-half",
          "empty": "image://theme/rating-star-empty"
        },
        "alt-rating": null,
        "summary": null
      },
      "resources": {}
    }'

    property string cardData: '
    {
      "art": "../tests/qmltests/Dash/artwork/music-player-design.png",
      "mascot": "../tests/qmltests/Dash/artwork/avatar.png",
      "title": "foo",
      "subtitle": "bar",
      "summary": "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }'

    property string fullMapping: '
    {
      "title": "title",
      "art": "art",
      "subtitle": "subtitle",
      "mascot": "mascot",
      "summary": "summary"
    }'

    property var cardsModel: [
        {
            "name": "Art, header, summary - vertical",
            "layout": { "components": JSON.parse(fullMapping) }
        },
        {
            "name": "Art, header, summary - vertical, small",
            "layout": { "template": { "card-size": "small" }, "components": JSON.parse(fullMapping) }
        },
        {
            "name": "Art, header, summary - vertical, large",
            "layout": { "template": { "card-size": "large" }, "components": JSON.parse(fullMapping) }
        },
        {
            "name": "Art, header, summary - vertical, wide",
            "layout": { "components": Helpers.update(JSON.parse(root.fullMapping), { "art": { "aspect-ratio": 2 } }) }
        },
        {
            "name": "Art, title - vertical, fitted",
            "layout": { "components": Helpers.update(JSON.parse(root.fullMapping), { "art": { "fill-mode": "fit" } }) }
        }
    ]

    Card {
        id: card
        anchors { top: parent.top; left: parent.left; margins: units.gu(1) }

        template: Helpers.update(JSON.parse(root.defaultLayout), Helpers.tryParse(layoutArea.text, layoutError))['template'];
        components: Helpers.update(JSON.parse(root.defaultLayout), Helpers.tryParse(layoutArea.text, layoutError))['components'];
        cardData: Helpers.mapData(dataArea.text, components, dataError)
    }

    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right}
        width: units.gu(40)
        color: "lightgrey"

        Column {
            anchors { fill: parent; margins: units.gu(1) }
            spacing: units.gu(1)

            OptionSelector {
                id: selector
                model: cardsModel
                delegate: OptionSelectorDelegate { text: modelData.name }
                onSelectedIndexChanged: updateAreas()
                Component.onCompleted: updateAreas()

                function updateAreas() {
                    var element = cardsModel[selectedIndex];
                    if (element) {
                        layoutArea.text = JSON.stringify(element.layout, undefined, 2) || "{}";
                        // FIXME: don't overwrite data
                        var data = JSON.parse(root.cardData);
                        Helpers.update(data, element.data);
                        dataArea.text = JSON.stringify(data, undefined, 2) || "{}";
                    } else {
                        layoutArea.text = "";
                        dataArea.text = "";
                    }

                }
            }

            TextArea {
                id: layoutArea
                anchors { left: parent.left; right: parent.right }
                height: units.gu(25)
            }

            Label {
                id: layoutError
                anchors { left: parent.left; right: parent.right }
                height: units.gu(4)
                color: "orange"
            }

            TextArea {
                id: dataArea
                anchors { left: parent.left; right: parent.right }
                height: units.gu(25)
            }

            Label {
                id: dataError
                anchors { left: parent.left; right: parent.right }
                height: units.gu(4)
                color: "orange"
            }
        }
    }

    TestCase {
        id: testCase

        when: windowShown

        property Item header: findChild(card, "cardHeader")
        property Item art: findChild(card, "artShape")
        property Item artImage: findChild(card, "artImage")
        property Item summary: findChild(card, "summaryLabel")

        // Find an object with the given name in the children tree of "obj"
        function findChild(obj,objectName) {
            var childs = new Array(0);
            childs.push(obj)
            while (childs.length > 0) {
                if (childs[0].objectName == objectName) {
                    return childs[0]
                }
                for (var i in childs[0].children) {
                    childs.push(childs[0].children[i])
                }
                childs.splice(0, 1);
            }
            return null;
        }

        function initTestCase() {
            verify(testCase.header !== undefined, "Couldn't find header object.");
        }

        function cleanup() {
            selector.selectedIndex = -1;
        }


        function test_header_binding_data() {
            return [
                { tag: "Mascot", property: "mascot", value: Qt.resolvedUrl("artwork/avatar.png"), index: 0 },
                { tag: "Title", property: "title", value: "foo", index: 0 },
                { tag: "Subtitle", property: "subtitle", value: "bar", index: 0 },
            ];
        }

        function test_header_binding(data) {
            selector.selectedIndex = data.index;
            tryCompare(testCase.header, data.property, data.value);
        }

        function test_card_binding_data() {
            return [
                { tag: "Art", object: artImage, property: "source", value: Qt.resolvedUrl("artwork/music-player-design.png"), index: 0 },
                { tag: "Summary", object: summary, property: "text", field: "summary", index: 0 },
                { tag: "Fit", object: art, fill: Image.PreserveAspectFit, index: 4 },
            ];
        }

        function test_card_binding(data) {
            selector.selectedIndex = data.index;

            if (data.hasOwnProperty('value')) {
                tryCompare(data.object, data.property, data.value);
            }

            if (data.hasOwnProperty('field')) {
                tryCompare(data.object, data.property, card.cardData[data.field]);
            }
        }

        function test_card_size_data() {
            return [
                { tag: "Medium", width: units.gu(18.5), index: 0 },
                { tag: "Small", width: units.gu(12), size: "small", index: 0 },
                { tag: "Large", width: units.gu(38), size: "large", index: 0 },
                { tag: "Wide", width: units.gu(18.5), aspect: 0.5, index: 0 },
            ]
        }

        function test_card_size(data) {
            selector.selectedIndex = data.index;

            if (data.hasOwnProperty("size")) {
                card.template['card-size'] = data.size;
                card.templateChanged();
            }

            if (data.hasOwnProperty("aspect")) {
                card.components['art']['aspect-ratio'] = data.aspect;
                card.componentsChanged();
            }

            if (data.hasOwnProperty("width")) {
                tryCompare(card, "width", data.width);
            }

            if (data.hasOwnProperty("height")) {
                tryCompare(card, "height", data.height);
            }
        }

        function test_art_size_data() {
            return [
                { tag: "Medium", width: units.gu(18.5), fill: Image.PreserveAspectCrop, index: 0 },
                { tag: "Small", width: units.gu(12), index: 1 },
                { tag: "Large", width: units.gu(38), index: 2 },
                { tag: "Wide", height: units.gu(9.25), index: 3 },
                { tag: "Fit", height: units.gu(18.5), width: units.gu(9.25), index: 4 },
            ]
        }

        function test_art_size(data) {
            selector.selectedIndex = data.index;

            if (data.hasOwnProperty("size")) {
                card.template['card-size'] = data.size;
                card.templateChanged();
            }

            if (data.hasOwnProperty("aspect")) {
                card.components['art']['aspect-ratio'] = data.aspect;
                card.componentsChanged();
            }

            if (data.hasOwnProperty("width")) {
                tryCompare(art, "width", data.width);
            }

            if (data.hasOwnProperty("height")) {
                tryCompare(art, "height", data.height);
            }

            if (data.hasOwnProperty("fill")) {
                tryCompare(artImage, "fillMode", data.fill);
            }
        }
    }
}
