package sav.gp
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class BitmapDrawer
	{
		public static var LINE_NORMAL			:uint = 1;
		public static var bitmapData			:BitmapData;
		public static var currentPoint			:Point;
		
		public static function workOn(bd:BitmapData):void { bitmapData = bd };		
		
		public static function workEnd():void{ bitmapData = null };
		
		public static function moveTo(point:Point):void { currentPoint = point; }
		
		public static function lineTo(pointB:Point):void
		{
			bitmapData.lock();
			var pointA = currentPoint.clone();
			var drawPoint = pointA.clone();			
			var dPoint = pointB.subtract(drawPoint);
			
			while(dPoint.length > LINE_NORMAL)
			{
				dPoint.normalize(LINE_NORMAL);
				drawPoint.x += dPoint.x;
				drawPoint.y += dPoint.y;
				bitmapData.setPixel32(drawPoint.x , drawPoint.y , 0xff000000);
				dPoint = pointB.subtract(drawPoint);
			}			
			bitmapData.setPixel32(pointB.x , pointB.y , 0xff000000);
			bitmapData.unlock();
			currentPoint = pointB.clone();
		}
		
		public static function curveTo(pointB:Point , pointC:Point):void
		{
			var pointA = currentPoint.clone();
			bitmapData.lock();
			//bitmapData.setPixel32(pointA.x , pointA.y , 0xff000000);
			//bitmapData.setPixel32(pointB.x , pointB.y , 0xff000000);
			//bitmapData.setPixel32(pointC.x , pointC.y , 0xff000000);
			
			for (var a=0;a<1;a+=0.05)
			{
				var b=1-a;
				var pre1=(a*a);
				var pre2=2*a*b;
				var pre3=(b*b);
				var drawPoint = new Point(pre1*pointA.x + pre2*pointB.x  + pre3*pointC.x , pre1*pointA.y + pre2*pointB.y + pre3*pointC.y);
				lineTo(drawPoint);
				trace(a);
				trace(drawPoint);
			}

			bitmapData.unlock();
			currentPoint = pointC.clone();			
		}
		
	}
}