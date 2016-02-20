var WIDTH = 400,
    HEIGHT = 400;

var m_Width = 1.0;
var m_Length = 1.0;
var m_SegmentCount = 10;

var addQuad = function (geo, offset) {
    console.log("generating mesh with offset:", offset);

    geo.vertices.push(
        (new THREE.Vector3( 0,  0, 0 )).add(offset),
        (new THREE.Vector3( m_Width,  0, 0 )).add(offset),
        (new THREE.Vector3( m_Width, m_Length, 0 )).add(offset),
        (new THREE.Vector3( 0, m_Length, 0 )).add(offset)
    );
    var baseIndex = geo.vertices.length - 4;
    geo.faces.push( new THREE.Face3( baseIndex, baseIndex+1, baseIndex+2 ) );
    geo.faces.push( new THREE.Face3( baseIndex, baseIndex+2, baseIndex+3 ) );
}

var createGeometry = function() {
    var geometry = new THREE.Geometry();
    var offset = new THREE.Vector3();
    var i, j, x, y;

    console.log("starting");
    console.log("segcount: ", m_SegmentCount);
    for (i = 0; i < m_SegmentCount; i++) {
        y = m_Length * i;

        for (j = 0; j < m_SegmentCount; j++) {
            x = m_Width * j;

            offset.set(x, y, Math.random(3) ); //  = new Vector3(x, Random.Range(0.0f, m_Height), z);
            console.log(offset);
            addQuad(geometry, offset);
        }
    }

    geometry.computeBoundingSphere();
    return geometry;
}

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

var halfWayX = (m_SegmentCount / 2) * m_Width;
var halfWayY = (m_SegmentCount / 2) * m_Length;

camera.position.set(halfWayX, -halfWayY, 5);
 camera.lookAt(new THREE.Vector3(halfWayX, halfWayY, 0));
// camera.up.set(new THREE.Vector3(0, 1, 0));

var render = function () {
    requestAnimationFrame( render );
    renderer.render(scene, camera);
};

render();

