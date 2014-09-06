/******************************************************************************************************************
	This is a stand-alone Class for time counting usage
	
	To use this , build it with _timerDelay in constructor (which is 1000 , one sec , in default)
	
		To start time count , call <start> function , if you provide ec(endCount) in this function , TimeCounter will subtract time
	by thie endCount , and dispatch 'timeOut' event when endCount is at 0 value.
	
		For get how long TimeCounter is started , check <totalCount> for it .
	
*******************************************************************************************************************/
package sav.utils
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import sav.events.TimeCounterEvent;
	
	[Event(name = "timeOut", type = "sav.events.TimeCounterEvent")]
	[Event(name = "timeJump", type = "sav.events.TimeCounterEvent")]
	public class TimeCounter extends EventDispatcher
	{		
		public function TimeCounter(timerDelay:int = 1000)
		{
			_timerDelay		= timerDelay;
			_timer			= new Timer(_timerDelay);
			_timer.addEventListener(TimerEvent.TIMER , timerJump);
		}
		
		public function reset(startCount:int = 0, timeLimited:Boolean = false, endCount:int = 0):void
		{
			_startCount = startCount;
			_timeIsLimited = timeLimited;
			
			if (_timeIsLimited && startCount == endCount) throw new Error("start count can't be same with end count");
			
			_timer.reset();
			
			_endCount = endCount;	
			_currentCount = _startCount;
			
			if (_timeIsLimited)
			{
				_dCount = (_startCount > _endCount) ? -1 : 1;
			}
			else
			{
				_dCount = 1;
			}
		}
		
		public function start():void
		{
			_timer.start();
		}
		
		public function pause():void
		{
			_timer.stop();
		}
		
		private function timerJump(evt:TimerEvent):void
		{
			_currentCount += _dCount;
			dispatchEvent(new TimeCounterEvent(TimeCounterEvent.TIME_JUMP));
			
			if (_timeIsLimited && _currentCount == _endCount)
			{
				_timer.stop();
				dispatchEvent(new TimeCounterEvent(TimeCounterEvent.TIME_OUT));
			}
		}
		
		public function destroy():void
		{
			if (_timer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER , timerJump);
				_timer = null;
			}
		}
		
		/****************
		 * 	  params
		 * *************/
		private var _timerDelay			:uint = 1000;
		private var _timer				:Timer;
		private var _startCount			:int = 0;
		private var _endCount			:int = 0;
		private var _currentCount		:int;
		private var _dCount				:int;
		
		private var _timeIsLimited:Boolean;
		
		public function get startCount():int { return _startCount; }
		public function get endCount():int { return _endCount; }	
		public function get currentCount():int { return _currentCount; }
	}
}