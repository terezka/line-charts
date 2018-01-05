module Internal.Axis exposing
  ( Axis, default
  , int, time, float
  , dashed, custom
  -- INTERNAL
  , ticks, viewHorizontal, viewVertical
  )


import Svg exposing (Svg, Attribute, g, text_, tspan, text)
import Svg.Attributes as Attributes exposing (class, strokeWidth, stroke)
import Lines.Coordinate as Coordinate exposing (..)
import Lines.Axis.Tick as Tick exposing (Direction)
import Internal.Axis.Tick as Tick
import Internal.Axis.Line as Line
import Internal.Axis.Intersection as Intersection
import Internal.Axis.Range as Range
import Internal.Axis.Title as Title
import Internal.Axis.Values as Values
import Internal.Svg as Svg exposing (..)
import Internal.Utils exposing (..)


{-| -}
type alias Dimension data msg =
  { title : Title.Title msg
  , variable : data -> Float
  , pixels : Int
  , padding : Float
  , range : Range.Range
  , axis : Axis data msg
  }


{-| -}
type Axis data msg
  = Default
  | Custom (Line.Line msg) (Coordinate.Range -> Coordinate.Range -> List (Tick.Tick msg))
  | Data   (Line.Line msg) (Coordinate.Range -> Coordinate.Range -> List (Tick.Tick msg)) (data -> Tick.Tick msg)



-- API / AXIS


{-| -}
default : Axis data msg
default =
  Default


{-| -}
int : Int -> Axis data msg
int amount =
  custom Line.default <| \_ range ->
    List.map Tick.int <| Values.int (Values.around amount) range


{-| -}
float : Int -> Axis data msg
float amount =
  custom Line.default <| \_ range ->
    List.map Tick.float <| Values.float (Values.around amount) range


{-| -}
time : Int -> Axis data msg
time amount =
  custom Line.default <| \_ range ->
    List.map Tick.time <| Values.time amount range


{-| TODO use variable to make data tick -}
dashed : Line.Line msg -> (data -> Tick.Tick msg) -> (Coordinate.Range -> Coordinate.Range -> List (Tick.Tick msg)) -> Axis data msg
dashed line dataTick ticks =
  Data line ticks dataTick


{-| -}
custom : Line.Line msg -> (Coordinate.Range -> Coordinate.Range -> List (Tick.Tick msg)) -> Axis data msg
custom =
  Custom



-- INTERNAL


ticks : Coordinate.Range -> Coordinate.Range -> Dimension data msg -> List data -> List (Tick.Tick msg)
ticks dataRange range { variable, pixels, axis } data =
  case axis of
    Default ->
      List.map Tick.float (defaultValues pixels range)

    Custom line values ->
      values dataRange range

    Data line values tick ->
      values dataRange range ++ List.map tick data


defaultValues : Int -> Coordinate.Range -> List Float
defaultValues length =
  Values.float (defaultAmount length)


defaultAmount : Int -> Values.Amount
defaultAmount length =
  Values.around <| length // 90


line : Axis data msg -> Coordinate.Range -> Coordinate.Range -> Line.Config msg
line axis =
  case axis of
    Default               -> Line.config Line.default
    Custom line values    -> Line.config line
    Data line values tick -> Line.config line


-- VIEW


type alias ViewConfig msg =
  { padding : Float
  , line : Coordinate.Range -> Coordinate.Range -> Line.Config msg
  , ticks : List (Tick.Tick msg)
  , intersection : Float
  , title : Title.Config msg
  }


{-| -}
viewHorizontal : Coordinate.System -> Intersection.Intersection -> List data -> Dimension data msg -> Svg msg
viewHorizontal system intersection data dimension =
    let
        config =
          { padding = dimension.padding
          , line = line dimension.axis
          , ticks = ticks system.xData system.x dimension data
          , intersection = Intersection.getY intersection system
          , title = Title.config dimension.title
          }

        axisPosition =
          config.intersection - scaleDataY system config.padding

        at x =
          { x = x, y = axisPosition }

        viewAxisLine =
          viewHorizontalAxisLine system axisPosition

        viewTick tick =
          viewHorizontalTick system config (at tick.position) tick
    in
    g [ class "chart__axis--horizontal" ]
      [ viewHorizontalTitle system at config
      , viewAxisLine (config.line system.xData system.x)
      , g [ class "chart__ticks" ] (List.map viewTick config.ticks)
      ]


{-| -}
viewVertical : Coordinate.System -> Intersection.Intersection -> List data -> Dimension data msg -> Svg msg
viewVertical system intersection data dimension =
    let
        config =
          { padding = dimension.padding
          , line = line dimension.axis
          , ticks = ticks system.yData system.y dimension data
          , intersection = Intersection.getX intersection system
          , title = Title.config dimension.title
          }

        axisPosition =
          config.intersection - scaleDataX system config.padding

        at y =
          { x = axisPosition, y = y }

        viewAxisLine =
          viewVerticalAxisLine system axisPosition

        viewTick tick =
          viewVerticalTick system config (at tick.position) tick
    in
    g [ class "chart__axis--vertical" ]
      [ viewVerticalTitle system at config
      , viewAxisLine (config.line system.yData system.y)
      , g [ class "chart__ticks" ] (List.map viewTick config.ticks)
      ]



-- VIEW TITLE


viewHorizontalTitle : Coordinate.System -> (Float -> Point) -> ViewConfig msg -> Svg msg
viewHorizontalTitle system at { title } =
  let
    position =
      at (title.position system.x)
  in
  g [ class "chart__title"
    , transform
        [ move system position.x position.y
        , offset title.xOffset (title.yOffset + 40)
        ]
    , anchorStyle Middle
    ]
    [ title.view ]


viewVerticalTitle : Coordinate.System -> (Float -> Point) -> ViewConfig msg -> Svg msg
viewVerticalTitle system at { title } =
  let
    position =
      at (title.position system.y)
  in
  g [ class "chart__title"
    , transform
        [ move system position.x position.y
        , offset (title.xOffset - 5) (title.yOffset - 15)
        ]
    , anchorStyle Middle
    ]
    [ title.view ]



-- VIEW LINE


viewHorizontalAxisLine : Coordinate.System -> Float -> Line.Config msg -> Svg msg
viewHorizontalAxisLine system axisPosition config =
  horizontal system (attributesLine config) axisPosition config.start config.end


viewVerticalAxisLine : Coordinate.System -> Float -> Line.Config msg -> Svg msg
viewVerticalAxisLine system axisPosition config =
  vertical system (attributesLine config) axisPosition config.start config.end


attributesLine : Line.Config msg -> List (Svg.Attribute msg)
attributesLine { events, width, color } =
  events ++ [ strokeWidth (toString width), stroke color ]



-- VIEW TICK


viewHorizontalTick : Coordinate.System -> ViewConfig msg -> Point -> Tick.Tick msg -> Svg msg
viewHorizontalTick system config ({ x, y } as point) tick =
  g [ class "chart__tick" ]
    [ xTick system (lengthOfTick tick) (attributesTick tick) y x
    , viewMaybe tick.label (viewHorizontalLabel system tick point)
    ]


viewVerticalTick : Coordinate.System -> ViewConfig msg -> Point -> Tick.Tick msg -> Svg msg
viewVerticalTick system config ({ x, y } as point) tick =
  g [ class "chart__tick" ]
    [ yTick system (lengthOfTick tick) (attributesTick tick) x y
    , viewMaybe tick.label (viewVerticalLabel system tick point)
    ]


lengthOfTick : Tick.Tick msg -> Float
lengthOfTick { length, direction } =
  if Tick.isPositive direction then -length else length


attributesTick : Tick.Tick msg -> List (Svg.Attribute msg)
attributesTick { width, color } =
  [ strokeWidth (toString width), stroke color ]



viewHorizontalLabel : Coordinate.System -> Tick.Tick msg -> Point -> Svg msg -> Svg msg
viewHorizontalLabel system { direction } position view =
  let
    yOffset = if Tick.isPositive direction then -10 else 20
  in
  g [ transform [ move system position.x position.y, offset 0 yOffset ]
    , anchorStyle Middle
    ]
    [ view ]


viewVerticalLabel : Coordinate.System -> Tick.Tick msg -> Point -> Svg msg -> Svg msg
viewVerticalLabel system { direction } position view =
  let
    anchor = if Tick.isPositive direction then Start else End
    xOffset = if Tick.isPositive direction then 10 else -10
  in
  g [ transform [ move system position.x position.y, offset xOffset 5 ]
    , anchorStyle anchor
    ]
    [ view ]
