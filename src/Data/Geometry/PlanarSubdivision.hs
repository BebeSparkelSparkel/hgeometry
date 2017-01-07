{-# LANGUAGE TemplateHaskell #-}
module Data.Geometry.PlanarSubdivision where

import           Control.Lens
import qualified Data.BalBST as SS
import           Data.Bifunctor.Apply
import qualified Data.CircularSeq as C
import           Data.Ext
import qualified Data.Foldable as F
import           Data.Geometry.Interval
import           Data.Geometry.LineSegment
import           Data.Geometry.Point
import           Data.Geometry.Polygon
import           Data.Geometry.Properties
import qualified Data.Map as M
import           Data.PlanarGraph
import           Data.PlaneGraph
import           Data.Semigroup
import           Data.Util
import qualified Data.Vector as V


-- | Note that the functor instance is in v
data VertexData r v = VertexData { _location :: !(Point 2 r)
                                 , _vData    :: !v
                                 } deriving (Show,Eq,Ord,Functor,Foldable,Traversable)
makeLenses ''VertexData

instance Bifunctor VertexData where
  bimap f g (VertexData p v) = VertexData (fmap f p) (g v)


data EdgeType = Visible | Invisible deriving (Show,Read,Eq,Ord)

data EdgeData e = EdgeData { _edgeType :: !EdgeType
                           , _eData    :: !e
                           } deriving (Show,Eq,Ord,Functor,Foldable,Traversable)
makeLenses ''EdgeData


-- | The Face data consists of the data itself and a list of holes
data FaceData h f = FaceData { _holes :: [h]
                             , _fData :: !f
                             } deriving (Show,Eq,Ord,Functor,Foldable,Traversable)
makeLenses ''FaceData


newtype PlanarSubdivision s v e f r = PlanarSubdivision { _graph ::
    PlanarGraph s Primal_ (VertexData r v) (EdgeData e) (FaceData (Dart s) f) }
      deriving (Show,Eq)
makeLenses ''PlanarSubdivision

instance Functor (PlanarSubdivision s v e f) where
  fmap f s = s&graph.vertexData.traverse.location %~ fmap f


--------------------------------------------------------------------------------

-- | Construct a planar subdivision from a polygon
--
-- running time: $O(n)$.
fromPolygon                            :: proxy s
                                       -> SimplePolygon p r
                                       -> f -- ^ data inside
                                       -> f -- ^ data outside the polygon
                                       -> PlanarSubdivision s p () f r
fromPolygon p (SimplePolygon vs) iD oD = PlanarSubdivision g'
  where
    g      = fromVertices p vs
    fData' = V.fromList [FaceData [] iD, FaceData [] oD]

    g'     = g & faceData .~ fData'
               & dartData.traverse._2 .~ EdgeData Visible ()
-- The following does not really work anymore
-- frompolygon p (MultiPolygon vs hs) iD oD = PlanarSubdivision g'
--   where
--     g      = fromVertices p vs
--     hs'    = map (\h -> fromPolygon p h oD iD) hs
--            -- note that oD and iD are exchanged
--     fData' = V.fromList [FaceData iD hs', FaceData oD []]


fromVertices      :: proxy s
                  -> C.CSeq (Point 2 r :+ p)
                  -> PlanarGraph s Primal_ (VertexData r p) () ()
fromVertices _ vs = g&vertexData .~ vData'
  where
    n = length vs
    g = planarGraph [ [ (Dart (Arc i)               Positive, ())
                      , (Dart (Arc $ (i+1) `mod` n) Negative, ())
                      ]
                    | i <- [0..(n-1)]]
    vData' = V.fromList . map (\(p :+ e) -> VertexData p e) . F.toList $ vs


-- | Constructs a connected planar subdivision.
--
-- pre: the segments form a single connected component
-- running time: $O(n\log n)$
fromConnectedSegments     :: (Foldable f, Ord r, Num r)
                            => proxy s
                            -> f (LineSegment 2 p r :+ EdgeData e)
                            -> PlanarSubdivision s [p] e () r
fromConnectedSegments px ss = PlanarSubdivision $
    fromConnectedSegments' px ss & faceData.traverse %~ FaceData []

-- | Constructs a planar graph
--
-- pre: The segments form a single connected component
--
-- running time: $O(n\log n)$
fromConnectedSegments'      :: (Foldable f, Ord r, Num r)
                            => proxy s
                            -> f (LineSegment 2 p r :+ e)
                            -> PlanarGraph s Primal_ (VertexData r [p]) e ()
fromConnectedSegments' _ ss = planarGraph dts & vertexData .~ vxData
  where
    pts         = M.fromListWith (<>) . concatMap f . zipWith g [0..] . F.toList $ ss
    f (s :+ e)  = [ ( s^.start.core
                    , SP [s^.start.extra] [(s^.end.core)   :+ h Positive e])
                  , ( s^.end.core
                    , SP [s^.end.extra]   [(s^.start.core) :+ h Negative e])
                  ]
    g i (s :+ e) = s :+ (Arc i :+ e)
    h d (a :+ e) = (Dart a d, e)

    vts    = map (\(p,sp) -> (p,map (^.extra) . sortArround (ext p) <$> sp))
           . M.assocs $ pts
    -- vertex Data
    vxData = V.fromList . map (\(p,sp) -> VertexData p (sp^._1)) $ vts
    -- The darts
    dts    = map (^._2._2) vts
