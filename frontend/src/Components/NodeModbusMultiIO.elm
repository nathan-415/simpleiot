module Components.NodeModbusMultiIO exposing (view)

import Api.Node exposing (Node)
import Api.Point as Point exposing (Point)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
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

        optionInput =
            Form.nodeOptionInput
                { onEditNodePoint = o.onEditNodePoint
                , node = o.node
                , now = o.now
                , labelWidth = labelWidth
                }

        checkboxInput =
            Form.nodeCheckboxInput
                { onEditNodePoint = o.onEditNodePoint
                , node = o.node
                , now = o.now
                , labelWidth = labelWidth
                }

        counterWithReset =
            Form.nodeCounterWithReset
                { onEditNodePoint = o.onEditNodePoint
                , node = o.node
                , now = o.now
                , labelWidth = labelWidth + 150
                }

        modbusIOType =
            Point.getText o.node.points Point.typeModbusIOType

        isClient =
            case o.parent of
                Just p ->
                    Point.getText p.points Point.typeClientServer == Point.valueClient

                Nothing ->
                    False

        isWrite =
            modbusIOType
                == Point.valueModbusHoldingRegister
                || modbusIOType
                == Point.valueModbusCoil

        value =
            Point.getValue o.node.points Point.typeValue

        valueSet =
            Point.getValue o.node.points Point.typeValueSet

        isRegister =
            modbusIOType
                == Point.valueModbusInputRegister
                || modbusIOType
                == Point.valueModbusHoldingRegister

        isReadOnly =
            Point.getValue o.node.points Point.typeReadOnly == 1

        valueText =
            if isRegister then
                String.fromFloat (Round.roundNum 2 value)

            else if value == 0 then
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
    in
    column
        [ width fill
        , Border.widthEach { top = 2, bottom = 0, left = 0, right = 0 }
        , Border.color colors.black
        , spacing 6
        ]
    <|
        wrappedRow [ spacing 10 ]
            [ Icon.io
            , text <|
                Point.getText o.node.points Point.typeDescription
                    ++ ": "
            , el [ paddingXY 7 0, Background.color valueBackgroundColor, Font.color valueTextColor ] <|
                text <|
                    valueText
                        ++ (if isRegister then
                                " " ++ Point.getText o.node.points Point.typeUnits

                            else
                                ""
                           )
            , text <|
                if isClient && isWrite && not isReadOnly && value /= valueSet then
                    " (cmd pending)"

                else
                    ""
            ]
            :: (if o.expDetail then
                    [ textInput Point.typeDescription "Description"
                    , numberInput Point.typeID "ID"
                    , onOffInput Point.typeValue Point.typeValueSet "DI_01"
                    ]

                else
                    []
               )
