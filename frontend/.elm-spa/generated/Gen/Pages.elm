module Gen.Pages exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation exposing (Key)
import Effect exposing (Effect)
import ElmSpa.Page
import Gen.Params.NotFound
import Gen.Params.SignIn
import Gen.Params.Top
import Gen.Model as Model
import Gen.Msg as Msg
import Gen.Route as Route exposing (Route)
import Page exposing (Page)
import Pages.NotFound
import Pages.SignIn
import Pages.Top
import Request exposing (Request)
import Shared
import Task
import Url exposing (Url)
import View exposing (View)


type alias Model =
    Model.Model


type alias Msg =
    Msg.Msg


init : Route -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
init route =
    case route of
        Route.NotFound ->
            pages.notFound.init ()
    
        Route.SignIn ->
            pages.signIn.init ()
    
        Route.Top ->
            pages.top.init ()


update : Msg -> Model -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
update msg_ model_ =
    case ( msg_, model_ ) of
        ( Msg.NotFound msg, Model.NotFound params model ) ->
            pages.notFound.update params msg model
    
        ( Msg.SignIn msg, Model.SignIn params model ) ->
            pages.signIn.update params msg model
    
        ( Msg.Top msg, Model.Top params model ) ->
            pages.top.update params msg model

        _ ->
            \_ _ _ -> ( model_, Effect.none )


view : Model -> Shared.Model -> Url -> Key -> View Msg
view model_ =
    case model_ of
        Model.Redirecting_ ->
            \_ _ _ -> View.none
    
        Model.NotFound params model ->
            pages.notFound.view params model
    
        Model.SignIn params model ->
            pages.signIn.view params model
    
        Model.Top params model ->
            pages.top.view params model


subscriptions : Model -> Shared.Model -> Url -> Key -> Sub Msg
subscriptions model_ =
    case model_ of
        Model.Redirecting_ ->
            \_ _ _ -> Sub.none
    
        Model.NotFound params model ->
            pages.notFound.subscriptions params model
    
        Model.SignIn params model ->
            pages.signIn.subscriptions params model
    
        Model.Top params model ->
            pages.top.subscriptions params model



-- INTERNALS


pages :
    { notFound : Bundle Gen.Params.NotFound.Params Pages.NotFound.Model Pages.NotFound.Msg
    , signIn : Bundle Gen.Params.SignIn.Params Pages.SignIn.Model Pages.SignIn.Msg
    , top : Bundle Gen.Params.Top.Params Pages.Top.Model Pages.Top.Msg
    }
pages =
    { notFound = bundle Pages.NotFound.page Model.NotFound Msg.NotFound
    , signIn = bundle Pages.SignIn.page Model.SignIn Msg.SignIn
    , top = bundle Pages.Top.page Model.Top Msg.Top
    }


type alias Bundle params model msg =
    ElmSpa.Page.Bundle params model msg Shared.Model (Effect Msg) Model Msg (View Msg)


bundle page toModel toMsg =
    ElmSpa.Page.bundle
        { redirecting =
            { model = Model.Redirecting_
            , view = View.none
            }
        , toRoute = Route.fromUrl
        , toUrl = Route.toHref
        , fromCmd = Effect.fromCmd
        , mapEffect = Effect.map toMsg
        , mapView = View.map toMsg
        , toModel = toModel
        , toMsg = toMsg
        , page = page
        }


type alias Static params =
    Bundle params () Never


static : View Never -> (params -> Model) -> Static params
static view_ toModel =
    { init = \params _ _ _ -> ( toModel params, Effect.none )
    , update = \params _ _ _ _ _ -> ( toModel params, Effect.none )
    , view = \_ _ _ _ _ -> View.map never view_
    , subscriptions = \_ _ _ _ _ -> Sub.none
    }
    
