module Main exposing (..)

{-
   Rotating triangle, that is a "hello world" of the WebGL
-}

import AnimationFrame
import Html exposing (Html)
import Html.Attributes exposing (width, height, style)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Time exposing (Time)
import WebGL exposing (Mesh, Shader)


type alias HouseOpts =
    { center : Float
    , height : Float
    , hh : Float
    , hl : Float
    , hw : Float
    , length : Float
    , roofBase : Float
    , roofHeight : Float
    , roofTop : Float
    , start : Vec3
    , width : Float
    }


main : Program Never Time Time
main =
    Html.program
        { init = ( 0, Cmd.none )
        , view = view
        , subscriptions = (\model -> AnimationFrame.diffs Basics.identity)
        , update = (\elapsed currentTime -> ( elapsed + currentTime, Cmd.none ))
        }


view : Float -> Html msg
view t =
    WebGL.toHtml
        [ width 400
        , height 400
        , style [ ( "display", "block" ) ]
        ]
        [ WebGL.entity
            vertexShader
            fragmentShader
            mesh
            { perspective = perspective (t / 1000) }
        ]


target : Vec3
target =
    vec3 0 0 0


origin : Vec3
origin =
    vec3 0 0 0


perspective : Float -> Mat4
perspective t =
    Mat4.mul
        (Mat4.makePerspective 45 1 0.01 100)
        (Mat4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) target (vec3 0 1 0))



-- Mesh


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


mesh : Mesh Vertex
mesh =
    WebGL.triangles (house 1 1 1 0.5 origin)


cube : Float -> Vec3 -> List ( Vertex, Vertex, Vertex )
cube s =
    prism s s s


post : Vec3 -> List ( Vertex, Vertex, Vertex )
post base =
    let
        ( x, y, z ) =
            ( 0.1, 0.5, 0.1 )

        centerY =
            (y / 2) + Vec3.getY base

        center =
            Vec3.setY centerY base
    in
        prism x y z center


prism : Float -> Float -> Float -> Vec3 -> List ( Vertex, Vertex, Vertex )
prism w h l center =
    let
        ( x, y, z ) =
            ( Vec3.scale w Vec3.i
            , Vec3.scale h Vec3.j
            , Vec3.scale l Vec3.k
            )

        ( negX, negY, negZ ) =
            ( Vec3.negate x
            , Vec3.negate y
            , Vec3.negate z
            )

        nearCorner =
            List.foldl (\v a -> Vec3.sub a (Vec3.scale 0.5 v)) center [ x, y, z ]

        farCorner =
            List.foldl Vec3.add nearCorner [ x, y, z ]
    in
        List.concat
            [ quad nearCorner x y
            , quad nearCorner x z
            , quad nearCorner y z
            , quad farCorner negX negY
            , quad farCorner negX negZ
            , quad farCorner negY negZ
            ]


quad : Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
quad corner x y =
    let
        ( a, b, c, d ) =
            ( corner
            , Vec3.add corner x
            , Vec3.add corner (Vec3.add x y)
            , Vec3.add corner y
            )
    in
        List.concat
            [ tri a b c
            , tri a c d
            ]


houseOpts : Float -> Float -> Float -> Float -> Vec3 -> HouseOpts
houseOpts width height length roofHeight start =
    let
        ( hw, hh, hl ) =
            ( width / 2
            , height / 2
            , length / 2
            )

        ( center, roofBase, roofTop ) =
            ( hh + Vec3.getY start
            , height + Vec3.getY start
            , height + roofHeight + Vec3.getY start
            )
    in
        { width = width
        , height = height
        , length = length
        , roofHeight = roofHeight
        , start = start
        , hw = hw
        , hh = hh
        , hl = hl
        , center = center
        , roofBase = roofBase
        , roofTop = roofTop
        }


house : Float -> Float -> Float -> Float -> Vec3 -> List ( Vertex, Vertex, Vertex )
house h w l r start =
    let
        { width, height, length, roofHeight, hw, hh, hl, center, roofBase, roofTop } =
            houseOpts h w l r start
    in
        List.concat
            [ prism width height length (vec3 0 center 0)
            , roofSides hw hl roofBase roofTop
            , roof hw hl roofTop roofBase
            , fromPostPath (postPathEdge w l)
            ]


postPathEdge : Float -> Float -> ( Vec3, Vec3 )
postPathEdge w l =
    ( (vec3 w 0 l)
    , (vec3 -w 0 l)
    )


postPathSquare : Float -> Float -> List Vec3
postPathSquare w l =
    [ (vec3 w 0 l)
    , (vec3 -w 0 l)
    , (vec3 w 0 -l)
    , (vec3 -w 0 -l)
    ]


posts : List Vec3 -> List ( Vertex, Vertex, Vertex )
posts locations =
    locations
        |> List.map post
        |> List.concat


postsBetweenEndpoints : Int -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
postsBetweenEndpoints count a b =
    let
        distance =
            Vec3.distance a b

        split : Int
        split =
            floor (distance / toFloat count)
    in
        []


interpolate : Vec3 -> Vec3 -> Float -> Vec3
interpolate a b s =
    let
        aToB =
            Vec3.sub b a

        offset =
            Vec3.scale s aToB
    in
        Vec3.add a offset


maxSegmentsWithMinLength : Float -> Float -> Int
maxSegmentsWithMinLength minLength distance =
    floor (distance / minLength)


intermediatePoints : Float -> Vec3 -> Vec3 -> List Vec3
intermediatePoints targetSplit a b =
    let
        count =
            maxSegmentsWithMinLength targetSplit (Vec3.distance a b)

        fromS =
            interpolate a b

        sEntries =
            List.range 0 count
                |> List.map (\i -> 1 / toFloat i)
    in
        sEntries
            |> List.map fromS


fromPostPath : ( Vec3, Vec3 ) -> List ( Vertex, Vertex, Vertex )
fromPostPath endpoints =
    let
        ( a, b ) =
            endpoints

        points =
            [ a, b ]

        corners =
            points
                |> List.map post
                |> List.concat

        intermediate =
            posts (intermediatePoints 0.5 a b)
    in
        List.concat
            [ corners
            , intermediate
            ]


roof : Float -> Float -> Float -> Float -> List ( Vertex, Vertex, Vertex )
roof hw hl roofTop roofBase =
    let
        ( roofA, roofB, cornerA, cornerB ) =
            ( vec3 hw roofTop 0
            , vec3 -hw roofTop 0
            , vec3 hw roofBase hl
            , vec3 hw roofBase -hl
            )

        ( roofLine, downSlantA, downSlantB ) =
            ( Vec3.sub roofB roofA
            , Vec3.sub cornerA roofA
            , Vec3.sub cornerB roofA
            )
    in
        List.concat
            [ quad roofA roofLine downSlantA
            , quad roofA roofLine downSlantB
            ]


roofSides : Float -> Float -> Float -> Float -> List ( Vertex, Vertex, Vertex )
roofSides hw hl roofBase roofTop =
    List.concat
        [ tri (vec3 hw roofBase hl) (vec3 hw roofBase -hl) (vec3 hw roofTop 0)
        , tri (vec3 -hw roofBase hl) (vec3 -hw roofBase -hl) (vec3 -hw roofTop 0)
        ]


tri : Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
tri x y z =
    [ ( Vertex x (vec3 1 0 0)
      , Vertex y (vec3 0 1 0)
      , Vertex z (vec3 0 0 1)
      )
    ]


samplePrism : List ( Vertex, Vertex, Vertex )
samplePrism =
    prism 0.5 3 0.5 (vec3 0 0 0)



-- Shaders


type alias Uniforms =
    { perspective : Mat4 }


vertexShader : Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
    [glsl|
        attribute vec3 position;
        attribute vec3 color;
        uniform mat4 perspective;
        varying vec3 vcolor;
        void main () {
            gl_Position = perspective * vec4(position, 1.0);
            vcolor = color;
        }
    |]


fragmentShader : Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec3 vcolor;
        void main () {
            gl_FragColor = vec4(vcolor, 1.0);
        }
    |]
