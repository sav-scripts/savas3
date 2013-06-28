package sav.gp.simple_canvas.events
{
	import flash.events.Event;
	public class SimpleCanvasEvent extends Event
	{		
		public function SimpleCanvasEvent(type:String)
		{
			super(type);
		}
		
		/**
		 * 
         * @eventType historyAdded
		 */
		public static const HISTORY_ADDED:String = 'historyAdded';		
		
		public static const REPLAY_COMPLETE:String = 'replayComplete';
		
		public static const UNDO_CHANGED:String = 'undoChanged';
		
		public static const DRAW_START:String = 'drawStart';
		
		public static const DRAW_END:String = 'drawEnd';
	}
}