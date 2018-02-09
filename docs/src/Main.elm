port module Main exposing (..)

import Html
import Html.Attributes
import Html.Events
import Html.Lazy
import Dict
import Area
import Selection
import Stepped
import Ticks
import Lines



-- MODEL


type alias Model =
  { focused : Id
  , isSourceOpen : Bool
  , selection : Selection.Model
  , area : Area.Model
  , stepped : Stepped.Model
  , ticks : Ticks.Model
  , lines : Lines.Model
  }


type alias Id =
  Int



-- INIT 


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

    ( lines, cmdLines ) =
      Lines.init
  in
    ( { focused = 1
      , isSourceOpen = False
      , selection = selection
      , area = area
      , stepped = stepped
      , ticks = ticks
      , lines = lines
      }
    , Cmd.batch
        [ Cmd.map SelectionMsg cmdSelection
        , Cmd.map AreaMsg cmdArea
        , Cmd.map SteppedMsg cmdStepped
        , Cmd.map TicksMsg cmdTicks
        , Cmd.map LinesMsg cmdLines
        , highlight ()
        ]
    )


-- UPDATE


type Msg
  = Focus Id
  | CloseSource
  | SelectionMsg Selection.Msg
  | AreaMsg Area.Msg
  | SteppedMsg Stepped.Msg
  | TicksMsg Ticks.Msg
  | LinesMsg Lines.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Focus id ->
      ( { model | isSourceOpen = True, focused = id }
      , Cmd.none
      )

    CloseSource ->
      ( { model | isSourceOpen = False }
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

    LinesMsg msg ->
      let
        ( lines, cmd ) =
          Lines.update msg model.lines
      in
        ( { model | lines = lines }
        , Cmd.map LinesMsg cmd
        )



-- VIEW


view : Model -> Html.Html Msg
view model =
  Html.div
    [ Html.Attributes.class "view" ]
    [ viewTitle
    , viewExample 0 AreaMsg Area.view model.area
    , viewExample 1 SelectionMsg Selection.view model.selection
    , viewExample 2 LinesMsg Lines.view model.lines
    , viewExample 3 SteppedMsg Stepped.view model.stepped
    , viewExample 4 TicksMsg Ticks.view model.ticks
    , viewSource model.focused model.isSourceOpen
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
            [ Html.a
                [ Html.Attributes.href "https://github.com/terezka/line-charts" ]
                [ Html.text "Github" ]
            , Html.text " / "
            , Html.a
                [ Html.Attributes.href "https://twitter.com/terezk_a" ]
                [ Html.text "Twitter" ]
            , Html.text " / "
            , Html.a
                [ Html.Attributes.href "http://package.elm-lang.org/packages/terezka/line-charts/latest" ]
                [ Html.text "Docs" ]
            ]
        , Html.p [ Html.Attributes.class "view__tag-line" ]
            [ Html.text "A opinionated library for plotting series in SVG." ]
        , Html.p [ Html.Attributes.class "view__tag-line" ]
            [ Html.text "Written in all Elm." ]
        ]


viewExample : Id -> (msg -> Msg) -> (a -> Html.Html msg) -> a -> Html.Html Msg
viewExample id toMsg view model =
  Html.div 
    [ Html.Attributes.class "view__example__container" ]
    [ Html.map toMsg <| Html.Lazy.lazy view model
    , Html.button 
        [ Html.Events.onClick (Focus id) ] 
        [ Html.text "see source" ]
    ]


viewSource : Id -> Bool -> Html.Html Msg
viewSource id isSourceOpen =
  let 
    classes =
      if isSourceOpen then
        "view__source__container view__source__container--open"
      else
        "view__source__container view__source__container--closed"

    viewInnerSource i s =
      if i ==  id then
        Html.pre 
          [ Html.Attributes.class "shown" ] 
          [ Html.text s ]
      else
        Html.pre 
          [ Html.Attributes.class "hidden" ] 
          [ Html.text s ]

    viewSources =
      List.indexedMap viewInnerSource 
        [ Area.source 
        , Selection.source
        , Lines.source
        , Stepped.source
        ]
  in
  Html.div 
    [ Html.Attributes.class classes ]
    [ Html.button 
        [ Html.Events.onClick CloseSource ] 
        [ Html.text "[x] close" ] 
    , Html.div 
        [ Html.Attributes.class "view__source__inner elm" ]
        viewSources
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
