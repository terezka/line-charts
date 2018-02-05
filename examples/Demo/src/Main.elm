port module Main exposing (..)

import Html
import Html.Attributes
import Html.Lazy
import Selection
import Area



-- MODEL


type alias Model =
    { focused : Maybe Id
    , selection : Selection.Model
    , area : Area.Model
    }


type alias Id =
  String


init : ( Model, Cmd Msg )
init =
  let
    ( selection, cmdSelection ) =
      Selection.init

    ( area, cmdArea ) =
      Area.init
  in
    ( { focused = Nothing
      , selection = selection
      , area = area
      }
    , Cmd.batch
        [ Cmd.map SelectionMsg cmdSelection
        , Cmd.map AreaMsg cmdArea
        ]
    )


-- UPDATE


type Msg
  = Focus (Maybe Id)
  | SelectionMsg Selection.Msg
  | AreaMsg Area.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Focus id ->
      ( updateFocused id model
      , Cmd.none
      )

    SelectionMsg msg ->
      let
        ( selection, cmd ) =
          Selection.update msg model.selection
      in
        ( { model | selection = selection }
        , Cmd.map SelectionMsg cmd
        )

    AreaMsg msg ->
      let
        ( area, cmd ) =
          Area.update msg model.area
      in
        ( { model | area = area }
        , Cmd.map AreaMsg cmd
        )


updateFocused : Maybe Id -> Model -> Model
updateFocused id model =
  if id == model.focused
    then { model | focused = Nothing }
    else { model | focused = id }



-- VIEW


view : Model -> Html.Html Msg
view model =
  Html.div
    [ Html.Attributes.class "view" ]
    [ viewTitle
    , Html.map AreaMsg <| Html.Lazy.lazy Area.view model.area
    , Html.map SelectionMsg <| Html.Lazy.lazy Selection.view model.selection
    ]


viewTitle : Html.Html msg
viewTitle =
    Html.div
        [ Html.Attributes.class "view__title__container" ]
        [ Html.h1
            [ Html.Attributes.class "view__title" ]
            [ Html.text "line-charts" ]
        , Html.div
            [ Html.Attributes.class "view__github-link" ]
            [ Html.text "Find it on "
            , Html.a
                [ Html.Attributes.href "https://github.com/terezka/elm-plot" ]
                [ Html.text "Github" ]
            , Html.text " / "
            , Html.a
                [ Html.Attributes.href "https://twitter.com/terez_ka" ]
                [ Html.text "Twitter" ]
            ]
        ]



-- Ports


port highlight : () -> Cmd msg



-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }
