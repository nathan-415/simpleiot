module Components.NodeModbusMultiIO exposing (view)

import Api.Node exposing (Node)
import Api.Point as Point exposing (Point)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Round
import Time
import UI.Form as Form
import UI.Icon as Icon
import UI.Style as Style exposing (colors)
import UI.ViewIf exposing (viewIf)


view :
    { isRoot : Bool
    , now : Time.Posix
    , zone : Time.Zone
    , modified : Bool
    , expDetail : Bool
    , parent : Maybe Node
    , node : Node
    , onEditNodePoint : Point -> msg
    }
    -> Element msg
view o =
    let
        labelWidth =
            150

        textInput =
            Form.nodeTextInput
                { onEditNodePoint = o.onEditNodePoint
                , node = o.node
                , now = o.now
                , labelWidth = labelWidth
                }

        numberInput =
            Form.nodeNumberInput
                { onEditNodePoint = o.onEditNodePoint
                , node = o.node
                , now = o.now
                , labelWidth = labelWidth
                }

        onOffInput =
            Form.nodeOnOffInput
                { onEditNodePoint = o.onEditNodePoint
                , node = o.node
                , now = o.now
                , labelWidth = labelWidth
                }

        value =
            Point.getValueIndexed o.node.points Point.typeDigitalInput 0

        value1 =
            Point.getValueIndexed o.node.points Point.typeDigitalInput 1

        --valueSet =
        --    Point.getValue o.node.points Point.typeValueSet
        valueText =
            if value == 0 then
                "off"

            else
                "on"

        valueBackgroundColor =
            if valueText == "on" then
                Style.colors.blue

            else
                Style.colors.none

        valueTextColor =
            if valueText == "on" then
                Style.colors.white

            else
                Style.colors.black

        valueText1 =
            if value == 0 then
                "off"

            else
                "on"

        valueBackgroundColor1 =
            if valueText == "on" then
                Style.colors.blue

            else
                Style.colors.none

        valueTextColor1 =
            if valueText == "on" then
                Style.colors.white

            else
                Style.colors.black
    in
    column
        [ width fill
        , Border.widthEach { top = 2, bottom = 0, left = 0, right = 0 }
        , Border.color colors.black
        , spacing 6
        ]
    <|
        wrappedRow [ spacing 10 ]
            [ text <|
                Point.getText o.node.points Point.typeDescription
            ]
            :: (if o.expDetail then
                    [ textInput Point.typeDescription "Description"
                    , numberInput Point.typeID
                        "ID"
                    , row [ spacing 2 ]
                        [ text <|
                            "DI_01: "
                        , el [ paddingXY 7 0, Background.color valueBackgroundColor, Font.color valueTextColor ] <|
                            text <|
                                valueText
                        , Input.text []
                            { onChange =
                                \d ->
                                    o.onEditNodePoint (Point "" Point.typeDigitalInputDesc 0 o.now 0 d 0 0)
                            , text = Point.getTextIndexed o.node.points Point.typeDigitalInputDesc 0
                            , placeholder = Nothing
                            , label =
                                Input.labelLeft [ width (px 0) ] <|
                                    el
                                        [ alignRight ]
                                    <|
                                        text <|
                                            ""
                            }
                        ]
                    , row [ spacing 4 ]
                        [ text <|
                            "DI_02: "
                        , el [ paddingXY 7 0, Background.color valueBackgroundColor, Font.color valueTextColor ] <|
                            text <|
                                valueText
                        , Input.text []
                            { onChange =
                                \d ->
                                    o.onEditNodePoint (Point "" Point.typeDigitalInputDesc 1 o.now 0 d 0 0)
                            , text = Point.getTextIndexed o.node.points Point.typeDigitalInputDesc 1
                            , placeholder = Nothing
                            , label =
                                Input.labelLeft [ width (px 0) ] <|
                                    el
                                        [ alignRight ]
                                    <|
                                        text <|
                                            ""
                            }
                        ]
                    ]

                else
                    []
               )
