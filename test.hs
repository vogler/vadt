{-# LANGUAGE ConstraintKinds, TypeFamilies #-}
-- import GHC.Exts

-- abstract types (does not work with newtype)
data Time
data Location
data Distance

data Range a = Range a a
-- why does newtype need a constructor if it's limited to one?
newtype Duration = Duration Int -- Int is Bounded, Integer is not
-- in OCaml we can just write
-- type duration = int

class Duration_ a where
  duration :: a -> Duration

-- Integral is Int and Integer, Num also includes Real
instance Integral a => Duration_ (Range a) where
  duration (Range a b) = Duration (fromIntegral (b - a))

-- what if we wanted it to work on Num as well?
type Duration2 a = Num a
class Duration_2 a where
  duration2 :: Num b => a -> b
instance Num a => Duration_2 (Range a) where
  duration2 (Range a b) = b - a

main = putStrLn "hallo"
