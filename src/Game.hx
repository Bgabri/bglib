import h2d.HtmlText;
import h2d.Interactive;
import h2d.Slider;
import h2d.Flow;
import h2d.Font;

import fonts.BgFont2;

import h2d.filter.Nothing;
import h2d.Graphics;
import h2d.Tile;
import h2d.Bitmap;

import h3d.mat.Texture;

/**
 * The base game class with basic quick add ui elements and pixelization.
 **/
class Game extends hxd.App {
    var fps:h2d.HtmlText;
    var drawCalls:h2d.Text;
    var triangles:h2d.Text;
    var fui:h2d.Flow;

    var renderTarget:Texture;
    var renderTargetBitmap:Bitmap;
    var pxScale(default, set):Int = 1;

    static public var frameWidth(default, null):Int = 0;
    static public var frameHeight(default, null):Int = 0;

    override function init() {
        @:privateAccess engine.window.addEventTarget(onEvent);

        var w = Math.floor(engine.width / pxScale);
        var h = Math.floor(engine.height / pxScale);

        // shader which limits the number of colours drawn;
        var paletteShader = new shaders.Palette(hxd.Res.pear36.toTexture());

        // draw the renderTarget in s2d
        renderTargetBitmap = new Bitmap(s2d);
        renderTargetBitmap.setScale(pxScale);

        setScale();

        s2d.filter = new Nothing(); // pixel perfection!
        s2d.filter = new h2d.filter.Shader(paletteShader);

        fui = new h2d.Flow(s2d); // s2d
        fui.layout = Vertical;
        fui.verticalSpacing = 5;

        fps = addText("0");
        drawCalls = addText("0");
        triangles = addText("0");
    }

    override function render(e:h3d.Engine) {
        engine.pushTarget(renderTarget);

        engine.clear(0, 1);
        s3d.render(e);

        engine.popTarget();

        s2d.render(e);
    }

    function setScale() {
        if (renderTargetBitmap == null) return;

        frameWidth = Math.floor(engine.width / pxScale);
        frameHeight = Math.floor(engine.height / pxScale);

        // creates a texture to render s2d to
        renderTarget = new Texture(frameWidth, frameHeight, [Target]);

        renderTarget.depthBuffer = Texture.getDefaultDepth();
        renderTarget.depthBuffer.resize(frameWidth, frameHeight);
        renderTarget.filter = Nearest;

        renderTargetBitmap.tile = Tile.fromTexture(renderTarget);

        s2d.setScale(pxScale); // scales s2d
    }

    override function onResize() {
        setScale();
        fui.maxHeight = Game.frameHeight;
    }

    function getFont():Font {
        return BgFont2.get();
    }

    function set_pxScale(scale:Int):Int {
        this.pxScale = scale;
        setScale();
        return scale;
    }

    var fpsT:Float = 0.;
    var countFPS:Float = 0.;
    var sumFPS:Float = 0.;

    override function update(dt:Float) {
        if (fpsT > .25) {
            fps.text = '${Math.floor(sumFPS / countFPS * 10 + .5) / 10}';
            sumFPS = 0;
            countFPS = 0;
            fpsT = 0;
        }

        sumFPS += engine.fps;
        countFPS++;
        fpsT += dt;

        drawCalls.text = '${engine.drawCalls}';
        triangles.text = '${engine.drawTriangles}';
    }

    var keyUp:Array<Bool> = [];

    function onEvent(event:hxd.Event) {
        switch (event.kind) {
            case EKeyDown:
                if (!keyUp[event.keyCode]) keyPressed(event.keyCode);
                keyUp[event.keyCode] = true;
            case EKeyUp:
                keyReleased(event.keyCode);
                keyUp[event.keyCode] = false;

            case EPush:
                mousePress(event);
            case ERelease:
                mouseRelease(event);
            case EMove:
                mouseMoved(event);
            case _:
        }
    }

    function keyPressed(keyCode:Int) {}

    function keyReleased(keyCode:Int) {}

    function mousePress(event:hxd.Event) {}

    function mouseRelease(event:hxd.Event) {}

    function mouseMoved(event:hxd.Event) {}

    // from sampleApp
    function addButton(label:String, onClick:Void->Void):Flow {
        var f = new h2d.Flow(fui);
        f.padding = 5;
        f.paddingBottom = 7;
        f.backgroundTile = h2d.Tile.fromColor(0x404040);
        var tf = new h2d.Text(getFont(), f);
        tf.text = label;
        f.enableInteractive = true;
        f.interactive.cursor = Button;
        f.interactive.onClick = (_) -> onClick();
        f.interactive.onOver = (_) -> {
            f.backgroundTile = Tile.fromColor(0x606060);
        };
        f.interactive.onOut = (_) -> {
            f.backgroundTile = Tile.fromColor(0x404040);
        };
        return f;
    }

    function addSlider(
        label:String, get:Void->Float, set:Float->Void, min:Float = 0.,
        max:Float = 1.
    ):Slider {
        var f = new h2d.Flow(fui);

        f.horizontalSpacing = 5;

        var tf = new h2d.Text(getFont(), f);
        tf.text = label;
        tf.maxWidth = 70;
        tf.textAlign = Right;

        var sli = new h2d.Slider(100, 10, f);
        sli.minValue = min;
        sli.maxValue = max;
        sli.value = get();

        var tf = new h2d.TextInput(getFont(), f);
        tf.text = "" + hxd.Math.fmt(sli.value);
        sli.onChange = function() {
            set(sli.value);
            tf.text = "" + hxd.Math.fmt(sli.value);
            f.needReflow = true;
        };
        tf.onChange = function() {
            var v = Std.parseFloat(tf.text);
            if (Math.isNaN(v)) return;
            sli.value = v;
            set(v);
        };
        return sli;
    }

    function addGraph(
        x1:Int,
        y1:Int,
        x2:Int,
        y2:Int,
        get:Void->Float,
        scaleX:Float = 1,
        scaleY:Float = 1,
        graphColor = 0x0000FF,
        axisColor = 0x888888
    ):() -> Void {
        var graph = new Graphics(s2d);
        var points:Array<Float> = [get()];

        var update = () -> {
            points.push(get());
            if (points.length * scaleX > x2 - x1) points = [get()];

            graph.clear();
            graph.lineStyle(1, axisColor, .9);
            graph.moveTo(x1, y1);
            graph.lineTo(x2, y2);

            graph.lineStyle(1, graphColor, 1);
            graph.moveTo(x1, points[0] * scaleY + y1);
            for (i => p in points)
                graph.lineTo(i * scaleX + x1, p * scaleY + y1);
        }
        return update;
    }

    function addCheck(
        label:String, get:Void->Bool, set:Bool->Void
    ):Interactive {
        var f = new h2d.Flow(fui);

        f.horizontalSpacing = 5;

        var tf = new h2d.Text(getFont(), f);
        tf.text = label;
        tf.maxWidth = 70;
        tf.textAlign = Right;

        var size = 10;
        var b = new h2d.Graphics(f);
        function redraw() {
            b.clear();
            b.beginFill(0x808080);
            b.drawRect(0, 0, size, size);
            b.beginFill(0);
            b.drawRect(1, 1, size - 2, size - 2);
            if (get()) {
                b.beginFill(0xC0C0C0);
                b.drawRect(2, 2, size - 4, size - 4);
            }
        }
        var i = new h2d.Interactive(size, size, b);
        i.onClick = function(_) {
            set(!get());
            redraw();
        };
        redraw();
        return i;
    }

    function addChoice(
        text, choices, callback:Int->Void, value = 0
    ):Interactive {
        var font = getFont();
        var i = new h2d.Interactive(110, font.lineHeight, fui);
        i.backgroundColor = 0xFF808080;
        fui.getProperties(i).paddingLeft = 20;

        var t = new h2d.Text(font, i);
        t.maxWidth = i.width;
        t.text = text + ":" + choices[value];
        t.textAlign = Center;

        i.onClick = function(_) {
            value++;
            value %= choices.length;
            callback(value);
            t.text = text + ":" + choices[value];
        };
        i.onOver = function(_) {
            t.textColor = 0xFFFFFF;
        };
        i.onOut = function(_) {
            t.textColor = 0xEEEEEE;
        };
        i.onOut(null);
        return i;
    }

    function addText(text = ""):HtmlText {
        var tf = new h2d.HtmlText(getFont(), fui);
        tf.text = text;
        return tf;
    }
}
