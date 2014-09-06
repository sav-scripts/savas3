package sav.utils
{
	import flash.geom.Point;
	
	public class GeomUtils
	{
		public static function rotatePoint(oldPoint:Point , degree:Number):Point
		{			
			var tx:Number = oldPoint.x;
			var ty:Number = oldPoint.y;
			var arc:Number = degree/180*Math.PI;
			var dx:Number = Math.cos(arc)*tx - Math.sin(arc)*ty;
			var dy:Number = Math.cos(arc)*ty + Math.sin(arc)*tx;
			
			return new Point(dx , dy);
		}
	}
}