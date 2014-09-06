package sav.ui.utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import sav.game.MouseRecorder;
	
	public class DragableUI extends Sprite
	{
		
		public function DragableUI()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		public function setLimit(coordinateContainer:DisplayObjectContainer = null, limitBound:Rectangle = null, selfBound:Rectangle = null):void
		{
			_coordinateContainer = coordinateContainer;			
			_limitBound = limitBound;
			_selfBound = selfBound;
			
			if (!limitBound && coordinateContainer)
			{
				if (!_stage) throw new Error("stage reference not given");
				_stage.addEventListener(Event.RESIZE, stageResize);
				stageResize(null);
			}
			
			if (!_selfBound && coordinateContainer) _selfBound = this.getBounds(this);
		}
		
		private function stageResize(evt:Event):void
		{
			_limitBound = new Rectangle(0, 0, _stage.stageWidth, _stage.stageHeight);
		}
		
		private function addedToStage(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			_stage = stage;
		}
		
		private function removedFromStage(evt:Event):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
		}		
		
		public function activeDrag():void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownThis);	
		}
		
		public function disactiveDrag():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownThis);			
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);		
		}
		
		private function mouseDownThis(evt:MouseEvent):void
		{
			//if (evt.target != evt.currentTarget) return;
			
			stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
			
			MouseRecorder.updatePosition(parent);
		}
		
		private function stageMouseMove(evt:MouseEvent):void
		{
			var dp:Point = MouseRecorder.updatePosition(parent);
			x += dp.x;
			y += dp.y;
			
			if (!_coordinateContainer) return;
			
			var leftTopPosition:Point = localToGlobal(_selfBound.topLeft);
			var bottomRightPosition:Point = localToGlobal(_selfBound.bottomRight);
			
			
			var dx:Number, dy:Number;
			
			dx = _limitBound.left - leftTopPosition.x;
			if (dx > 0) x += dx;
			dx = _limitBound.right - bottomRightPosition.x;
			if (dx < 0) x += dx;
			
			dy = _limitBound.top - leftTopPosition.y;
			if (dy > 0) y += dy;
			dy = _limitBound.bottom - bottomRightPosition.y;
			if (dy < 0) y += dy;		
		}
		
		private function stageMouseUp(evt:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);	
		}
		
		public function destroy():void
		{
			disactiveDrag();	
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);		
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			_stage.removeEventListener(Event.RESIZE, stageResize);
			
			_stage = null;
			_coordinateContainer = null;
			_limitBound = null;
			_selfBound = null;
		}
		
		private var _stage:Stage;
		
		private var _coordinateContainer:DisplayObjectContainer;
		private var _limitBound:Rectangle;
		private var _selfBound:Rectangle;
	}
}