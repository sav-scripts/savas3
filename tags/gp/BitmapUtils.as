package sav.gp
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	public class BitmapUtils
	{
		public static function resize(oldBitmapData:BitmapData , newWidth:uint , newHeight:uint , smooth:Boolean = true):BitmapData
		{
			var newBitmapData			= new BitmapData(newWidth , newHeight , true , 0xffffffff);
			var sx						= newWidth / oldBitmapData.width;
			var sy						= newHeight / oldBitmapData.height;
			var matrix					= new Matrix(sx , 0 , 0 , sy);
			newBitmapData.draw(oldBitmapData , matrix , null , null , null , smooth);
			
			return newBitmapData;
		}		
	}
}