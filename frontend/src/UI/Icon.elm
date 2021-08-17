module UI.Icon exposing
    ( blank
    , bus
    , check
    , cloud
    , cloudOff
    , database
    , device
    , dot
    , io
    , list
    , minus
    , power
    , send
    , trendingDown
    , trendingUp
    , uploadCloud
    , user
    , users
    , variable
    )

import Element exposing (..)
import FeatherIcons
import Svg
import Svg.Attributes as S


icon : FeatherIcons.Icon -> Element msg
icon iconIn =
    el [ padding 5 ] <| html <| FeatherIcons.toHtml [] iconIn



-- non-clickable icons


bus : Element msg
bus =
    [ Svg.line [ S.x1 "11", S.y1 "3", S.x2 "11", S.y2 "14" ] []
    , Svg.polyline [ S.points "3 14 3 9 19 9 19 14" ] []
    , Svg.rect [ S.fill "rgb(0,0,0)", S.stroke "none", S.x "0", S.y "14", S.width "6", S.height "5" ] []
    , Svg.rect [ S.fill "rgb(0,0,0)", S.stroke "none", S.x "8", S.y "14", S.width "6", S.height "5" ] []
    , Svg.rect [ S.fill "rgb(0,0,0)", S.stroke "none", S.x "16", S.y "14", S.width "6", S.height "5" ] []
    ]
        |> FeatherIcons.customIcon
        |> icon


dot : Element msg
dot =
    [ Svg.circle
        [ S.style "fill:#000000;fill-opacity:1;"
        , S.cx "11.903377"
        , S.cy "11.823219"
        , S.r "3.1"
        ]
        []
    ]
        |> FeatherIcons.customIcon
        |> icon


variable : Element msg
variable =
    [ Svg.g [ S.transform "scale(3.3,4.7)", S.style "stroke-width:0.25;fill:#000000" ]
        [ Svg.path [ S.d "m 6.0407008,4.5926947 q -0.048802,0.028837 -0.095385,0.00222 -0.044365,-0.026619 -0.075421,-0.077639 -0.031056,-0.05102 -0.03771,-0.1064766 -0.00665,-0.053238 0.028837,-0.077639 Q 6.025173,4.2244632 6.1871061,4.0714031 6.3490392,3.9183431 6.4754802,3.7164812 6.6041393,3.5146194 6.6839968,3.2617376 q 0.079857,-0.2551001 0.079857,-0.5634385 0,-0.3083384 -0.079857,-0.5634385 Q 6.6041393,1.8797604 6.4754802,1.6756804 6.3490392,1.4716003 6.1871061,1.3185402 6.025173,1.1632619 5.8610216,1.054567 q -0.035492,-0.024401 -0.028837,-0.0776391 0.00665,-0.0554565 0.03771,-0.10647656 0.031056,-0.05102 0.075421,-0.0776392 0.046584,-0.0266191 0.095385,0.002218 0.186334,0.1109131 0.372668,0.29059229 0.1885523,0.1796792 0.3393941,0.4214698 0.1508418,0.2395722 0.2440088,0.5390376 0.095385,0.2994653 0.095385,0.652169 0,0.3527036 -0.095385,0.6499507 Q 6.9036047,3.6454969 6.7527629,3.8850691 6.6019211,4.1246414 6.4133688,4.3021024 6.2270348,4.4817816 6.0407008,4.5926947 Z" ] []
        , Svg.path [ S.d "M 3.4652989,2.3389406 2.7732012,1.3806515 H 2.6201411 q -0.075421,0 -0.1086948,-0.033274 -0.031056,-0.033274 -0.031056,-0.1175679 0,-0.084294 0.031056,-0.1175678 0.033274,-0.033274 0.1086948,-0.033274 h 0.7630821 q 0.075421,0 0.1064766,0.033274 0.033274,0.033274 0.033274,0.1175678 0,0.084294 -0.033274,0.1175679 -0.031056,0.033274 -0.1064766,0.033274 H 3.1857979 L 3.6760338,2.0816223 4.1684879,1.3806515 H 4.0353922 q -0.075421,0 -0.1086948,-0.033274 -0.031056,-0.033274 -0.031056,-0.1175679 0,-0.084294 0.031056,-0.1175678 0.033274,-0.033274 0.1086948,-0.033274 h 0.6743516 q 0.075421,0 0.1064765,0.033274 0.033274,0.033274 0.033274,0.1175678 0,0.084294 -0.033274,0.1175679 -0.031056,0.033274 -0.1064765,0.033274 H 4.5655568 L 3.8801139,2.3433772 4.6476325,3.4103611 h 0.1286591 q 0.075421,0 0.1064766,0.033274 0.033274,0.033274 0.033274,0.1175679 0,0.084294 -0.033274,0.1175679 -0.031056,0.033274 -0.1064766,0.033274 H 3.9910269 q -0.075421,0 -0.1086948,-0.033274 -0.031056,-0.033274 -0.031056,-0.1175679 0,-0.084294 0.031056,-0.1175679 0.033274,-0.033274 0.1086948,-0.033274 H 4.2328175 L 3.6671607,2.6006955 3.0881944,3.4103611 h 0.1841157 q 0.075421,0 0.1064766,0.033274 0.033274,0.033274 0.033274,0.1175679 0,0.084294 -0.033274,0.1175679 -0.031056,0.033274 -0.1064766,0.033274 H 2.5535933 q -0.075421,0 -0.1086948,-0.033274 -0.031056,-0.033274 -0.031056,-0.1175679 0,-0.084294 0.031056,-0.1175679 0.033274,-0.033274 0.1086948,-0.033274 h 0.1375322 z" ] []
        , Svg.path [ S.d "M 1.2891841,4.5926947 Q 1.1028501,4.4817816 0.91429783,4.3021024 0.72796384,4.1246414 0.57712203,3.8850691 0.42628023,3.6454969 0.33089497,3.3482498 q -0.093167,-0.2972471 -0.093167,-0.6499507 0,-0.3527037 0.093167,-0.652169 Q 0.42628023,1.7466647 0.57712203,1.5070925 0.72796384,1.2653019 0.91429783,1.0856227 1.1028501,0.90594351 1.2891841,0.79503041 q 0.048802,-0.0288374 0.093167,-0.002218 0.046584,0.0266191 0.077639,0.0776392 0.031056,0.05102 0.03771,0.10647656 0.00665,0.0532383 -0.028837,0.0776391 -0.1641514,0.1086949 -0.3260845,0.2639732 -0.16193311,0.1530601 -0.2905923,0.3571402 -0.12865919,0.20408 -0.20851661,0.4591802 -0.0776392,0.2551001 -0.0776392,0.5634385 0,0.3083384 0.0776392,0.5634385 0.0798574,0.2528818 0.20851661,0.4547436 0.12865919,0.2018619 0.2905923,0.3549219 0.1619331,0.1530601 0.3260845,0.2617549 0.035492,0.024401 0.028837,0.077639 -0.00665,0.055457 -0.03771,0.1064766 -0.031056,0.05102 -0.077639,0.077639 -0.044365,0.026619 -0.093167,-0.00222 z" ] []
        ]
    ]
        |> FeatherIcons.customIcon
        |> icon


io : Element msg
io =
    [ Svg.polyline [ S.points "3 6 3 16" ] []
    , Svg.polyline [ S.points "12 3 8 19" ] []
    , Svg.ellipse [ S.cx "18", S.cy "11", S.rx "3", S.ry "5" ] []
    ]
        |> FeatherIcons.customIcon
        |> icon


cloudOff : Element msg
cloudOff =
    icon FeatherIcons.cloudOff


cloud : Element msg
cloud =
    icon FeatherIcons.cloud


power : Element msg
power =
    icon FeatherIcons.power


user : Element msg
user =
    icon FeatherIcons.user


users : Element msg
users =
    icon FeatherIcons.users


device : Element msg
device =
    icon FeatherIcons.hardDrive


minus : Element msg
minus =
    icon FeatherIcons.minus


blank : Element msg
blank =
    el [ width (px 33), height (px 33) ] <| text ""


list : Element msg
list =
    icon FeatherIcons.list


check : Element msg
check =
    icon FeatherIcons.check


trendingUp : Element msg
trendingUp =
    icon FeatherIcons.trendingUp


trendingDown : Element msg
trendingDown =
    icon FeatherIcons.trendingDown


send : Element msg
send =
    icon FeatherIcons.send


uploadCloud : Element msg
uploadCloud =
    icon FeatherIcons.uploadCloud


database : Element msg
database =
    icon FeatherIcons.database
