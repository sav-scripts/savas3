package sav.components.dialog_v2
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import sav.events.DEvent;
	import sav.utils.ColorUtils;
	public class ButtonGroup extends Sprite 
	
	{
		public function ButtonGroup(setting:DialogSetting)
		{
			_setting = setting;
		}
		
		public function build(dataArray:Array, contentBound:Rectangle):void
		{
			while (numChildren) removeChildAt(0);
			
			_maxButtonWidth = 0;
			var obj:Object , text:String, func:Function, funcParams:Array, closeDialog:Boolean, tf:TextField, align:String;
			
			for each(obj in dataArray)
			{
				text = obj.text;
				tf = DialogButton.getTextField(text, _setting.buttonTextSize, _setting.buttonLetterSpacing);
				_maxButtonWidth = Math.max(_maxButtonWidth, tf.width);
			}
			
			if (_setting.buttonAlign == ButtonAlign.HORIZONTAL)
			{
				_maxButtonWidth = Math.max(_maxButtonWidth, int(contentBound.width / dataArray.length));
			}
			else if (_setting.buttonAlign == ButtonAlign.VERTICAL)
			{
				_maxButtonWidth = Math.max(_maxButtonWidth, int(contentBound.width));
			}
			else
			{
				throw new Error("Illegal buttonAlign : " + _setting.buttonAlign);
			}
			
			_buttonArray = [];
			
			_maxButtonWidth += _setting.buttonInflateWidth * 2;
			//_maxButtonWidth = _maxButtonWidth;
			
			var i:uint, l:uint = dataArray.length, startX:Number = 0, startY:Number = 0;
			for (i = 0; i < l;i++ )
			{	
				obj = dataArray[i];
				text = obj.text;
				func = obj.func;
				funcParams = obj.funcParams;
				closeDialog = obj.closeDialog;
				
				var button:DialogButton = new DialogButton(text, func, funcParams, closeDialog, _maxButtonWidth, _setting);
				
					
				if (_setting.buttonAlign == ButtonAlign.HORIZONTAL)
				{
					button.x = startX;
					button.y = startY;
					startX += _maxButtonWidth + 3;
				}
				else
				{
					button.x = startX;
					button.y = startY;
					startY += _setting.buttonHeight;
				}
				
				addChild(button);
				
				button.addEventListener(MouseEvent.CLICK, buttonClick);
				
				_buttonArray.push(button);
			}
		}
		
		private function buttonClick(evt:MouseEvent):void
		{
			var button:DialogButton = DialogButton(evt.currentTarget);
			if(button._execFunc != null) button._execFunc.apply(null, button._execFuncParams);
			
			var dEvent:DEvent = new DEvent(BUTTON_CLICK);
			dEvent.data.button = button;
			dispatchEvent(dEvent);
		}
		
		internal function drawBasement():void
		{
			var i:int, l:int = _buttonArray.length;
			var button:DialogButton;
			
			if (_setting.buttonAlign == ButtonAlign.HORIZONTAL)
			{
				var rect:Rectangle = this.getBounds(this);
				rect.y = 0;
				rect.height = _setting.buttonHeight;
				_bound = rect.clone();
				
			
				
				for (i = 1; i < l; i++)
				{
					button = _buttonArray[i];
					drawDivLine_v(button.x);
				}
			}
			else
			{
				//_maxButtonWidth
				_bound = new Rectangle(0, 0, _maxButtonWidth, _setting.buttonHeight * _buttonArray.length);
				
				/*
				for (i = 1; i < l; i++)
				{
					button = _buttonArray[i];
					drawDivLine_h(button.y);
				}
				*/
			}
			
			
			
			/*
			if (l > 0)
			{
				drawDivLine_v(button.x + _maxButtonWidth + 1);
			}
			*/
		}
		
		private function drawDivLine_v(tx:Number):void
		{
			var g:Graphics = this.graphics;
			
			//g.beginFill(0xff0000);
			//g.drawRect(tx - 2, _bound.y, 1, _bound.height);
			
			var rect:Rectangle = new Rectangle(tx - 2, _bound.y, 1, _bound.height);
			
			var darkColor:int = ColorUtils.brighten(_setting.baseColor, -.1);
			var lightColor:int = ColorUtils.brighten(_setting.baseColor, .06);
			
			var fillType:String = GradientType.LINEAR;
			var darkColors:Array = [darkColor, darkColor, darkColor, darkColor];
			var lightColors:Array = [lightColor, lightColor, lightColor, lightColor];
			var alphas:Array = [0, 1, 1, 0];
			var ratios:Array = [0x00, 0x44, 0xbb, 0xff];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(rect.width, rect.height, Math.PI / 2);
			
			g.beginGradientFill(fillType, lightColors, alphas, ratios, matr);			
			g.drawRect(rect.x - 1, rect.y, rect.width, rect.height);
			g.drawRect(rect.x + 1, rect.y, rect.width, rect.height);
			
			g.beginGradientFill(fillType, darkColors, alphas, ratios, matr);		
			g.drawRect(rect.x, rect.y, rect.width, rect.height);		
			
			g.endFill();
		}
		
		private function drawDivLine_h(ty:Number):void
		{
			var g:Graphics = this.graphics;
			
			//var rect:Rectangle = new Rectangle(_bound.x, ty - 2, _bound.width, 1);
			var rect:Rectangle = new Rectangle(_bound.x, ty, _bound.width, 1);
			
			var darkColor:int = ColorUtils.brighten(_setting.baseColor, -.1);
			var lightColor:int = ColorUtils.brighten(_setting.baseColor, .06);
			
			/*
			var fillType:String = GradientType.LINEAR;
			var darkColors:Array = [darkColor, darkColor, darkColor, darkColor];
			var lightColors:Array = [lightColor, lightColor, lightColor, lightColor];
			var alphas:Array = [0, 1, 1, 0];
			var ratios:Array = [0x00, 0x11, 0xee, 0xff];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(rect.width, rect.height, 0);
			
			g.beginGradientFill(fillType, lightColors, alphas, ratios, matr);			
			g.drawRect(rect.x, rect.y-1, rect.width, rect.height);
			g.drawRect(rect.x, rect.y+1, rect.width, rect.height);
			
			g.beginGradientFill(fillType, darkColors, alphas, ratios, matr);		
			g.drawRect(rect.x, rect.y, rect.width, rect.height);		
			*/
			g.beginFill(lightColor);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);		
			
			g.beginFill(darkColor);
			g.drawRect(rect.x, rect.y-1, rect.width, rect.height);
			
			g.endFill();
		}
		
		internal function destroy():void
		{
			while (numChildren)
			{
				var button:DialogButton = DialogButton(getChildAt(0));
				button.removeEventListener(MouseEvent.CLICK, buttonClick);
				button.destroy();				
			}
			
			_buttonArray = null;
			
			_setting = null;
			
			if (parent) parent.removeChild(this);
		}
		
		/************************
		*         params
		************************/
		private var _setting:DialogSetting;
		internal static var BUTTON_CLICK:String = 'buttonClick';		
		
		private var _bound:Rectangle;
		public function get bound():Rectangle { return _bound; }
		
		private var _rc:Number;
		public function get rc():Number { return _rc; }
		
		private var _buttonArray:Array;
		
		private var _maxButtonWidth:Number;
		
		private var _align:String;
		
		//public function get groupWidth():Number 
		//{
			//return _maxButtonWidth
		//}
	}
}