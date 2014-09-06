package sav.events
{
	import flash.events.Event;
	
	public class IconSliderEvent extends Event
	{	
		public static const MOUSE_OVER_SLIDER:String		= 'mouseOverSlider';
		public static const MOUSE_OUT_SLIDER:String			= 'mouseOutSlider';
		
		public function IconSliderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			if (type == null) type = '';
			super(type, bubbles, cancelable);
		}
	}
}