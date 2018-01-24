module Internal.Axis.Ticks exposing
  ( Config
  , int, time, float
  , intCustom, timeCustom, floatCustom, custom
  -- INTERNAL
  , ticks
  )



import LineChart.Axis.Tick as Tick
import Internal.Axis.Tick
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Axis.Values as Values



-- AXIS


{-| TODO why does this now warn me about the unused data type? -}
type Config data msg
  = Config (Coordinate.Range -> Coordinate.Range -> List (Tick.Config msg))



-- API


{-| -}
int : Int -> Config data msg
int amount =
  intCustom amount Tick.int


{-| -}
float : Int -> Config data msg
float amount =
  floatCustom amount Tick.float


{-| -}
time : Int -> Config data msg
time amount =
  timeCustom amount Tick.time



-- API / CUSTOM


{-| -}
intCustom : Int -> (Int -> Tick.Config msg) -> Config data msg
intCustom amount tick =
  custom <| \data range ->
    List.map tick <| Values.int (Values.around amount) (Coordinate.smallestRange data range)


{-| -}
floatCustom : Int -> (Float -> Tick.Config msg) -> Config data msg
floatCustom amount tick =
  custom <| \data range ->
    List.map tick <| Values.float (Values.around amount) (Coordinate.smallestRange data range)


{-| -}
timeCustom : Int -> (Tick.Time -> Tick.Config msg) -> Config data msg
timeCustom amount tick =
  custom <| \data range ->
    List.map tick <| Values.time amount (Coordinate.smallestRange data range)



-- API / VERY CUSTOM


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> List (Tick.Config msg)) -> Config data msg
custom =
  Config



-- INTERNAL


ticks : Coordinate.Range -> Coordinate.Range -> Config data msg -> List (Tick.Properties msg)
ticks dataRange range (Config values) =
  List.map Internal.Axis.Tick.properties <| values dataRange range
