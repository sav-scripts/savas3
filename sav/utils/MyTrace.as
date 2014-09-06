package sav.utils
{
	import flash.utils.getTimer;
	public class MyTrace
	{		
		public static function recoardStart(recoardName:String):void
		{
			if (_timerRecoardDic[recoardName])
				recoardEnd(recoardName);
			else
				_timerRecoardDic[recoardName] = getTimer();
		}
		
		public static function recoardEnd(recoardName:String):void
		{
			if (!_timerRecoardDic[recoardName]) throw new Error("Can't find start recoard for '" + recoardName + "'");
			var costTime:Number = (getTimer() - _timerRecoardDic[recoardName]) / 1000;
			
			trace(recoardName + " : [" + costTime + "] sec");
			delete _timerRecoardDic[recoardName];
		}
		
		
		
		/**********************
		 *       params
		 * *******************/
		public static var _timerRecoardDic:Object = { };
	}
}