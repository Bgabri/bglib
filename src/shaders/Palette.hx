package shaders;
import h3d.mat.Texture;

class Palette extends h3d.shader.ScreenShader {

    static var SRC = {
        @param var texture:Sampler2D;
        @param var colors:Sampler2D;
        @param var size:Float;
        
        function fragment() {


            pixelColor = texture.get(input.uv);

            var newColor:Vec4 = colors.get(vec2(0, 0));

            for (i in 0...int(size)) {
                var color:Vec4 = colors.get(vec2(i/size, 0));

                if (distance(pixelColor, color) < distance(pixelColor, newColor)) {
                    newColor = color;
                }
            }
            pixelColor = newColor;

        }
    }


    public function new(pallete:Texture) {
		super();
        colors = pallete;
        colors.filter = Nearest;
        size = pallete.width;
	}

}
