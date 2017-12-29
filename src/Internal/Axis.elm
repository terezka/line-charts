module Internal.Axis exposing
  ( Axis
  , exactly, around
  , int, time, float
  , intCustom, timeCustom, floatCustom, dataCustom, custom
  , Config, intConfig, timeConfig, floatConfig
  -- INTERNAL
  , line, ticks, direction
  , viewHorizontal, viewVertical
  )


import Svg exposing (Svg, Attribute, g, text_, tspan, text)
import Svg.Attributes as Attributes exposing (class, strokeWidth, stroke)
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Axis.Line as Line
import Internal.Axis.Tick as Tick
import Internal.Axis.Title as Title
import Internal.Axis.Values as Values
import Internal.Axis.Values.Time as Time
import Internal.Svg as Svg exposing (..)
import Internal.Utils exposing (..)


{-| -}
type Axis data msg
  = AxisInt (Coordinate.Range -> List Int) (Config Int msg)
  | AxisTime (Coordinate.Range -> List Time.Time) (Config Time.Time msg)
  | AxisFloat (Coordinate.Range -> List Float) (Config Float msg)
  | AxisData (Config data msg)



-- API / AXIS


{-| -}
exactly : Int -> Values.Amount
exactly =
  Values.Exactly


{-| -}
around : Int -> Values.Amount
around =
  Values.Around


{-| -}
int : Values.Amount -> Axis data msg
int amount =
   AxisInt (Values.int amount) intConfig


{-| -}
time : Values.Amount -> Axis data msg
time amount =
   AxisTime (Values.time amount) timeConfig


{-| -}
float : Values.Amount -> Axis data msg
float amount =
   AxisFloat (Values.float amount) floatConfig


{-| -}
intCustom : Values.Amount -> Config Int msg -> Axis data msg
intCustom amount =
  AxisInt (Values.int amount)


{-| -}
timeCustom : Values.Amount -> Config Time.Time msg -> Axis data msg
timeCustom amount =
  AxisTime (Values.time amount)


{-| -}
floatCustom : Values.Amount -> Config Float msg -> Axis data msg
floatCustom amount =
  AxisFloat (Values.float amount)


{-| -}
dataCustom : Config data msg -> Axis data msg
dataCustom =
   AxisData


{-| -}
custom : (Coordinate.Range -> List Float) -> Config Float msg -> Axis data msg
custom =
  AxisFloat



-- API / CONFIG


{-| -}
type alias Config unit msg =
  { line : Maybe (Line.Line msg)
  , tick : Int -> unit -> Tick.Tick msg
  , direction : Tick.Direction
  }


{-| -}
intConfig : Config Int msg
intConfig =
  { line = Just Line.default
  , direction = Tick.negative
  , tick = Tick.int
  }


{-| -}
timeConfig : Config Time.Time msg
timeConfig =
  { line = Just Line.default
  , direction = Tick.negative
  , tick = Tick.time
  }


{-| -}
floatConfig : Config Float msg
floatConfig =
  { line = Just Line.default
  , direction = Tick.negative
  , tick = Tick.float
  }



-- INTERNAL


{-| -}
ticks : Coordinate.Range -> (data -> Float) -> List data -> Axis data msg -> List ( Float, Tick.Tick msg )
ticks range variable data axis =
  case axis of
    AxisInt values config ->
      let withPosition i v = ( toFloat v, config.tick i v ) in
      List.indexedMap withPosition (values range)

    AxisTime values config ->
      let withPosition i v = ( v.timestamp, config.tick i v ) in
      List.indexedMap withPosition (values range)

    AxisFloat values config ->
      let withPosition i v = ( v, config.tick i v ) in
      List.indexedMap withPosition (values range)

    AxisData config ->
      let withPosition i v = ( variable v, config.tick i v ) in
      List.indexedMap withPosition data


{-| -}
line : Axis data msg -> Maybe (Coordinate.Range -> Line.Config msg)
line axis =
  let toConfig = Maybe.map Line.config in
  case axis of
    AxisInt values config   -> toConfig config.line
    AxisTime values config  -> toConfig config.line
    AxisFloat values config -> toConfig config.line
    AxisData config         -> toConfig config.line


{-| -}
direction : Axis data msg -> Tick.Direction
direction axis =
  case axis of
    AxisInt values config   -> config.direction
    AxisTime values config  -> config.direction
    AxisFloat values config -> config.direction
    AxisData config         -> config.direction



-- VIEW


{-| -}
type alias ViewConfig msg =
  { padding : Float
  , line : Maybe (Coordinate.Range -> Line.Config msg)
  , ticks : List ( Float, Tick.Tick msg )
  , direction : Tick.Direction
  , intersection : Float
  , title : Title.Config msg
  }



{-| -}
viewHorizontal : Coordinate.System -> ViewConfig msg -> Svg msg
viewHorizontal system axis =
    let
        axisPosition =
          axis.intersection - scaleDataY system axis.padding

        at x =
          { x = x, y = axisPosition }

        viewAxisLine { start, end, events } = -- TODO Add color and width
          horizontal system events axisPosition start end

        viewTick ( position, tick ) =
          viewHorizontalTick system axis (at position) tick
    in
    g [ class "axis--horizontal" ]
      [ viewHorizontalTitle system at axis
      , viewMaybe axis.line (apply system.x >> viewAxisLine)
      , g [ class "ticks" ] (List.map viewTick axis.ticks)
      ]


{-| -}
viewVertical : Coordinate.System -> ViewConfig msg -> Svg msg
viewVertical system axis =
    let
        axisPosition =
          axis.intersection - scaleDataX system axis.padding

        at y =
          { x = axisPosition, y = y }

        viewAxisLine { start, end, events } = -- TODO Add color and width
          vertical system events axisPosition start end

        viewTick ( position, tick ) =
          viewVerticalTick system axis (at position) tick
    in
    g [ class "axis--vertical" ]
      [ viewVerticalTitle system at axis
      , viewMaybe axis.line (apply system.y >> viewAxisLine)
      , g [ class "ticks" ] (List.map viewTick axis.ticks)
      ]



-- VIEW TITLE


viewHorizontalTitle : Coordinate.System -> (Float -> Point) -> ViewConfig msg -> Svg msg
viewHorizontalTitle system at { title } =
  let
    position =
      at (title.position system.x)
  in
  g [ class "title"
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
  g [ class "title"
    , transform
        [ move system position.x position.y
        , offset (title.xOffset - 5) (title.yOffset - 15)
        ]
    , anchorStyle Middle
    ]
    [ title.view ]



-- VIEW TICK


viewHorizontalTick : Coordinate.System -> ViewConfig msg -> Point -> Tick.Tick msg -> Svg msg
viewHorizontalTick system config ({ x, y } as point) tick =
  g [ class "tick" ]
    [ xTick system (lengthOfTick config tick) (attributesTick tick) y x
    , viewMaybe tick.label (viewHorizontalLabel system config point)
    ]


viewVerticalTick : Coordinate.System -> ViewConfig msg -> Point -> Tick.Tick msg -> Svg msg
viewVerticalTick system config ({ x, y } as point) tick =
  g [ class "tick" ]
    [ yTick system (lengthOfTick config tick) (attributesTick tick) x y
    , viewMaybe tick.label (viewVerticalLabel system config point)
    ]


lengthOfTick : ViewConfig msg -> Tick.Tick msg -> Float
lengthOfTick { direction } { length } =
  if isPositive direction then -length else length


attributesTick : Tick.Tick msg -> List (Svg.Attribute msg)
attributesTick { width, color } =
  [ strokeWidth (toString width), stroke color ]



viewHorizontalLabel : Coordinate.System -> ViewConfig msg -> Point -> Svg msg -> Svg msg
viewHorizontalLabel system { direction } position view =
  let
    yOffset = if isPositive direction then -10 else 20
  in
  g [ transform [ move system position.x position.y, offset 0 yOffset ]
    , anchorStyle Middle
    ]
    [ view ]


viewVerticalLabel : Coordinate.System -> ViewConfig msg -> Point -> Svg msg -> Svg msg
viewVerticalLabel system { direction } position view =
  let
    anchor = if isPositive direction then Start else End
    xOffset = if isPositive direction then 10 else -10
  in
  g [ transform [ move system position.x position.y, offset xOffset 5 ]
    , anchorStyle anchor
    ]
    [ view ]



-- UTILS


isPositive : Tick.Direction -> Bool
isPositive direction =
  case direction of
    Tick.Positive -> True
    Tick.Negative -> False
