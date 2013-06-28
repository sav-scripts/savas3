package sav.utils
{
	import flash.geom.Point;
	import flash.display.DisplayObject;
	
	public class MyMath
	{
		//取得隨機正負值
		public static function throwCoin():int
		{
			var coin:int = (Math.random()<.5)?-1:1;
			return coin;
		}
		//取得一個在所給予引數的正副值之間的亂數
		public static function randomBetween(n1:Number,n2:Number,isInt:Boolean = false):Number
		{
			if (isInt)
			{
				return int(Math.random() * (n2 - n1)) + n1;
			}
			else
			{
				return Math.random() * (n2 - n1) + n1;
			}
		}
		public static function getLength(x1:Number, y1:Number, x2:Number = 0, y2:Number = 0):Number
		{
			return Math.sqrt(Math.pow(x1 - x2,2) + Math.pow(y1 - y2,2));
		}
		
		
		public static function reLocate(sourceCoordinate:DisplayObject,targetCoordinate:DisplayObject,point:Point):Point
		{
			var locInGlobal:Point		= sourceCoordinate.localToGlobal(point);
			var locInTarget:Point		= targetCoordinate.globalToLocal(locInGlobal);
			return locInTarget;			
		}
		
		public static function getCircumference(shapeArray:Array):Number
		{
			var totalLength:Number = 0;
			for (var i:int=1; i<=shapeArray.length; i++)
			{
				var lastPoint:Point = shapeArray[i - 1];
				var thisPoint:Point=(i==shapeArray.length)?shapeArray[0]:shapeArray[i];
				totalLength += getLength(thisPoint.x,thisPoint.y,lastPoint.x,lastPoint.y);
			}
			return totalLength;
		}
		public static function getPointByLength(shapeArray:Array,lengthToPoint:Number):Object
		{
			//trace('----------');
			var theLength:Number=0;
			for (var i:int=1; i<=shapeArray.length; i++)
			{
				var lastPoint:Point=shapeArray[i-1];
				var thisPoint:Point=(i==shapeArray.length)?shapeArray[0]:shapeArray[i];
				//trace('('+lastPoint.x+','+lastPoint.y+')-('+thisPoint.x+','+thisPoint.y+')');
				var lengthOnThisLine:Number = getLength(thisPoint.x, thisPoint.y, lastPoint.x, lastPoint.y);
				theLength+=lengthOnThisLine;
				var subtractedLength:Number = theLength - lengthToPoint;
				if (subtractedLength>0)
				{
					break;
				}
			}
			var x:int = int(thisPoint.x-(thisPoint.x-lastPoint.x)*subtractedLength/lengthOnThisLine);
			var y:int = int(thisPoint.y-(thisPoint.y-lastPoint.y)*subtractedLength/lengthOnThisLine);
			return {x:x,y:y,index:i};
		}
	}
}