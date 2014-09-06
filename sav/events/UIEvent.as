package sav.events
{
	import flash.events.Event;
	
	public class UIEvent extends Event
	{
		public var data:Object;
		
		public static const SHOW_START:String = 'showStart';
		public static const HIDE_START:String = 'hideStart';
		public static const SHOW_COMPLETE:String = 'showComplete';
		public static const HIDE_COMPLETE:String = 'hideComplete';
		
		public static const BLOCK_CLICK:String = 'blockClick';
		public static const BLOCK_MOUSE_OVER:String = 'blockMouseOver';
		public static const BLOCK_MOUSE_OUT:String = 'blockMouseOut';	
		
		public static const BLOCK_MOUSE_DOWN:String = 'blockMouseDown';	
		public static const BLOCK_MOUSE_UP:String = 'blockMouseUp';	
		
		public function UIEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false):void
		{
			this.data = (data == null) ? new Object() : data;
			if (type == null) type = '';
			super(type, bubbles, cancelable);
		}
	}
}