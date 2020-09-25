module Pages.Groups exposing (Model, Msg, Params, page)

import Api.Auth exposing (Auth)
import Api.Data as Data exposing (Data)
import Api.Device as Dev
import Api.Group as Group exposing (Group)
import Api.Response exposing (Response)
import Api.User as User exposing (User)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Http
import List.Extra
import Shared
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)
import UI.Form as Form
import UI.Icon as Icon
import UI.Style as Style
import Utils.Route


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
        }



-- INIT


type alias Params =
    ()


type alias Model =
    { auth : Auth
    , groupEdit : Maybe Group
    , newUser : Maybe NewUser
    , newDevice : Maybe NewDevice
    , error : Maybe String
    , groups : List Group
    , devices : List Dev.Device
    , users : List User
    , newGroupUserFound : Maybe User
    , newGroupDeviceFound : Maybe Dev.Device
    }


defaultModel : Model
defaultModel =
    { auth = { email = "", token = "", isRoot = False }
    , groupEdit = Nothing
    , newUser = Nothing
    , newDevice = Nothing
    , error = Nothing
    , groups = []
    , devices = []
    , users = []
    , newGroupUserFound = Nothing
    , newGroupDeviceFound = Nothing
    }


type alias NewUser =
    { groupId : String
    , userEmail : String
    }


type alias NewDevice =
    { groupId : String
    , deviceId : String
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared _ =
    case shared.auth of
        Just auth ->
            let
                model =
                    { defaultModel | auth = auth }
            in
            ( model
            , Cmd.batch
                [ User.list { token = auth.token, onResponse = ApiRespUserList }
                , Dev.list { token = auth.token, onResponse = ApiRespDeviceList }
                ]
            )

        Nothing ->
            ( defaultModel
            , Utils.Route.navigate shared.key Route.SignIn
            )



-- UPDATE


type Msg
    = EditGroup Group
    | DiscardGroupEdits
    | New
    | AddUser String
    | CancelAddUser
    | EditNewUser String
    | AddDevice String
    | CancelAddDevice
    | EditNewDevice String
    | ApiRespList (Data (List Group))
    | ApiUpdate Group
    | ApiDelete String
    | ApiNewDevice String String
    | ApiRemoveDevice String String
    | ApiNewUser Group String
    | ApiRemoveUser Group String
    | ApiRespUpdate (Data Response)
    | ApiRespDelete (Data Response)
    | ApiRespNewDevice (Data Response)
    | ApiRespUserList (Data (List User))
    | ApiRespDeviceList (Data (List Dev.Device))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditGroup group ->
            ( { model | groupEdit = Just group }
            , Cmd.none
            )

        DiscardGroupEdits ->
            ( { model | groupEdit = Nothing }
            , Cmd.none
            )

        New ->
            ( { model | groupEdit = Just Group.empty }
            , Cmd.none
            )

        AddUser groupId ->
            ( { model | newUser = Just { groupId = groupId, userEmail = "" } }
            , Cmd.none
            )

        CancelAddUser ->
            ( { model | newUser = Nothing }
            , Cmd.none
            )

        EditNewUser userEmail ->
            case model.newUser of
                Just newUser ->
                    ( { model | newUser = Just { newUser | userEmail = userEmail } }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        ApiUpdate group ->
            ( { model | groupEdit = Nothing }
            , Cmd.none
            )

        ApiDelete id ->
            ( { model | groupEdit = Nothing }
            , Cmd.none
            )

        ApiRemoveUser group userId ->
            let
                users =
                    List.filter
                        (\ur -> ur.userId /= userId)
                        group.users

                updatedGroup =
                    { group | users = users }
            in
            ( model
            , Cmd.none
            )

        ApiNewUser group userId ->
            let
                -- only add user if it does not already exist
                users =
                    case
                        List.Extra.find
                            (\ur -> ur.userId == userId)
                            group.users
                    of
                        Just _ ->
                            group.users

                        Nothing ->
                            { userId = userId, roles = [ "user" ] } :: group.users

                updatedGroup =
                    { group | users = users }
            in
            ( { model | newUser = Nothing }
            , Cmd.none
            )

        ApiRemoveDevice groupId deviceId ->
            ( model
            , case
                List.Extra.find (\d -> d.id == deviceId)
                    model.devices
              of
                Just device ->
                    let
                        groups =
                            List.filter (\o -> o /= groupId)
                                device.groups
                    in
                    Dev.postGroups
                        { token = model.auth.token
                        , id = device.id
                        , groups = groups
                        , onResponse = ApiRespNewDevice
                        }

                Nothing ->
                    Cmd.none
            )

        AddDevice groupId ->
            ( { model | newDevice = Just { groupId = groupId, deviceId = "" } }
            , Cmd.none
            )

        CancelAddDevice ->
            ( { model | newDevice = Nothing }
            , Cmd.none
            )

        EditNewDevice deviceId ->
            case model.newDevice of
                Just newDevice ->
                    ( { model | newDevice = Just { newDevice | deviceId = deviceId } }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        ApiNewDevice groupId deviceId ->
            case
                List.Extra.find (\d -> d.id == deviceId)
                    model.devices
            of
                Just device ->
                    let
                        groups =
                            case
                                List.Extra.find (\o -> o == groupId)
                                    device.groups
                            of
                                Just _ ->
                                    device.groups

                                Nothing ->
                                    groupId :: device.groups

                        -- optimistically update devices
                        devices =
                            List.map
                                (\d ->
                                    if d.id == device.id then
                                        { d | groups = groups }

                                    else
                                        d
                                )
                                model.devices
                    in
                    ( { model | newDevice = Nothing, devices = devices }
                    , Dev.postGroups
                        { token = model.auth.token
                        , id = device.id
                        , groups = groups
                        , onResponse = ApiRespNewDevice
                        }
                    )

                Nothing ->
                    ( { model | newDevice = Nothing }, Cmd.none )

        ApiRespUpdate _ ->
            ( model, Cmd.none )

        ApiRespDelete _ ->
            ( model, Cmd.none )

        ApiRespList _ ->
            ( model, Cmd.none )

        ApiRespNewDevice _ ->
            ( model, Cmd.none )

        ApiRespUserList _ ->
            ( model, Cmd.none )

        ApiRespDeviceList _ ->
            ( model, Cmd.none )


save : Model -> Shared.Model -> Shared.Model
save model shared =
    { shared
        | error =
            case model.error of
                Nothing ->
                    shared.error

                Just _ ->
                    model.error
        , lastError =
            case model.error of
                Nothing ->
                    shared.lastError

                Just _ ->
                    shared.now
    }


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load _ model =
    ( { model | error = Nothing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "SIOT Groups"
    , body =
        [ column
            [ width fill, spacing 32 ]
            [ el Style.h2 <| text "Groups"
            , el [ padding 16, width fill, Font.bold ] <|
                Form.button
                    { label = "new group"
                    , color = Style.colors.blue
                    , onPress = New
                    }
            , viewGroups model
            ]
        ]
    }


viewGroups : Model -> Element Msg
viewGroups model =
    column
        [ width fill
        , spacing 40
        ]
    <|
        List.map (\o -> viewGroup model o.mod o.group) <|
            mergeGroupEdit model.groups model.groupEdit


type alias GroupMod =
    { group : Group
    , mod : Bool
    }


mergeGroupEdit : List Group -> Maybe Group -> List GroupMod
mergeGroupEdit groups groupEdit =
    case groupEdit of
        Just edit ->
            let
                groupsMapped =
                    List.map
                        (\o ->
                            if edit.id == o.id then
                                { group = edit, mod = True }

                            else
                                { group = o, mod = False }
                        )
                        groups
            in
            if edit.id == "" then
                { group = edit, mod = True } :: groupsMapped

            else
                groupsMapped

        Nothing ->
            List.map (\o -> { group = o, mod = False }) groups


viewGroup : Model -> Bool -> Group -> Element Msg
viewGroup model modded group =
    let
        devices =
            List.filter
                (\d ->
                    case List.Extra.find (\groupId -> group.id == groupId) d.groups of
                        Just _ ->
                            True

                        Nothing ->
                            False
                )
                model.devices
    in
    column
        ([ width fill
         , Border.widthEach { top = 2, bottom = 0, left = 0, right = 0 }
         , Border.color Style.colors.black
         , spacing 6
         ]
            ++ (if modded then
                    [ Background.color Style.colors.orange
                    , below <|
                        Form.buttonRow
                            [ Form.button
                                { label = "discard"
                                , color = Style.colors.gray
                                , onPress = DiscardGroupEdits
                                }
                            , Form.button
                                { label = "save"
                                , color = Style.colors.blue
                                , onPress = ApiUpdate group
                                }
                            ]
                    ]

                else
                    []
               )
        )
        [ if group.id == "00000000-0000-0000-0000-000000000000" then
            el [ padding 16 ] (text group.name)

          else
            row
                []
                [ Form.viewTextProperty
                    { name = "Group name"
                    , value = group.name
                    , action = \x -> EditGroup { group | name = x }
                    }
                , Icon.x (ApiDelete group.id)
                ]
        , row []
            [ el [ padding 16, Font.italic, Font.color Style.colors.gray ] <| text "Users"
            , case model.newUser of
                Just newUser ->
                    if newUser.groupId == group.id then
                        Icon.userX CancelAddUser

                    else
                        Icon.userPlus (AddUser group.id)

                Nothing ->
                    Icon.userPlus (AddUser group.id)
            ]
        , case model.newUser of
            Just ua ->
                if ua.groupId == group.id then
                    row []
                        [ Form.viewTextProperty
                            { name = "Enter new user email address"
                            , value = ua.userEmail
                            , action = \x -> EditNewUser x
                            }
                        , case model.newGroupUserFound of
                            Just user ->
                                Icon.userPlus (ApiNewUser group user.id)

                            Nothing ->
                                Element.none
                        ]

                else
                    Element.none

            Nothing ->
                Element.none
        , viewUsers group model.users
        , row []
            [ el [ padding 16, Font.italic, Font.color Style.colors.gray ] <| text "Devices"
            , case model.newDevice of
                Just newDevice ->
                    if newDevice.groupId == group.id then
                        Icon.x CancelAddDevice

                    else
                        Icon.plus (AddDevice group.id)

                Nothing ->
                    Icon.plus (AddDevice group.id)
            ]
        , case model.newDevice of
            Just nd ->
                if nd.groupId == group.id then
                    row []
                        [ Form.viewTextProperty
                            { name = "Enter new device ID"
                            , value = nd.deviceId
                            , action = \x -> EditNewDevice x
                            }
                        , case model.newGroupDeviceFound of
                            Just dev ->
                                Icon.plus (ApiNewDevice group.id dev.id)

                            Nothing ->
                                Element.none
                        ]

                else
                    Element.none

            Nothing ->
                Element.none
        , viewDevices group devices
        ]


viewUsers : Group -> List User -> Element Msg
viewUsers group users =
    column [ spacing 6, paddingEach { top = 0, right = 16, bottom = 0, left = 32 } ]
        (List.map
            (\ur ->
                case List.Extra.find (\u -> u.id == ur.userId) users of
                    Just user ->
                        row [ padding 16 ]
                            [ text
                                (user.first
                                    ++ " "
                                    ++ user.last
                                    ++ " <"
                                    ++ user.email
                                    ++ ">"
                                )
                            , Icon.userX (ApiRemoveUser group user.id)
                            ]

                    Nothing ->
                        el [ padding 16 ] <| text "User not found"
            )
            group.users
        )


viewDevices : Group -> List Dev.Device -> Element Msg
viewDevices group devices =
    column [ spacing 6, paddingEach { top = 0, right = 16, bottom = 0, left = 32 } ]
        (List.map
            (\d ->
                row [ padding 16 ]
                    [ text
                        ("("
                            ++ d.id
                            ++ ") "
                            ++ Dev.description d
                        )
                    , Icon.x (ApiRemoveDevice group.id d.id)
                    ]
            )
            devices
        )
