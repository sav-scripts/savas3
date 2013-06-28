package sav.game.map.events
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import sav.game.map.prototype.MapNode;
	import sav.game.map.prototype.Path;
	public class MapEvent extends Event
	{
		public function MapEvent(type:String, bubble:Boolean = false, cancelable:Boolean = false):void
		{
			super(type, bubble, cancelable);
		}
		
		/************************
		*         events
		************************/
		public static const NODE_CLICK:String = 'nodeClick';
		public static const NODE_MOUSE_OVER:String = 'nodeMouseOver';
		public static const NODE_MOUSE_OUT:String = 'nodeMouseOut';
		public static const PATH_CLICK:String = 'pathClick';
		
		/************************
		*         params
		************************/
		public var node:MapNode;
		public var clip:Sprite; 
		public var path:Path;
	}
}