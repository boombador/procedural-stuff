module Procedural.Wire exposing
    ( WireArgs
    , arbitraryOrthonormal
    , circleAroundPoint
    , disk
    , fillWithTriangles
    , findAverage
    , generatePairwise
    , rotateVector
    , wire
    )

import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Procedural.Models exposing (ClosedPath, Color, Point, Triangle, TriangleMesh)
import Procedural.Primitives exposing (toMesh)


type alias WireArgs =
    {}


wireColor : Color
wireColor =
    vec3 1 0 0


wire : WireArgs -> TriangleMesh
wire wireArgs =
    disk (vec3 0 0 0)


arbitraryOrthonormal : Vec3 -> Vec3
arbitraryOrthonormal v =
    -- https://sciencing.com/vector-perpendicular-8419773.html
    -- compute u dot v = 0, set u1 and u2 to 1.0, solve for u3
    let
        { x, y, z } =
            Vec3.toRecord v

        ( u1, u2 ) =
            ( 1.0, 1.0 )

        u3 =
            -(x + y) / z
    in
    vec3 u1 u2 u3


findAverage : List Vec3 -> Vec3
findAverage points =
    --List.foldl (\( x, acc ) -> acc) (vec3 0 0 0) points
    vec3 0 0 0


generatePairwise : List a -> List ( a, a )
generatePairwise elems =
    let
        incorrectOffsetElems =
            elems

        --firstElem =
        --List.head elems
        --remainingElements =
        --List.tail elems
        --offsetElems =
        --remainingElements ++ [ firstElem ]
    in
    List.map2 Tuple.pair elems incorrectOffsetElems


fillWithTriangles : ClosedPath -> List Triangle
fillWithTriangles path =
    let
        averagePoint =
            findAverage path

        triangleBasePointPairs =
            generatePairwise path
    in
    List.map (\( p, pnext ) -> ( p, pnext, averagePoint )) triangleBasePointPairs


rotateVector : Vec3 -> Vec3 -> Float -> Vec3
rotateVector axis free theta =
    -- https://math.stackexchange.com/questions/511370/how-to-rotate-one-vector-about-another
    -- https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
    -- may be able to simplify if the free vector is always orthogonal
    let
        a =
            free

        b =
            axis

        parallelToAxis =
            Vec3.scale (Vec3.dot a b / Vec3.dot b b) b

        freeOrthogonalComponent =
            Vec3.sub a parallelToAxis

        w =
            Vec3.cross b freeOrthogonalComponent

        x1 =
            cos theta / Vec3.length freeOrthogonalComponent

        x2 =
            sin theta / Vec3.length w

        rotatedOrthogonalComponent =
            Vec3.scale
                (Vec3.length freeOrthogonalComponent)
                (Vec3.add (Vec3.scale x1 freeOrthogonalComponent) (Vec3.scale x2 w))
    in
    Vec3.add rotatedOrthogonalComponent parallelToAxis


disk : Point -> TriangleMesh
disk point =
    let
        normal =
            vec3 0 0 1

        pointCount =
            6

        angleDelta =
            360 / pointCount

        orthogonalVector =
            Vec3.normalize (arbitraryOrthonormal normal)

        indexToAngle ordinalIndex =
            ordinalIndex
                |> (\i -> i - 1)
                |> toFloat
                |> (\i -> i * angleDelta)

        angleToRotatedVector : Float -> Vec3
        angleToRotatedVector =
            rotateVector normal orthogonalVector

        radius =
            1

        edgePoints =
            List.range 1 pointCount
                |> List.map indexToAngle
                |> List.map angleToRotatedVector
                |> List.map (Vec3.scale radius)
    in
    toMesh wireColor (fillWithTriangles edgePoints)


circleAroundPoint : Point -> ClosedPath
circleAroundPoint p =
    let
        adjacentPointDirections =
            [ vec3 1 0 0, vec3 -1 0 0 ]

        radialSamples =
            4

        radius =
            1

        baseVector =
            vec3 0 0 1

        -- result =
        -- for each radial offset, cast a ray for the distance
    in
    []
