module Gen.Model exposing (Model(..))

import Gen.Params.NotFound
import Gen.Params.SignIn
import Gen.Params.Top
import Pages.NotFound
import Pages.SignIn
import Pages.Top


type Model
    = Redirecting_
    | NotFound Gen.Params.NotFound.Params Pages.NotFound.Model
    | SignIn Gen.Params.SignIn.Params Pages.SignIn.Model
    | Top Gen.Params.Top.Params Pages.Top.Model

