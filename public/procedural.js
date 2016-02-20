var WIDTH = 400,
    HEIGHT = 400;

var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera( 75, WIDTH/HEIGHT, 0.1, 1000 );

var renderer = new THREE.WebGLRenderer();
renderer.setSize( WIDTH, HEIGHT );
document.body.appendChild( renderer.domElement );

var geometry = createGeometry();
var material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
var mesh = new THREE.Mesh( geometry, material );
scene.add( mesh );

var axisHelper = new THREE.AxisHelper( 5 );
scene.add( axisHelper );

camera.position.z = 5;

var render = function () {
    requestAnimationFrame( render );
    renderer.render(scene, camera);
};

render();

function createGeometry() {
    var m_width = 1.0;
    var m_length = 1.0;

    //Set up the vertices and triangles:
    //meshBuilder.Vertices.Add(new Vector3(0.0f, 0.0f, 0.0f));
    //meshBuilder.UVs.Add(new Vector2(0.0f, 0.0f));
    //meshBuilder.Normals.Add(Vector3.up);

    //meshBuilder.Vertices.Add(new Vector3(0.0f, 0.0f, m_Length));
    //meshBuilder.UVs.Add(new Vector2(0.0f, 1.0f));
    //meshBuilder.Normals.Add(Vector3.up);

    //meshBuilder.Vertices.Add(new Vector3(m_Width, 0.0f, m_Length));
    //meshBuilder.UVs.Add(new Vector2(1.0f, 1.0f));
    //meshBuilder.Normals.Add(Vector3.up);

    //meshBuilder.Vertices.Add(new Vector3(m_Width, 0.0f, 0.0f));
    //meshBuilder.UVs.Add(new Vector2(1.0f, 0.0f));
    //meshBuilder.Normals.Add(Vector3.up);


    var geometry = new THREE.Geometry();
    geometry.vertices.push(
        new THREE.Vector3( 0,  0, 0 ),
        new THREE.Vector3( m_width,  0, 0 ),
        new THREE.Vector3( m_width, m_length, 0 ),
        new THREE.Vector3( 0, m_length, 0 )
    );
    geometry.faces.push( new THREE.Face3( 0, 1, 2 ) );
    geometry.faces.push( new THREE.Face3( 0, 2, 3 ) );

    geometry.computeBoundingSphere();
    return geometry;
}
