package sav.utils 
{
	/**
	 * ...
	 * @author sav
	 */
	public class MathUtils 
	{
		///取得隨機正負值
		public static function throwCoin():int
		{
			return (Math.random()<.5)?-1:1;
		}
		
		///取得一個在所給予引數的正副值之間的亂數
		public static function randomBetween(n1:Number, n2:Number, isInt:Boolean = false):Number
		{
			if (isInt)
				return int(Math.random() * (n2 - n1 + 1)) + n1;
			else
				return Math.random() * (n2 - n1 + 1) + n1;
		}
		
		public static function getLength(x1:Number, y1:Number, x2:Number = Number.NaN, y2:Number = Number.NaN):Number
		{
			if (isNaN(x2) || isNaN(y2))
				return Math.sqrt(x1 * x1 + y2 * y2);
			else
				return Math.sqrt(Math.pow(x1 - x2,2) + Math.pow(y1 - y2,2));
		}
		
		/**
		 * 取得一段介於 0 ~ 1 的震盪值, 這個值在 length 上反覆, 從 0 ~ circleGap/2 ~ circleGap 的返回值為 0 ~ 1 ~ 0
		 * 
		 * @param	length	
		 * @param	circleGap
		 * @return
		 */
		public static function getSwingValue(length:Number, circleGap:Number):Number
		{
			var gap:Number = circleGap / 2;
			var v:Number = length % gap;
			var v2:Number = length % circleGap;
			
			if (v2 >= gap)
				return (gap - v) / gap;
			else
				return v / gap;
		}
		
	}

}