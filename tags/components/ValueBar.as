package sav.components
{
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import fl.motion.Color;
	
	import oldstaff.MyGraphics;
	
	public class ValueBar extends Sprite
	{
		private var baseColor			:Number = 0x222222;
		private var _valueColor			:Number;
		private var _valueColorLight	:Number;
		
		public var baseShape			:Shape;
		public var valueShape			:Shape;
		public var unitValue			:Number = 1;
		
		private var barWidth			:Number;
		private var barHeight			:Number;
		private var valueRange			:Number;
		private var _value				:Number;
		private var _currentValue		:Number;
		private var minValue			:Number;
		private var maxValue			:Number;
		
		public function ValueBar(w:Number = 200 , h:Number = 6 , minV:Number = 0 , maxV:Number = 100):void
		{
			barWidth			= w;
			barHeight			= h;
			minValue			= minV;
			maxValue			= maxV;
			valueColor			= 0xffea33;
			
			init();
		}
		
		public function init():void
		{
			valueRange			= barWidth - barHeight;
			
			baseShape			= new Shape();
			valueShape			= new Shape();
			addChild(baseShape);
			addChild(valueShape);
			
			baseShape.graphics.beginFill(baseColor);
			baseShape.graphics.drawRoundRect(-1,-1,barWidth+2,barHeight+2,barHeight+2);
			
			_value				= maxValue;
			currentValue		= maxValue;
		}
		
		public function set value(v:Number):void
		{
			_value	= v;
			if (_value > maxValue) _value = maxValue;
			if (_value < minValue) _value = minValue;
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
				var dValue			= (value - currentValue)/Math.abs(value - currentValue) * unitValue;
				if (unitValue >= Math.abs(value - currentValue))
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
			var valueWidth			= int(valueRange * (_currentValue - minValue) / (maxValue - minValue));
			var rect				= new Rectangle(0,0,valueWidth+barHeight,barHeight);
			
			valueShape.graphics.clear();
			valueShape.graphics.beginFill(_valueColor);
			valueShape.graphics.drawRoundRect(rect.x,rect.y,rect.width,rect.height,barHeight);
			valueShape.graphics.beginFill(_valueColorLight);
			
			rect.inflate(-1,-1);
			rect.height = rect.height / 2;
			MyGraphics.drawRoundRect2(valueShape , rect.x , rect.y , rect.width , rect.height , barHeight-1 , barHeight -1 , 0 , 0);
			
		}
		
		public function get currentValue():Number{ return _currentValue; }
		
		public function set valueColor(v:Number):void
		{
			_valueColor			= v;
			_valueColorLight	= Color.interpolateColor(_valueColor,0xffffff,0.5)			
		}
		
		public function get valueColor():Number { return _valueColor; }
		
		public function set min(v:Number):void { minValue = v; }
		public function set max(v:Number):void { maxValue = v; }
		public function get min():Number { return minValue; }
		public function get max():Number { return maxValue; }
		
	}
}