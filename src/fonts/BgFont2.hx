package fonts;
import hxd.res.BitmapFont;

class BgFont2 {

	public static function get() : h2d.Font {
		var engine = h3d.Engine.getCurrent();
        
        var BYTES = hxd.res.Embed.getResource("res/fonts/BgFont2.png");
        var DESC = hxd.res.Embed.getResource("res/fonts/BgFont2.fnt");
        var bmp = new BitmapFont(DESC.entry);

        @:privateAccess bmp.loader = BYTES.loader;

		return bmp.toFont();
	}

}