package sav.utils
{
	import flash.geom.Point;
	
	public class GeomUtils
	{
		public static function rotatePoint(oldPoint:Point , degree:Number):Point
		{			
			var tx = oldPoint.x;
			var ty = oldPoint.y;
			var arc = degree/180*Math.PI;
			var dx = Math.cos(arc)*tx - Math.sin(arc)*ty;
			var dy = Math.cos(arc)*ty + Math.sin(arc)*tx;
			
			return new Point(dx , dy);
		}
	}
}