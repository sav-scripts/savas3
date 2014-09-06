package sav.utils
{
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class ColorUtils
	{
		/**
		 * Input colour value such as 0xFF0000, and modifier from -1 to 1.
		 */
		public static function brighten(color:uint, modifier:Number):uint
		{
			var z:int = 0xff * modifier;

			var r:uint = trim(((color & 0xff0000) >> 16) + z);
			var g:uint = trim(((color & 0x00ff00) >>  8) + z);
			var b:uint = trim(((color & 0x0000ff)      ) + z);

			return r << 16 | g << 8 | b;
		}

		/**
		 * Blends two colours. Percentage should be 0.5 for an equal blend.
		 */
		public static function blend(first:uint, second:uint, percent:Number):uint
		{
			var r:int = ((first & 0xff0000) >> 16) * (1 - percent) + ((second & 0xff0000) >> 16) * percent;
			var g:int = ((first & 0x00ff00) >>  8) * (1 - percent) + ((second & 0x00ff00) >>  8) * percent;
			var b:int = ((first & 0x0000ff)      ) * (1 - percent) + ((second & 0x0000ff)      ) * percent;

			return r << 16 | g << 8 | b;
		}

		public static function desaturate(color:uint, percent:Number):uint
		{
			return blend(color, 0x7F7F7F, percent);
		}

		public static function bleach(color:uint, percent:Number):uint
		{
			return blend(color, 0xFFFFFF, percent);
		}

		public static function darken(color:uint, percent:Number):uint
		{
			return blend(color, 0x000000, percent);
		}

		private	static function trim(value:int):uint
		{
			return Math.min(Math.max(0x00, value), 0xff);
		}

		// HELPERS ////////////////////////////////////////////////////////////////////////////

		public static function getR(color:uint):uint
		{
			return (color & 0xff0000) >> 16;
		}

		public static function getG(color:uint):uint
		{
			return (color & 0x00ff00) >> 8;
		}

		public static function getB(color:uint):uint
		{
			return color & 0x0000ff;
		}

	}
}