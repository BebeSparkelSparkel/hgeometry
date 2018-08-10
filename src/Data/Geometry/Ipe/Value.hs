{-# LANGUAGE OverloadedStrings #-}
module Data.Geometry.Ipe.Value where

import GHC.Exts
import Data.Text

--------------------------------------------------------------------------------

-- | Many types either consist of a symbolc value, or a value of type v
data IpeValue v = Named Text | Valued v deriving (Show,Eq,Ord,Functor,Foldable,Traversable)

instance IsString (IpeValue v) where
  fromString = Named . fromString
