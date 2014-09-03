package sav.utils
{
	import flash.geom.Point;
	import flash.display.DisplayObject;
	
	public class MyMath
	{
		//取得隨機正負值
		public static function throwCoin():int
		{
			var coin = (Math.random()<.5)?-1:1;
			return coin;
		}
		//取得一個在所給予引數的正副值之間的亂數
		public static function randomBetween(n1:Number,n2:Number,isInt:Boolean = false):Number
		{
			if (isInt)
			{
				return int(Math.random() * (n2 - n1 + 1)) + n1;
			}
			else
			{
				return Math.random() * (n2 - n1 + 1) + n1;
			}
		}
		public static function getLength(x1,y1,x2=null,y2=null):Number
		{
			if (x2 && y2)
			{
				return Math.sqrt(Math.pow(x1 - x2,2) + Math.pow(y1 - y2,2));
			}
			else
			{
				return Math.sqrt(x1 * x1 + y2 * y2);
			}
		}
		
		
		public static function reLocate(sourceCoordinate:DisplayObject,targetCoordinate:DisplayObject,point:Point):Point
		{
			var locInGlobal		= sourceCoordinate.localToGlobal(point);
			var locInTarget		= targetCoordinate.globalToLocal(locInGlobal);
			return locInTarget;			
		}
		
		public static function getCircumference(shapeArray:Array):Number
		{
			var totalLength = 0;
			for (var i=1; i<=shapeArray.length; i++)
			{
				var lastPoint = shapeArray[i - 1];
				var thisPoint=(i==shapeArray.length)?shapeArray[0]:shapeArray[i];
				totalLength += getLength(thisPoint.x,thisPoint.y,lastPoint.x,lastPoint.y);
			}
			return totalLength;
		}
		public static function getPointByLength(shapeArray:Array,lengthToPoint:Number):Object
		{
			//trace('----------');
			var theLength:Number=0;
			for (var i=1; i<=shapeArray.length; i++)
			{
				var lastPoint=shapeArray[i-1];
				var thisPoint=(i==shapeArray.length)?shapeArray[0]:shapeArray[i];
				//trace('('+lastPoint.x+','+lastPoint.y+')-('+thisPoint.x+','+thisPoint.y+')');
				var lengthOnThisLine=getLength(thisPoint.x,thisPoint.y,lastPoint.x,lastPoint.y);
				theLength+=lengthOnThisLine;
				var subtractedLength=theLength-lengthToPoint;
				if (subtractedLength>0)
				{
					break;
				}
			}
			var x = int(thisPoint.x-(thisPoint.x-lastPoint.x)*subtractedLength/lengthOnThisLine);
			var y = int(thisPoint.y-(thisPoint.y-lastPoint.y)*subtractedLength/lengthOnThisLine);
			return {x:x,y:y,index:i};
		}
	}
}