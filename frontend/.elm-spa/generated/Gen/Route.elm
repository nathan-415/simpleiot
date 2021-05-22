module Gen.Route exposing
    ( Route(..)
    , fromUrl
    , toHref
    )

import Gen.Params.NotFound
import Gen.Params.SignIn
import Gen.Params.Top
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = NotFound
    | SignIn
    | Top


fromUrl : Url -> Route
fromUrl =
    Parser.parse (Parser.oneOf routes) >> Maybe.withDefault NotFound


routes : List (Parser (Route -> a) a)
routes =
    [ Parser.map NotFound Gen.Params.NotFound.parser
    , Parser.map SignIn Gen.Params.SignIn.parser
    , Parser.map Top Gen.Params.Top.parser
    ]


toHref : Route -> String
toHref route =
    let
        joinAsHref : List String -> String
        joinAsHref segments =
            "/" ++ String.join "/" segments
    in
    case route of
        NotFound ->
            joinAsHref [ "not-found" ]
    
        SignIn ->
            joinAsHref [ "sign-in" ]
    
        Top ->
            joinAsHref [ "top" ]

