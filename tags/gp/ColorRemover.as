package sav.gp
{
	/**
	 * Inspired by ActiveDen Forum
	 * @link http://activeden.net/
	 */
	import flash.display.*;
	import flash.geom.*;
	import flash.filters.GlowFilter;	
	
	public class ColorRemover
	{
		/**
		 * Remove target color from a bitmapData, return a new transparent bitmapData
		 * 
		 * @param	source			BitmapData	source bitmapdata
		 * @param	testColor		uint		test color, RGB color value
		 * @param	colorRange		uint		color range for testing, this value should be max at 0xFF
		 * @param	smoothType		String		smooth type : "none", "inner", "outer"
		 * @param	smoothRange		Number		out/inner size for smoothing
		 * @param	smoothStrength	Number		smooth strength
		 * @return	BitmapData	
		 */
		public static function process(source:BitmapData, testColor:uint, colorRange:uint = 0, smoothType:String = 'inner', smoothRange:Number = 2, smoothStrength:Number = 10):BitmapData
		{
			var rect:Rectangle = new Rectangle(0, 0, source.width, source.height);
			var pt:Point = new Point();
			
			var r:uint = testColor >> 16 & 0xFF;
			var g:uint = testColor >> 8 & 0xFF;
			var b:uint = testColor & 0xFF;
			
			var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true, 0x00000000);
			
			var thRed_A:uint = ((r + colorRange) > 0xff) ? 0xff0000 : (r + colorRange) << 16 ;
			var thRed_B:uint = ((r - colorRange) < 0) ? 0 : (r - colorRange) << 16;
			var thGreen_A:uint = ((g + colorRange) > 0xff) ? 0xff00 : (g + colorRange) << 8;
			var thGreen_B:uint = ((g - colorRange) < 0) ? 0 : (g - colorRange) << 8;
			var thBlue_A:uint = ((b + colorRange) > 0xff) ? 0xff : (b + colorRange);
			var thBlue_B:uint = ((b - colorRange) < 0) ? 0 : (b - colorRange);
			
			bitmapData.threshold(source, rect, pt, ">", thRed_A, 0xffff0000, 0xff0000, false);
			bitmapData.threshold(source, rect, pt, "<", thRed_B, 0xffff0000, 0xff0000, false);
			bitmapData.threshold(source, rect, pt, ">", thGreen_A, 0xffff0000, 0x00ff00, false);		
			bitmapData.threshold(source, rect, pt, "<", thGreen_B, 0xffff0000, 0x00ff00, false);
			bitmapData.threshold(source, rect, pt, ">", thBlue_A, 0xffff0000, 0x0000ff, false);
			bitmapData.threshold(source, rect, pt, "<", thBlue_B, 0xffff0000, 0x0000ff, false);
			
			switch(smoothType)
			{
				case SMOOTH_NONE:					
					bitmapData.copyPixels(source, rect, pt, bitmapData, pt, false);
				break;
				
				case SMOOTH_OUTER:
					bitmapData.applyFilter(bitmapData, rect, pt, new GlowFilter(0x00ff00, 1, smoothRange, smoothRange, smoothStrength, smoothStrength, false, false));
					bitmapData.copyPixels(source, rect, pt, bitmapData, pt, false);
				break;
				
				case SMOOTH_INNER:
					bitmapData.applyFilter(bitmapData, rect, pt, new GlowFilter(0x00ff00, 1, smoothRange, smoothRange, smoothStrength, smoothStrength, true, false));
					
					var tempBitmapData:BitmapData = new BitmapData(rect.width, rect.height, false, 0x000000);
					tempBitmapData.copyPixels(bitmapData, rect, pt);
					
					bitmapData.copyPixels(source, rect, pt);
					bitmapData.copyChannel(tempBitmapData, rect, pt, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
				break;
				
				default:
					throw new Error('smooth type [' + smoothType + '] not defined');
			}
			
			return bitmapData;
		}
		
		public static var SMOOTH_NONE:String = 'none';
		public static var SMOOTH_INNER:String = 'inner';
		public static var SMOOTH_OUTER:String = 'outer';
	}
}