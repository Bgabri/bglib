import hxd.Res;
import h3d.mat.PbrMaterialSetup;

/**
 * Entry point, demo of a basic 3d scene.
 **/
class Main extends Game {
    public function new() {
        h3d.mat.MaterialSetup.current = new PbrMaterialSetup();

        super();
    }

    override function init() {
        super.init();

        var cubePrimative = h3d.prim.Cube.defaultUnitCube();

        var directionalLight = new h3d.scene.pbr.DirLight(
            new h3d.Vector(0.5, 0.2, -1), s3d
        );
        directionalLight.shadows.mode = Dynamic;
        directionalLight.color.set(1, 1, .6);

        var cube = new h3d.scene.Mesh(cubePrimative, s3d);
        cube.material.color.setColor(0x8ADA2E);
        cube.scaleX = 10;
        cube.scaleY = 10;
        cube.z = -1.5;
        cube.material.allocPass("terrain");

        var terrain = new h3d.shader.pbr.PropsValues(.2, 1);
        cube.material.mainPass.addShader(terrain);

        var pbrValues = new h3d.shader.pbr.PropsValues(.9, .5);
        var cache = new h3d.prim.ModelCache();

        var ico = cache.loadModel(hxd.Res.Model.Icosahedron);
        ico.setPosition(0, 0, 1);
        ico.scale(.75);
        for (mat in ico.getMaterials()) {
            mat.mainPass.addShader(pbrValues);
            mat.color.setColor(0xDA2E79);
        }
        s3d.addChild(ico);

        s3d.camera.pos.set(24, 24, 6);
        new h3d.scene.CameraController(s3d).loadFromCamera();
    }

    override function update(dt:Float) {
        super.update(dt);
    }

    static function main() {
        #if js
        Res.initEmbed();
        #else
        Res.initLocal();
        #end
        new Main();
    }
}
