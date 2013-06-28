package sav.geom
{
	import flash.geom.Point;
	public class Utils2D
	{
		public static function rotatePoint(point:Point, degree:Number, givePrecisionValue:Boolean = true):Point
		{	
			var arc:Number = degreeToPI(degree);
			var cos:Number = Math.cos(arc);
			var sin:Number = Math.sin(arc);
			
			//var x:Number = cos * point.x + sin * point.y;
			//var y:Number = cos * point.y - sin * point.x;
			//trace('sin = ' + sin);
			//trace('cos = ' + (cos == 1));
			
			var x:Number = point.x * cos - point.y * sin;
			var y:Number = point.x * sin + point.y * cos;
			
			if (givePrecisionValue == false)
			{
				x = int(x * 10000) / 10000;
				y = int(y * 10000) / 10000;
			}
			
			return new Point(x, y);
		}
		
		public static function rotatePointByPoint(centerPoint:Point, targetPoint:Point, degree:Number, givePrecisionValue:Boolean = true):Point
		{	
			var dPoint:Point = targetPoint.subtract(centerPoint);
			dPoint = rotatePoint(dPoint, degree, givePrecisionValue);
			
			return dPoint.add(centerPoint);
		}
		
		public static function degreeToPI(degree:Number):Number
		{
			return Math.PI * (degree / 180);
		}
	}
}