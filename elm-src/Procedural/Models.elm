module Procedural.Models exposing (..)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)


type alias Color =
    Vec3


type alias Point =
    Vec3


type alias Triangle =
    ( Point, Point, Point )



-- deprecated


type alias Tris =
    List ( Vec3, Vec3, Vec3 )


type alias Vertex =
    { position : Point
    , color : Color
    }


type alias TriangleMesh =
    List ( Vertex, Vertex, Vertex )


type alias ClosedPath =
    List Point
