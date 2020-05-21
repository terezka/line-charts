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
import Time


-- AXIS


{-| -}
type Config msg
  = Config (Coordinate.Range -> Coordinate.Range -> List (Tick.Config msg))



-- API


{-| -}
int : Int -> Config msg
int amount =
  intCustom amount Tick.int


{-| -}
float : Int -> Config msg
float amount =
  floatCustom amount Tick.float


{-| -}
time : Time.Zone -> Int -> Config msg
time zone amount =
  timeCustom zone amount Tick.time



-- API / CUSTOM


{-| -}
intCustom : Int -> (Int -> Tick.Config msg) -> Config msg
intCustom amount tick =
  custom <| \data range ->
    List.map tick <| Values.int (Values.around amount) (Coordinate.smallestRange data range)


{-| -}
floatCustom : Int -> (Float -> Tick.Config msg) -> Config msg
floatCustom amount tick =
  custom <| \data range ->
    List.map tick <| Values.float (Values.around amount) (Coordinate.smallestRange data range)


{-| -}
timeCustom : Time.Zone -> Int -> (Tick.Time -> Tick.Config msg) -> Config msg
timeCustom zone amount tick =
  custom <| \data range ->
    List.map tick <| Values.time zone amount (Coordinate.smallestRange data range)



-- API / VERY CUSTOM


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> List (Tick.Config msg)) -> Config msg
custom =
  Config



-- INTERNAL


ticks : Coordinate.Range -> Coordinate.Range -> Config msg -> List (Tick.Properties msg)
ticks dataRange range (Config values) =
  List.map Internal.Axis.Tick.properties <| values dataRange range
