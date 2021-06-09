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

        value =
            Point.getValue o.node.points Point.typeValue

        valueSet =
            Point.getValue o.node.points Point.typeValueSet
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
                    , numberInput Point.typeID "ID"
                    , onOffInput Point.typeValue Point.typeValueSet "DI_01"
                    , onOffInput Point.typeValue Point.typeValueSet "DI_02"
                    ]

                else
                    []
               )
