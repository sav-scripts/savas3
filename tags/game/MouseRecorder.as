package sav.game
{
	import flash.geom.Point;
	import flash.display.DisplayObjectContainer;
	
	public class MouseRecorder
	{
		private static var oldMousePosition		:Point = new Point(0,0);
		
		public static function updatePosition(pressedItem:DisplayObjectContainer):Point
		{
			var newMousePosition	= new Point(pressedItem.stage.mouseX , pressedItem.stage.mouseY);
			var dPosition			= newMousePosition.subtract(oldMousePosition);
			oldMousePosition		= newMousePosition;
			return dPosition;
		}		
	}
}