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

        di01ID =
            "2021"

        di02ID =
            "2020"

        di01DescID =
            "2019"

        di02DescID =
            "2018"

        value =
            Point.getValue o.node.points di01ID 0 Point.typeDigitalInput

        value1 =
            Point.getValue o.node.points di02ID 1 Point.typeDigitalInput

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

        io =
            Input.text
                []
                { onChange =
                    \d ->
                        o.onEditNodePoint (Point di01DescID 0 Point.typeDescription o.now 0 d 0 0)
                , text = Point.getText o.node.points di01DescID 0 Point.typeDescription
                , placeholder = Nothing
                , label = Input.labelLeft [ width (px 150) ] <| el [ alignRight ] <| text <| ("DI_01: " ++ valueText ++ " - ")
                }
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
                Point.getText o.node.points "456" 0 Point.typeDescription
            ]
            :: (if o.expDetail then
                    [ textInput "456" 0 Point.typeDescription "Description"
                    , numberInput "789"
                        0
                        Point.typeID
                        "ID"
                    , io
                    ]

                else
                    []
               )
