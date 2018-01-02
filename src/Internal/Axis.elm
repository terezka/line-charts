module Internal.Axis exposing
  ( Axis, default
  , exactly, around
  , int, time, float
  , intCustom, timeCustom, floatCustom, dashed, custom
  , Config, intConfig, timeConfig, floatConfig
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
  = AxisDefault
  | AxisInt (Coordinate.Range -> List Int) (Config Int msg)
  | AxisTime (Coordinate.Range -> List Tick.Time) (Config Tick.Time msg)
  | AxisFloat (Coordinate.Range -> List Float) (Config Float msg)
  | AxisData (Config data msg)



-- API / AXIS


{-| -}
default : Axis data msg
default =
  AxisDefault


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
timeCustom : Values.Amount -> Config Tick.Time msg -> Axis data msg
timeCustom amount =
  AxisTime (Values.time amount)


{-| -}
floatCustom : Values.Amount -> Config Float msg -> Axis data msg
floatCustom amount =
  AxisFloat (Values.float amount)


{-| -}
dashed : Config data msg -> Axis data msg
dashed =
   AxisData


{-| -}
custom : (Coordinate.Range -> List Float) -> Config Float msg -> Axis data msg
custom =
  AxisFloat



-- API / CONFIG


{-| -}
type alias Config unit msg =
  { line : Line.Line msg
  , tick : Int -> unit -> Tick.Tick msg
  , direction : Direction
  }


{-| -}
intConfig : Config Int msg
intConfig =
  { line = Line.default
  , direction = Tick.negative
  , tick = Tick.int
  }


{-| -}
timeConfig : Config Tick.Time msg
timeConfig =
  { line = Line.default
  , direction = Tick.negative
  , tick = Tick.time
  }


{-| -}
floatConfig : Config Float msg
floatConfig =
  { line = Line.default
  , direction = Tick.negative
  , tick = Tick.float
  }



-- INTERNAL


ticks : Coordinate.Range -> Dimension data msg ->  List data -> List ( Float, Tick.Tick msg )
ticks range { variable, pixels, axis } data =
  case axis of
    AxisDefault ->
      let withPosition i v = ( v, Tick.float i v ) in
      List.indexedMap withPosition (defaultValues pixels range)

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


defaultValues : Int -> Coordinate.Range -> List Float
defaultValues length =
  Values.float (defaultAmount length)


defaultAmount : Int -> Values.Amount
defaultAmount length =
  around <| length // 90


line : Axis data msg -> Coordinate.Range -> Coordinate.Range -> Line.Config msg
line axis =
  case axis of
    AxisDefault             -> Line.config Line.default
    AxisInt values config   -> Line.config config.line
    AxisTime values config  -> Line.config config.line
    AxisFloat values config -> Line.config config.line
    AxisData config         -> Line.config config.line


direction : Axis data msg -> Direction
direction axis =
  case axis of
    AxisDefault             -> Tick.Negative
    AxisInt values config   -> config.direction
    AxisTime values config  -> config.direction
    AxisFloat values config -> config.direction
    AxisData config         -> config.direction



-- VIEW


type alias ViewConfig msg =
  { padding : Float
  , line : Coordinate.Range -> Coordinate.Range -> Line.Config msg
  , ticks : List ( Float, Tick.Tick msg )
  , direction : Direction
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
          , ticks = ticks system.x dimension data
          , direction = direction dimension.axis
          , intersection = Intersection.getY intersection system
          , title = Title.config dimension.title
          }

        axisPosition =
          config.intersection - scaleDataY system config.padding

        at x =
          { x = x, y = axisPosition }

        viewAxisLine =
          viewHorizontalAxisLine system axisPosition

        viewTick ( position, tick ) =
          viewHorizontalTick system config (at position) tick
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
          , ticks = ticks system.y dimension data
          , direction = direction dimension.axis
          , intersection = Intersection.getX intersection system
          , title = Title.config dimension.title
          }

        axisPosition =
          config.intersection - scaleDataX system config.padding

        at y =
          { x = axisPosition, y = y }

        viewAxisLine =
          viewVerticalAxisLine system axisPosition

        viewTick ( position, tick ) =
          viewVerticalTick system config (at position) tick
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
    [ xTick system (lengthOfTick config tick) (attributesTick tick) y x
    , viewMaybe tick.label (viewHorizontalLabel system config point)
    ]


viewVerticalTick : Coordinate.System -> ViewConfig msg -> Point -> Tick.Tick msg -> Svg msg
viewVerticalTick system config ({ x, y } as point) tick =
  g [ class "chart__tick" ]
    [ yTick system (lengthOfTick config tick) (attributesTick tick) x y
    , viewMaybe tick.label (viewVerticalLabel system config point)
    ]


lengthOfTick : ViewConfig msg -> Tick.Tick msg -> Float
lengthOfTick { direction } { length } =
  if Tick.isPositive direction then -length else length


attributesTick : Tick.Tick msg -> List (Svg.Attribute msg)
attributesTick { width, color } =
  [ strokeWidth (toString width), stroke color ]



viewHorizontalLabel : Coordinate.System -> ViewConfig msg -> Point -> Svg msg -> Svg msg
viewHorizontalLabel system { direction } position view =
  let
    yOffset = if Tick.isPositive direction then -10 else 20
  in
  g [ transform [ move system position.x position.y, offset 0 yOffset ]
    , anchorStyle Middle
    ]
    [ view ]


viewVerticalLabel : Coordinate.System -> ViewConfig msg -> Point -> Svg msg -> Svg msg
viewVerticalLabel system { direction } position view =
  let
    anchor = if Tick.isPositive direction then Start else End
    xOffset = if Tick.isPositive direction then 10 else -10
  in
  g [ transform [ move system position.x position.y, offset xOffset 5 ]
    , anchorStyle anchor
    ]
    [ view ]
