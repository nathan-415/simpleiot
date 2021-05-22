module Gen.Msg exposing (Msg(..))

import Gen.Params.NotFound
import Gen.Params.SignIn
import Gen.Params.Top
import Pages.NotFound
import Pages.SignIn
import Pages.Top


type Msg
    = NotFound Pages.NotFound.Msg
    | SignIn Pages.SignIn.Msg
    | Top Pages.Top.Msg

