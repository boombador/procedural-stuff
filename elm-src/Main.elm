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
    { forward : Vec3, right : Vec3, start : Vec3, up : Vec3 }


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


perspective : Float -> Mat4
perspective t =
    Mat4.mul
        (Mat4.makePerspective 45 1 0.01 100)
        (Mat4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) (vec3 0 0 0) (vec3 0 1 0))



-- Mesh


origin : Vec3
origin =
    vec3 0 0 0


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


mesh : Mesh Vertex
mesh =
    WebGL.triangles (cube 1 (vec3 0 0 0))



{- axis aligned bounding box. for simplicity assumes double sided triangles -}


cube : Float -> Vec3 -> List ( Vertex, Vertex, Vertex )
cube s center =
    let
        ( x, y, z, negX, negY, negZ ) =
            ( Vec3.i
            , Vec3.j
            , Vec3.k
            , Vec3.negate Vec3.i
            , Vec3.negate Vec3.j
            , Vec3.negate Vec3.k
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


houseOpts : HouseOpts
houseOpts =
    let
        ( w, h, l ) =
            ( 2, 2, 2 )
    in
        { right = Vec3.scale w Vec3.i
        , up = Vec3.scale h Vec3.j
        , forward = Vec3.scale l Vec3.k
        , start = vec3 0 0 0
        }


house : List ( Vertex, Vertex, Vertex )
house =
    let
        { right, up, forward, start } =
            houseOpts

        ( nearCorner, farCorner, pivot ) =
            ( start
            , List.foldl Vec3.add start [ right, up, forward ]
            , Vec3.scale 0.5 (Vec3.add right forward)
            )
    in
        []



{-
       // set object origin to base of house
       pivotOffset.addVectors(vRight, vForward).multiplyScalar(0.5);
       farCorner.sub(pivotOffset);
       nearCorner.sub(pivotOffset);

       // build horizontal walls
       buildDirectedQuad(geo, nearCorner, vRight, vUp);
       buildDirectedQuad(geo, nearCorner, vUp, vForward);
       vRight.multiplyScalar(-1);
       vForward.multiplyScalar(-1);
       vUp.multiplyScalar(-1);
       buildDirectedQuad(geo, farCorner, vUp, vRight);
       buildDirectedQuad(geo, farCorner, vForward, vUp);
       vRight.multiplyScalar(-1);
       vForward.multiplyScalar(-1);
       vUp.multiplyScalar(-1);

       // roof
       roofPeak.set(0, 0, 0).addScaledVector(globalUp, vUp.length() + m_RoofHeight).addScaledVector(vRight, 0.5).sub(pivotOffset).add(opts.start);
       wallTopLeft.subVectors(vUp, pivotOffset).add(opts.start);
       wallTopRight.addVectors(vUp, vRight).sub(pivotOffset).add(opts.start);

       addTri(geo, wallTopLeft.clone(), roofPeak.clone(), wallTopRight.clone());
       roofPeak.add(vForward);
       wallTopLeft.add(vForward);
       wallTopRight.add(vForward);
       addTri(geo, wallTopLeft.clone(), wallTopRight.clone(), roofPeak.clone());

       roofPeak.sub(vForward);
       wallTopLeft.sub(vForward);
       wallTopRight.sub(vForward);

       var dirFromPeakLeft = new THREE.Vector3().subVectors(wallTopLeft, roofPeak);
       var dirFromPeakRight = new THREE.Vector3().subVectors(wallTopRight, roofPeak);

       var normDirFromPeakLeft = dirFromPeakLeft.clone().normalize();
       var normDirFromPeakRight = dirFromPeakRight.clone().normalize();
       dirFromPeakLeft.addScaledVector(normDirFromPeakLeft, m_RoofOverhangSide);
       dirFromPeakRight.addScaledVector(normDirFromPeakRight, m_RoofOverhangSide);

       roofPeak.addScaledVector( globalForward, -m_RoofOverhangFront);
       vForward.addScaledVector( globalForward, m_RoofOverhangFront * 2);

       buildDirectedQuad(geo, roofPeak, vForward, dirFromPeakLeft);
       buildDirectedQuad(geo, roofPeak, dirFromPeakRight, vForward);
       buildDirectedQuad(geo, roofPeak, dirFromPeakLeft, vForward);
       buildDirectedQuad(geo, roofPeak, vForward, dirFromPeakRight);
   };-
-}


tri : Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
tri x y z =
    [ ( Vertex x (vec3 1 0 0)
      , Vertex y (vec3 0 1 0)
      , Vertex z (vec3 0 0 1)
      )
    ]



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
