{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE ScopedTypeVariables #-}
--------------------------------------------------------------------------------
-- |
-- Module      :  Data.Geometry.PlnarSubdivision
-- Copyright   :  (C) Frank Staals
-- License     :  see the LICENSE file
-- Maintainer  :  Frank Staals
--
-- Data type to represent a PlanarSubdivision
--
--------------------------------------------------------------------------------
module Data.Geometry.PlanarSubdivision( module Data.Geometry.PlanarSubdivision.Basic
                                      -- , module Data.Geometry.PlanarSubdivision.Build
                                      , fromPolygon
                                      ) where

-- import           Algorithms.Geometry.PolygonTriangulation.Triangulate
import           Data.Geometry.PlanarSubdivision.Basic
import           Data.Geometry.Polygon

--------------------------------------------------------------------------------

-- | Construct a planar subdivision from a polygon. Since our PlanarSubdivision
-- models only connected planar subdivisions, this may add dummy/invisible
-- edges.
--
-- running time: \(O(n)\) for a simple polygon, \(O(n\log n)\) for a polygon
-- with holes.
fromPolygon                              :: forall proxy t p f r s.
                                            (Ord r, Fractional r) => proxy s
                                         -> Polygon t p r
                                         -> f -- ^ data inside
                                         -> f -- ^ data outside the polygon
                                         -> PlanarSubdivision s p () f r
fromPolygon p pg@(SimplePolygon _) iD oD = fromSimplePolygon p pg iD oD
fromPolygon _ (MultiPolygon _ _)   _  _  = PlanarSubdivision cs vd dd fd
  where
    -- wp = Proxy :: Proxy (Wrap s)

    -- -- the components
    cs = error "cs is undefined in function fromPolygon"
    -- cs' = PG.fromSimplePolygon wp (SimplePolygon vs) iD oD
    --     : map (\h -> PG.fromSimplePolygon wp h oD iD) hs

    vd = undefined
    dd = undefined
    fd = undefined





  -- subd&planeGraph.faceData .~ faceData'
  --                            &planeGraph.vertexData.traverse %~ getP
  -- where
  --   faceData' = fmap (\(fi, FaceData hs _) -> FaceData hs (getFData fi)) . faces $ subd

  --   -- given a faceId lookup the
  --   getFData fi = let v = boundaryVertices fi subd V.! 0
  --                 in subd^.dataOf v.to holeData

  --   -- note that we intentionally reverse the order of iDd and oD in the call below,
  --   -- as our holes are now outside
  --   subd = fromPolygon px (MultiPolygon (CSeq.fromList [a,b,c,d]) holes') (Just oD) Nothing

  --   -- for every polygon, construct a hole.
  --   holes' = map withF . F.toList $ pgs
  --   -- add the facedata to the vertex data
  --   withF (pg :+ f) = bimap (\p -> Hole f p) id pg

  --   -- corners of the slightly enlarged boundingbox
  --   (a,b,c,d) = corners . bimap (const $ Outer oD) id
  --             . grow 1 . boundingBoxList . fmap (^.core) $ pgs

    --TODO: We need to mark the edges of the outer square as invisible.

    -- Main Idea: Assign the vertices the hole-number on which they occur. For
    -- each face we then find an incident vertex to find the data corresponding
    -- to that face.

data HoleData f p = Outer !f | Hole !f !p deriving (Show,Eq)

-- holeData            :: HoleData f p -> f
-- holeData (Outer f)  = f
-- holeData (Hole f _) = f

-- getP            :: HoleData f p -> Maybe p
-- getP (Outer _)  = Nothing
-- getP (Hole _ p) = Just p
