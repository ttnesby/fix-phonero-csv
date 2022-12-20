module Upload exposing (..)

-- File upload with the <input type="file"> node.
--
-- Dependencies:
--   elm install elm/file
--   elm install elm/json
--

import Browser
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D



-- MAIN


main : Program () (Model) Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    List File


init : () -> ( Model, Cmd Msg )
init _ = ( [], Cmd.none )

-- UPDATE


type Msg
    = GotFiles (List File)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotFiles files ->
            ( files, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ input
            [ type_ "file"
            , multiple False
            , on "change" (D.map GotFiles filesDecoder)
            ]
            []
        , div [] [ text (Debug.toString model) ]
        ]


filesDecoder : D.Decoder (List File)
filesDecoder =
    D.at [ "target", "files" ] (D.list File.decoder)
