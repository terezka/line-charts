port module Main exposing (..)

import Html
import Html.Attributes
import Html.Lazy
import Area
import Selection
import Stepped
import Ticks



-- MODEL


type alias Model =
    { focused : Maybe Id
    , selection : Selection.Model
    , area : Area.Model
    , stepped : Stepped.Model
    , ticks : Ticks.Model
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

    ( stepped, cmdStepped ) =
      Stepped.init

    ( ticks, cmdTicks ) =
      Ticks.init
  in
    ( { focused = Nothing
      , selection = selection
      , area = area
      , stepped = stepped
      , ticks = ticks
      }
    , Cmd.batch
        [ Cmd.map SelectionMsg cmdSelection
        , Cmd.map AreaMsg cmdArea
        , Cmd.map SteppedMsg cmdStepped
        , Cmd.map TicksMsg cmdTicks
        ]
    )


-- UPDATE


type Msg
  = Focus (Maybe Id)
  | SelectionMsg Selection.Msg
  | AreaMsg Area.Msg
  | SteppedMsg Stepped.Msg
  | TicksMsg Ticks.Msg


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

    SteppedMsg msg ->
      let
        ( stepped, cmd ) =
          Stepped.update msg model.stepped
      in
        ( { model | stepped = stepped }
        , Cmd.map SteppedMsg cmd
        )

    TicksMsg msg ->
      let
        ( ticks, cmd ) =
          Ticks.update msg model.ticks
      in
        ( { model | ticks = ticks }
        , Cmd.map TicksMsg cmd
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
    , Html.map SteppedMsg <| Html.Lazy.lazy Stepped.view model.stepped
    , Html.map TicksMsg <| Html.Lazy.lazy Ticks.view model.ticks
    ]


viewTitle : Html.Html msg
viewTitle =
    Html.div
        [ Html.Attributes.class "view__title__container" ]
        [ Html.h1
            [ Html.Attributes.class "view__title" ]
            [ Html.text "series" ]
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
        , Html.p [ Html.Attributes.class "view__tag-line" ]
            [ Html.text "A opinionated library for plotting lines charts in SVG." ]
        , Html.p [ Html.Attributes.class "view__tag-line" ]
            [ Html.text "Written in all Elm." ]
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
