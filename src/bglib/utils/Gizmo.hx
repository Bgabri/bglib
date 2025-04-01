package bglib.utils;

import h3d.scene.Graphics;

/**
 * A circle in 3d space.
 **/
class Circle extends Graphics {
    public var thickness:Float = 1.0;
    public var color:Int = 0;
    public var r:Float = 1.0;
    public var N:Int = 8;

    public function new(?parent) {
        super(parent);
    }

    override function sync(ctx) {
        clear();

        lineStyle(thickness, color);

        var re = Math.cos((N - 1) / N * 6.2831) * r;
        var im = Math.sin((N - 1) / N * 6.2831) * r;
        moveTo(re, im, 0);

        for (i in 0...N) {
            var re = Math.cos(i / N * 6.2831) * r;
            var im = Math.sin(i / N * 6.2831) * r;

            lineTo(re, im, 0);
        }

        super.sync(ctx);
    }
}

/**
 * A 3d orientation reference in 3d space.
 * 
 * X: Red
 * 
 * Y: Green
 * 
 * Z: Blue
 **/
class Gizmo extends Graphics {
    public var thickness:Float = 2.0;
    public var length(default, set) = 1.0;
    public var offset:Float = 0.;

    var cx:Circle;
    var cy:Circle;
    var cz:Circle;

    public function new(?parent) {
        super(parent);
        cx = new Circle(this);
        cx.rotate(0, 1.57, 0);
        cx.r = 0.2;
        cx.color = 0xFF0000;

        cy = new Circle(this);
        cy.rotate(1.57, 0, 0);
        cy.r = 0.2;
        cy.color = 0x00FF00;

        cz = new Circle(this);
        cz.r = 0.2;
        cz.color = 0x0000FF;
    }

    override function sync(ctx) {
        clear();

        lineStyle(thickness, 0xFF0000);
        moveTo((-offset) * length, 0, 0);
        lineTo((1 - offset) * length, 0, 0);
        cx.thickness = thickness;
        cx.x = (1 - offset) * length - 0.3;

        lineStyle(thickness, 0x00FF00);
        moveTo(0, (-offset) * length, 0);
        lineTo(0, (1 - offset) * length, 0);
        cy.thickness = thickness;
        cy.y = (1 - offset) * length - 0.3;

        lineStyle(thickness, 0x0000FF);
        moveTo(0, 0, (-offset) * length);
        lineTo(0, 0, (1 - offset) * length);
        cz.thickness = thickness;
        cz.z = (1 - offset) * length - 0.3;

        super.sync(ctx);
    }

    function set_length(value):Float {
        if (value < 0) value = 0;
        if (value < 1) {
            removeChild(cx);
            removeChild(cy);
            removeChild(cz);
        } else {
            addChild(cx);
            addChild(cy);
            addChild(cz);
        }
        return length = value;
    }
}
