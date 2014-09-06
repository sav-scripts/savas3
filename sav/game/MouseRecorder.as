package sav.game
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	public class MouseRecorder
	{
		private static var oldMousePosition:Point = new Point(0, 0);
		private static var _draggingTarget:DisplayObjectContainer;
		private static var _stage:Stage;
		
		public static function init(stg:Stage):void
		{
			_stage = stg;
		}
		
		public static function updatePosition(pressedItem:DisplayObjectContainer):Point
		{
			var newMousePosition:Point	= new Point(pressedItem.stage.mouseX , pressedItem.stage.mouseY);
			var dPosition:Point			= newMousePosition.subtract(oldMousePosition);
			oldMousePosition		= newMousePosition;
			return dPosition;
		}
		
		/************************
		*       regist drag
		************************/
		private static var _registedDragDic:Dictionary = new Dictionary();
		private static var _triggerDic:Dictionary = new Dictionary();
		private static var _activeTrigger:InteractiveObject;
		
		//public static function simpleRegist(relatedObject:*, trigger:InteractiveObject, isSimple:Boolean = false, onMouseMoveFunc:Function = null, onMouseUpFunc:Function = null):void
		//{
			//registDrag(relatedObject, trigger, simpleMouseMove);
		//}
		//
		//private static function simpleMouseMove(target:Sprite, dx:Number, dy:Number):void
		//{
			//target.x += dx;
			//target.y += dy;
		//}
		
		public static function registDrag(relatedObject:*, trigger:InteractiveObject = null, isSimpleDrag:Boolean = true, onMouseMoveFunc:Function = null, onMouseUpFunc:Function = null, onMouseDownFunc:Function = null):void
		{
			if (_registedDragDic[relatedObject]) unregistDrag(relatedObject);
			
			if (trigger == null)
			{
				if (relatedObject is InteractiveObject)
					trigger = relatedObject
				else
					throw new Error("didn't assign trigger and relatedObject isn't InteractiveObject neither");
			}
			
			var obj:DragObject = new DragObject();
			obj.relatedObject = relatedObject;
			obj.trigger = trigger;
			obj.onMouseMoveFunc = onMouseMoveFunc;
			obj.onMouseUpFunc = onMouseUpFunc;
			obj.onMouseDownFunc = onMouseDownFunc;
			obj.isSimpleDrag = isSimpleDrag;
			_registedDragDic[relatedObject] = obj;
			
			var array:Array = _triggerDic[trigger];
			if (!array) array = [];
			array.push(relatedObject);
			_triggerDic[trigger] = array;
			
			trigger.addEventListener(MouseEvent.MOUSE_DOWN, dragMouseDown);
		}
		
		private static function dragMouseDown(evt:MouseEvent):void
		{
			_activeTrigger = InteractiveObject(evt.currentTarget);
			updatePosition(_stage);
			
			_stage.addEventListener(MouseEvent.MOUSE_UP, dragMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, dragMouseMove);
			
			var array:Array = _triggerDic[_activeTrigger];
			
			if (!array) return;
			
			for each(var relatedObj:* in array)
			{
				var dragObj:DragObject = _registedDragDic[relatedObj];
				if (dragObj.onMouseDownFunc != null) dragObj.onMouseDownFunc.call(null, relatedObj);
			}
		}
		
		private static function dragMouseUp(evt:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_UP, dragMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragMouseMove);
			
			var array:Array = _triggerDic[_activeTrigger];
			
			if (!array) return;
			
			for each(var relatedObj:* in array)
			{
				var dragObj:DragObject = _registedDragDic[relatedObj];
				if (dragObj.onMouseUpFunc != null) dragObj.onMouseUpFunc.call(null, relatedObj);
			}
			
			_activeTrigger = null;
		}
		
		private static function dragMouseMove(evt:MouseEvent):void
		{
			var point:Point = updatePosition(_stage);
			
			var array:Array = _triggerDic[_activeTrigger];
			
			if (!array) return;
			
			for each(var relatedObj:* in array)
			{
				var dragObj:DragObject = _registedDragDic[relatedObj];
				if (dragObj.isSimpleDrag)
				{
					dragObj.relatedObject.x += point.x;
					dragObj.relatedObject.y += point.y;					
					if (dragObj.onMouseMoveFunc != null) dragObj.onMouseMoveFunc.call(null);
				}
				else
				{
					if (dragObj.onMouseMoveFunc != null) dragObj.onMouseMoveFunc.call(null, relatedObj, point.x, point.y);
				}
			}
		}
		
		public static function unregistDrag(relatedObject:*):void
		{
			var obj:DragObject = _registedDragDic[relatedObject];
			if (!obj) return;
			
			delete _registedDragDic[relatedObject];
			
			var trigger:InteractiveObject = obj.trigger;
			
			var array:Array = _triggerDic[trigger];
			var index:int = array.indexOf(relatedObject);
			array.splice(index, 1);
			
			if (array.length == 0) 
			{
				if (_activeTrigger == trigger) _activeTrigger = null;
				trigger.removeEventListener(MouseEvent.MOUSE_DOWN, dragMouseDown);
				delete _triggerDic[trigger];
			}
		}
		
		/************************
		*      	quick drag
		************************/
		/*
		public static function startDrag(target:DisplayObjectContainer):void
		{
			if (_draggingTarget) throw new Error("already dragging on a target");
			
			_stage = target.stage;
			if (!_stage) throw new Error("dragging target not on display list");
			
			_draggingTarget = target;
			
			updatePosition(target);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
		}
		
		private static function stageMouseMove(evt:MouseEvent):void
		{
			var point:Point = updatePosition(_draggingTarget);
			_draggingTarget.x += point.x;
			_draggingTarget.y += point.y;
		}
		
		private static function stageMouseUp(evt:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
			
			_draggingTarget = null;
			//_stage = null;
		}
		*/
	}
}
import flash.display.InteractiveObject;

class DragObject
{
	public var relatedObject:*;
	public var trigger:InteractiveObject;
	public var onMouseMoveFunc:Function;
	public var onMouseUpFunc:Function;
	public var onMouseDownFunc:Function;
	public var isSimpleDrag:Boolean = false;
}