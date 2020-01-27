module Procedural.Terrain exposing (..)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Procedural.Models exposing (Color, Triangle, TriangleMesh, Vertex)
import Procedural.Primitives exposing (quad, toMesh)



-- Terrain and Ground


type alias Terrain =
    { xSegments : Int
    , zSegments : Int
    , xDelta : Float
    , zDelta : Float
    , heightList : List Float
    }


groundColor : Color
groundColor =
    vec3 0 1 0


groundPlane : Float -> TriangleMesh
groundPlane toEdge =
    let
        ( x, z, offset ) =
            ( Vec3.scale toEdge Vec3.i
            , Vec3.scale toEdge Vec3.k
            , -(toEdge / 2)
            )
    in
    toMesh groundColor (quad (vec3 offset 0 offset) x z)


terrain : Int -> Int -> Float -> Float -> List Float -> Terrain
terrain xSegments zSegments xDelta zDelta heightList =
    { xSegments = xSegments
    , zSegments = zSegments
    , xDelta = xDelta
    , zDelta = zDelta
    , heightList = heightList
    }


remainder : Int -> Int -> Int
remainder a b =
    -- no idea if this is doing what the old `rem` function did
    let
        quotient =
            a // b

        leastMultiple =
            quotient * b
    in
    a - leastMultiple


{-| This is making the plane go over in the wrong area, but otherwise is
looking good
-}
terrainToMesh : Terrain -> List Triangle
terrainToMesh t =
    let
        { xSegments, zSegments, xDelta, zDelta, heightList } =
            t

        withIndices : Int -> Float -> ( Int, Int, Float )
        withIndices idx h =
            ( remainder idx xSegments, idx // zSegments, h )

        quadFunc : ( Int, Int, Float ) -> List Triangle
        quadFunc =
            toQuad xDelta zDelta
    in
    heightList
        |> List.indexedMap withIndices
        |> List.map quadFunc
        |> List.concat


toQuad : Float -> Float -> ( Int, Int, Float ) -> List Triangle
toQuad dx dz triplet =
    let
        ( ix, iz, h ) =
            triplet

        ( xSide, zSide ) =
            ( toFloat ix * dx, toFloat iz * dz )

        start =
            vec3 xSide h zSide
    in
    quad start (Vec3.scale xSide Vec3.i) (Vec3.scale zSide Vec3.k)
