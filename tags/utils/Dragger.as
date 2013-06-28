package sav.utils
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import sav.game.MouseRecorder;
	public class Dragger
	{
		private static var registedObjects:Dictionary = new Dictionary();
		private static var hitAreaDic:Dictionary = new Dictionary();
		private static var _draggingTarget:InteractiveObject;		
		
		/**
		 * 
		 * @param	target			InteractiveObject	Dragging target
		 * @param	hitArea			InteractiveObject	HitArea, set to null for use target itself
		 * @param	numDrags		int					how many timers for drag able, set to -1 for unlimited times
		 * @param	onMouseMove		Function			execute this function when dragging
		 * @param	useInt			Boolean				use int on target position
		 * @param	movingLimit		Rectangle			a bound for dragging limie
		 */
		public static function add(
			target:InteractiveObject, 
			hitArea:InteractiveObject = null, 
			numDrags:int = -1, 
			onMouseMove:Function = null, 
			useInt:Boolean = true, 
			movingLimit:Rectangle = null):void
		{
			if (numDrags == 0) numDrags = -1;
			if (hitArea == null) hitArea = target;
			
			if (hitAreaDic[hitArea])
			{
				trace("[Dragger] Warning : hitArea " + hitArea + " already registed");
				return;
			}
			
			if (registedObjects[target]) remove(target);
			
			var obj:Object = { numDrags:numDrags, target:target, hitArea:hitArea, position:new Point(), onMouseMove:onMouseMove, useInt:useInt, movingLimit:movingLimit };
			
			registedObjects[target] = obj;
			hitAreaDic[hitArea] = obj;
			
			hitArea.addEventListener(MouseEvent.MOUSE_DOWN, objectMouseDown);		
		}		
		
		/**
		 * 
		 * @param	target		InteractiveObject		Target object for remove
		 */
		public static function remove(target:InteractiveObject):void
		{
			var obj:Object = registedObjects[target];
			 
			if (obj)
			{
				var hitArea:InteractiveObject = obj.hitArea;
				
				hitArea.removeEventListener(MouseEvent.MOUSE_DOWN, objectMouseDown);			
				target.stage.removeEventListener(MouseEvent.MOUSE_UP, objectMouseUp);
				target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, objectMouseMove);
				
				delete hitAreaDic[hitArea];
				delete registedObjects[target];
			}
		}
		
		private static function objectMouseDown(evt:MouseEvent):void
		{
			var hitArea:InteractiveObject = InteractiveObject(evt.currentTarget);
			var obj:Object = hitAreaDic[hitArea];
			var target:InteractiveObject = obj.target;
			obj.position = new Point(target.parent.mouseX, target.parent.mouseY);			
			
			_draggingTarget = target;
			
			target.stage.addEventListener(MouseEvent.MOUSE_UP, objectMouseUp);
			target.stage.addEventListener(MouseEvent.MOUSE_MOVE, objectMouseMove);
		}
		
		private static function objectMouseUp(evt:MouseEvent):void
		{
			var target:InteractiveObject = _draggingTarget;
			var obj:Object = registedObjects[target];
			
			target.stage.removeEventListener(MouseEvent.MOUSE_UP, objectMouseUp);
			target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, objectMouseMove);
			
			if (obj.numDrags == -1) return;
			obj.numDrags --;
			if (obj.numDrags == 0) remove(target);
		}
		
		private static function objectMouseMove(evt:MouseEvent):void
		{
			var target:InteractiveObject = _draggingTarget;
			var obj:Object = registedObjects[target];
			
			var newPosition:Point = new Point(target.parent.mouseX, target.parent.mouseY);
			var dPosition:Point = newPosition.subtract(obj.position);
			target.x += dPosition.x;
			target.y += dPosition.y;
			
			if (obj.useInt)
			{
				target.x = int(target.x);
				target.y = int(target.y);
			}			
			
			obj.position = newPosition;
			
			if (obj.movingLimit)
			{
				var rect:Rectangle = obj.movingLimit;
				if (target.x < rect.left) target.x = rect.left;
				if (target.y < rect.top) target.y = rect.top;
				if (target.x > rect.right) target.x = rect.right;
				if (target.y > rect.bottom) target.y = rect.bottom;
			}
			
			if (obj.onMouseMove != null) obj.onMouseMove.apply(null);
		}
	}
}