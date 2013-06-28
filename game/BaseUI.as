/******************************************************************************************************************
	This is a basic Class for UI , it define some method provide inherbited UIs Fade in fade out effects .
	
	For use it , write a Class extend it .
	
		When a building a Class extends this , you should asign a stageRef for them , so the <load> method knows where 
	it should be added at .
	
		If the UI's target fade in position not (0 , 0) , you should declare the position (targetX , targetY) you hope it is in 
	contructor of child Class ,	or change it after it is build . 
	
		(startX , startY) is similar , but decide where the fade in start (or where fade out end at)
		
		there is startAlpha and targetAlpha too , consider them work same way as x y things
		
		time is how long the fade in / out effect will take with
	
*******************************************************************************************************************/

package sav.game
{
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import caurina.transitions.Tweener;
	import flash.display.Stage;
	import flash.events.Event;

	public class BaseUI extends MovieClip
	{
		public static const REMOVED		:String = "unloaded";
		public static const LOADED		:String = "loaded";

		public var _startX:int			= 0;
		public var _startY:int			= 400;
		public var _targetX:int			= 0;
		public var _targetY:int			= 0;
		public var _startAlpha:Number	= 0;
		public var _targetAlpha:Number	= 1;
		
		public var time			:Number = 0.7;
		public var stageRef		:DisplayObjectContainer;

		public function BaseUI()
		{
			x = _startX;
			y = _startY;
		}
		
		public function set targetX(value:int):void
		{
			_targetX = value;
			if(parent) x = _targetX;
		}
		
		public function set targetY(value:int):void
		{
			_targetY = value;
			if(parent) y = _targetY;
		}
		
		public function get targetX():int
		{
			return _targetX;
		}
		
		public function get targetY():int
		{
			return _targetY;
		}
		
		public function set startX(value:int):void
		{
			_startX = value;
			x = _startX;
		}
		
		public function set startY(value:int):void
		{
			_startY = value;
			y = _startY;
		}
		
		public function set startAlpha(value:Number):void
		{
			_startAlpha = value;
			alpha = _startAlpha;
		}
		
		public function set targetAlpha(value:Number):void
		{
			_targetAlpha = value;			
		}

		public function unload(loadMe:BaseUI = null):void
		{
			Tweener.addTween(this, { alpha: _startAlpha , x:_startX , y:_startY , time:time , onComplete:remove } );
		}

		public function remove():void
		{
			if (this.parent)
			{
				dispatchEvent(new Event(REMOVED));
			
				stageRef.removeChild(this);				
			}
		}

		public function load():void
		{
			stageRef.addChild(this);
			x = _startX;
			y = _startY;
			Tweener.addTween(this, { alpha: _targetAlpha , x:_targetX , y:_targetY, time:time , onComplete:loaded } );
		}
		
		public function loaded():void
		{
			dispatchEvent(new Event(LOADED));
		}

	}

}