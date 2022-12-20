module Upload exposing (..)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, p, text)
import Html.Events exposing (onClick)
import Task


type alias Model =
    String


type Msg
    = OpenFileClicked
    | FileSelected File
    | FileRead String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenFileClicked ->
            ( model, Select.file ["text/csv"] FileSelected )

        FileSelected file ->
            ( model, Task.perform FileRead (File.toString file) )

        FileRead content ->
            ( content, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick OpenFileClicked ] [ text "Open file" ]
        , p [] [ text model ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = always ( "", Cmd.none )
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }