package sav.events 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author sav
	 */
	public class TimeCounterEvent extends Event
	{
		public static const TIME_OUT:String = "timeOut";
		public static const TIME_JUMP:String = "timeJump";
		
		public function TimeCounterEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			if (type == null) type = '';
			super(type, bubbles, cancelable);
		}
	}

}