package sav.components.value_bar
{
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import fl.motion.Color;
	import sav.gp.GraphicDrawer;
	
	public class ValueBar extends Sprite
	{	
		public function ValueBar(w:Number = 200 , h:Number = 6 , minV:Number = 0 , maxV:Number = 100):void
		{
			_barWidth			= w;
			_barHeight			= h;
			_minValue			= minV;
			_maxValue			= maxV;
			valueColor			= 0xffea33;
			
			init();
		}
		
		public function init():void
		{
			_valueRange = _barWidth - _barHeight;
			
			_baseShape = new Shape();
			_valueShape = new Shape();
			addChild(_baseShape);
			addChild(_valueShape);
			
			_baseShape.graphics.beginFill(_baseColor);
			_baseShape.graphics.drawRoundRect(-1,-1,_barWidth+2,_barHeight+2,_barHeight+2);
			
			_value				= _maxValue;
			currentValue		= _maxValue;
		}
		
		public function set value(v:Number):void
		{
			_value	= v;
			if (_value > _maxValue) _value = _maxValue;
			if (_value < _minValue) _value = _minValue;
			if (currentValue != _value) startValueChange();
		}
		
		public function get value():Number{ return _value; }
		
		private function startValueChange():void
		{
			if(this.hasEventListener(Event.ENTER_FRAME) == false)
			{
				this.addEventListener(Event.ENTER_FRAME , changeValueHandler);
			}
		}
		
		private function changeValueHandler(evt:Event):void
		{
			if (currentValue != value)
			{
				var dValue:Number			= (value - currentValue)/Math.abs(value - currentValue) * _unitValue;
				if (_unitValue >= Math.abs(value - currentValue))
				{
					currentValue = value;
				}
				else
				{
					currentValue = currentValue + dValue; 
				}

			}
			else
			{
				this.removeEventListener(Event.ENTER_FRAME , changeValueHandler);
				dispatchEvent(new Event('valueUpdated'));
			}
			dispatchEvent(new Event('valueChanged'));
		}
		
		public function setValue(v:Number):void
		{
			currentValue = v;
			_value = v;
		}
		
		public function set currentValue(v:Number):void
		{
			_currentValue			= v;
			var valueWidth:Number			= int(_valueRange * (_currentValue - _minValue) / (_maxValue - _minValue));
			var rect:Rectangle				= new Rectangle(0,0,valueWidth+_barHeight,_barHeight);
			
			_valueShape.graphics.clear();
			_valueShape.graphics.beginFill(_valueColor);
			_valueShape.graphics.drawRoundRect(rect.x,rect.y,rect.width,rect.height,_barHeight);
			_valueShape.graphics.beginFill(_valueColorLight);
			
			rect.inflate(-1,-1);
			rect.height = rect.height / 2;
			
			//MyGraphics.drawRoundRect2(_valueShape , rect.x , rect.y , rect.width , rect.height , _barHeight-1 , _barHeight -1 , 0 , 0);
			//_valueShape.graphics.drawRoundRect(rect.x, rect.y, rect.width, rect.width, _barHeight-1, _barHeight-1
			GraphicDrawer.drawRoundRectComplex(_valueShape.graphics, rect, _barHeight - 1, _barHeight - 1, 0, 0);
			
		}
		
		/************************
		*         params
		************************/
		public function get currentValue():Number{ return _currentValue; }
		
		public function set valueColor(v:Number):void
		{
			_valueColor			= v;
			_valueColorLight	= Color.interpolateColor(_valueColor,0xffffff,0.5)			
		}
		
		public function get valueColor():Number { return _valueColor; }
		
		public function set min(v:Number):void { _minValue = v; }
		public function set max(v:Number):void { _maxValue = v; }
		public function get min():Number { return _minValue; }
		public function get max():Number { return _maxValue; }
		
		
		private var _baseColor			:Number = 0x222222;
		private var _valueColor			:Number;
		private var _valueColorLight	:Number;
		
		private var _baseShape			:Shape;
		private var _valueShape			:Shape;
		private var _unitValue			:Number = 1;
		
		private var _barWidth			:Number;
		private var _barHeight			:Number;
		private var _valueRange			:Number;
		private var _value				:Number;
		private var _currentValue		:Number;
		private var _minValue			:Number;
		private var _maxValue			:Number;
		
	}
}