package sav.events
{
	import flash.events.Event;
	
	public class SwarmerEvent extends Event
	{
		public static const START_RECOVER			:String = 'startRecover';
		public static const COMPLETE				:String = 'complete';
		
		public function SwarmerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			if (type == null) type = '';
			super(type, bubbles, cancelable);
		}
	}
}