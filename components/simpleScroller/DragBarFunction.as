package sav.components.simpleScroller 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author sav
	 */
	
	 [Event(name = "change", type = "flash.events.Event")]
	public class DragBarFunction extends EventDispatcher
	{
		public function DragBarFunction(updateWhenDragging:Boolean = false):void
		{
			this.updateWhenDragging = updateWhenDragging;
		}
		
		public function setValueRange(min:Number, max:Number, valueGap:Number = 0):void
		{
			_minValue = min;
			_maxValue = max;
			_valueGap = valueGap;
			_valueRange = _maxValue - _minValue;
			
			if (_valueGap < 0) throw new Error("illegal value gap : " + _valueGap);
			if (_valueGap == 0) return;
			if (((_maxValue - _minValue) % _valueGap) != 0) throw new Error("value gap not fit with min and max value"); 
		}
		
		public function bindWith(dragBar:Sprite, minX:Number, maxX:Number):void
		{
			unBind();
			
			_dragBar = dragBar;
			_minX = minX;
			_maxX = maxX;
			_xRange = _maxX - _minX;
			
			_dragBar.addEventListener(MouseEvent.MOUSE_DOWN, dragBar_mouseDown);
			
			_oldValue = value;
		}
		
		public function unBind():void
		{
			if (_dragBar)
			{
				_dragBar.removeEventListener(MouseEvent.MOUSE_DOWN, dragBar_mouseDown);
				removeStageListeners();
				_dragBar = null;
			}
		}
		
		/************************
		*    dragBar listeners
		************************/
		private function dragBar_mouseDown(evt:MouseEvent):void
		{
			_lastMouseX = _dragBar.stage.mouseX;
			
			_dragBar.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			_dragBar.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		private function stage_mouseMove(evt:MouseEvent):void
		{
			var oldMouseX:Number = _lastMouseX;
			_lastMouseX = _dragBar.stage.mouseX;
			var dx:Number = _lastMouseX - oldMouseX;
			
			_dragBar.x += dx;
			if (_dragBar.x < _minX) _dragBar.x = _minX;
			if (_dragBar.x > _maxX) _dragBar.x = _maxX;
			
			
			if (updateWhenDragging == true) updateValue();
		}
		
		private function stage_mouseUp(evt:MouseEvent):void
		{
			removeStageListeners();
			
			if (_valueGap != 0)
			{
				var xGap:Number = _xRange * (_valueGap / (_maxValue - _minValue));
				
				
				var dx:Number = _dragBar.x - _minX;
				var exceedX:Number = dx % xGap;
				var i:int = Math.round(exceedX / xGap);
				var tx:Number = dx - exceedX + i * xGap;
				_dragBar.x = tx + _minX;
			}
			
			if (updateWhenDragging == false) updateValue();
		}
		
		private function updateValue():void
		{
			if(_oldValue != value)
			{
				_oldValue = value;
				
				var newEvent:Event = new Event(Event.CHANGE);
				dispatchEvent(newEvent);
			}
		}
		
		private function removeStageListeners():void
		{
			_dragBar.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			_dragBar.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		/************************
		*         params
		************************/
		public var updateWhenDragging:Boolean = false;
		
		private var _dragBar:Sprite;
		private var _minX:Number;
		private var _maxX:Number;
		private var _xRange:Number;
		
		private var _minValue:Number = 0;
		private var _maxValue:Number = 100;
		private var _valueGap:Number = 1;
		private var _valueRange:Number = 100;
		
		private var _lastMouseX:Number = 0;
		
		private var _oldValue:Number;
		
		public function get value():Number
		{
			if (_valueGap == 0) 
			{
				return ((_dragBar.x-_minX) / _xRange) * _valueRange + _minValue;
			}
			else
			{
				var xGap:Number = _xRange * (_valueGap / _valueRange);
				var dx:Number = _dragBar.x - _minX;
				var i:int = Math.round(dx / xGap);
				
				return _valueGap * i + _minValue;
			}
		}
		
		public function set value(v:Number):void
		{
			//if (v < _minValue || v > _maxValue) throw new Error("illegal value : " + v);
			if (v < _minValue) v = _minValue;
			if (v > _maxValue) v = _maxValue;
			
			_dragBar.x = _minX + ((v - _minValue) / _valueRange) * _xRange;
			_oldValue = v;
		}
	}
}