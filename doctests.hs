import Test.DocTest

main :: IO ()
main = doctest $ ["-isrc" ] ++ ghcExts ++ files

ghcExts :: [String]
ghcExts = map ("-X" ++)
          [ "TypeFamilies"
          , "GADTs"
          , "KindSignatures"
          , "DataKinds"
          , "TypeOperators"
          , "ConstraintKinds"
          , "PolyKinds"
          , "RankNTypes"
          , "TypeApplications"
          , "ScopedTypeVariables"

          , "PatternSynonyms"
          , "ViewPatterns"
          , "TupleSections"
          , "MultiParamTypeClasses"
          , "LambdaCase"
          , "TupleSections"


          , "StandaloneDeriving"
          , "GeneralizedNewtypeDeriving"
          , "DeriveFunctor"
          , "DeriveFoldable"
          , "DeriveTraversable"
          , "AutoDeriveTypeable"
          , "DeriveGeneric"
          , "FlexibleInstances"
          , "FlexibleContexts"
          ]

files :: [String]
files = map toFile modules

toFile :: String -> String
toFile = (\s -> "src/" <> s <> ".hs") . replace '.' '/'

replace     :: Eq a => a -> a -> [a] -> [a]
replace a b = go
  where
    go []                 = []
    go (c:cs) | c == a    = b:go cs
              | otherwise = c:go cs

modules :: [String]
modules =
  [ "Data.Range"
  , "Data.CircularList.Util"
  , "Data.Permutation"
  , "Data.CircularSeq"
  , "Data.LSeq"
  , "Data.PlanarGraph"
  , "Data.PlanarGraph.Dart"
  , "Data.PlanarGraph.Core"
  , "Data.PlaneGraph.IO"
  , "Data.Tree.Util"

  , "Data.Geometry.Point"
  , "Data.Geometry.Vector"
  , "Data.Geometry.Transformation"
  , "Data.Geometry.Line"
  , "Data.Geometry.Line.Internal"
  , "Data.Geometry.Interval"
  , "Data.Geometry.LineSegment"
  , "Data.Geometry.PolyLine"
  , "Data.Geometry.Polygon"
  , "Data.Geometry.Ball"
  , "Data.Geometry.Box"

  , "Data.Geometry.Ipe.IpeOut"
  , "Data.Geometry.Ipe.FromIpe"

  -- , "Algorithms.Geometry.HiddenSurfaceRemoval.HiddenSurfaceRemoval"
  ]
