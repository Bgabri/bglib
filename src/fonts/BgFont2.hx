package fonts;
import hxd.res.BitmapFont;

/**
 * Loads the BG font. 
 **/
class BgFont2 {

     /**
      * Loads the font.
      * @return h2d.Font
      **/
     public static function get() : h2d.Font {
        var BYTES = hxd.res.Embed.getResource("res/fonts/BgFont2.png");
        var DESC = hxd.res.Embed.getResource("res/fonts/BgFont2.fnt");
        var bmp = new BitmapFont(DESC.entry);

        @:privateAccess bmp.loader = BYTES.loader;

          return bmp.toFont();
     }

}