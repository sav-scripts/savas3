package sav.gp
{
	import flash.display.Graphics;
	import flash.geom.Point;
	public class Pen
	{
		private static var p:Point;
		private static var g:Graphics;
		
		/**
		 * Put pen on a target Graphics object, and move to a target position
		 * 
		 * @param	graphics	Graphics	Target Graphics object
		 * @param	tx			Number		Target x
		 * @param	ty			Number		Target y
		 */
		public static function putOn(graphics:Graphics, tx:Number, ty:Number):void
		{
			g = graphics;
			p = new Point(tx, ty);
			
			g.moveTo(tx, ty);
		}
		
		/**
		 * Draw a line, given value is differ value insteand of target value
		 * @param	dx		Number	Differ x
		 * @param	dy		Number	Differ y
		 */
		public static function lineTo(dx:Number = 0, dy:Number = 0):void
		{
			p.offset(dx, dy);
			g.lineTo(p.x, p.y);
		}
		
		public static function curveTo(cx:Number, cy:Number, tx:Number, ty:Number):void
		{
			var cx2:Number = p.x + cx;
			var cy2:Number = p.y + cy;
			p.offset(cx + tx, cy + ty);
			g.curveTo(cx2, cy2, p.x, p.y);
		}
	}
}