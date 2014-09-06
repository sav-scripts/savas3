package sav.events
{
	import flash.events.Event;
	public class DEvent extends Event
	{
		public var data:Object;
		
		public function DEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false):void
		{
			data = { };
			if (type == null) type = '';
			super(type, bubbles, cancelable);
		}
	}
}