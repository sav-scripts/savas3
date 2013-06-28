package sav.components.dialog
{
	import flash.display.Graphics;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import fl.motion.Color;
	import flash.display.GradientType;
	import sav.gp.GraphicDrawer;
	
	public class DialogButton extends SimpleButton
	{
		public function DialogButton(string:String, func:Function, funcParams:Array, closeDialog:Boolean, w:Number, setting:DialogSetting, align:String = 'middle'):void
		{
			_setting = setting;
			_text = string;
			_closeDialog = closeDialog;
			_bound = new Rectangle(0, 0, w, _setting.buttonHeight);
			_execFunc = func;
			_execFuncParams = funcParams;
			_align = align;
			
			
			upState = getState('up');
			overState = getState('over');
			downState = getState('down');
			hitTestState = getState();
		}
		
		private function getState(state:String = ''):Sprite
		{
			var orc:Number = _setting.buttonHeight / 2;
			var sp:Sprite = new Sprite();
			var g:Graphics = sp.graphics;
			var rc1:Number = (_align == 'middle' || _align == 'right') ? 2 : orc;
			var rc2:Number = (_align == 'middle' || _align == 'left') ? 2 : orc;
			var rc3:Number = (_align == 'middle' || _align == 'right') ? 2 : 2;
			var rc4:Number = (_align == 'middle' || _align == 'left') ? 2 : 2;
			
			var color:uint = _setting.buttonColor;
			
			var c5:Number = Color.interpolateColor(color, 0x000000, 0.5);
			
			var rect:Rectangle = _bound.clone();
			rect.x = 0;
			rect.y = 0;
			
			//rect.inflate(1, 1);
			g.beginFill(c5);
			//g.drawRoundRectComplex(rect.x, rect.y, rect.width, rect.height, rc1 + 1, rc2 + 1, rc3 + 1, rc4 + 1);			
			GraphicDrawer.drawRoundRectComplex(g, rect, rc1 + 1, rc2 + 1, rc3 + 1, rc4 + 1);
			
			rect.inflate(-1,-1);
			
			//var c1:uint = Color.interpolateColor(color, 0x000000, 0.18);
			//if (state == 'over') color = Color.interpolateColor(color, 0xffffff, 0.4);
			
			var c3:uint = Color.interpolateColor(color, 0xffffff, 0.10);
			var c1:uint = (state == 'over') ? 	Color.interpolateColor(color, 0xffffff, 0.20) :
												Color.interpolateColor(color, 0x000000, 0.08);
			var c2:uint = Color.interpolateColor(color, 0xffffff, 0.20);
			
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [c3, color, c1, c2];
			var alphas:Array = [1, 1, 1, 1];
			var ratios:Array = [0x00, 0x55, 0x77, 0xff];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(_bound.width, _bound.height, Math.PI / 2);
			g.beginGradientFill(fillType, colors, alphas, ratios, matr);			
			//g.drawRoundRectComplex(rect.x, rect.y, rect.width, rect.height, rc1, rc2, rc3, rc4);
			GraphicDrawer.drawRoundRectComplex(g, rect, rc1, rc2, rc3, rc4);
			
			g.endFill();
			
			var textColor:int = _setting.buttonTextColor;
			//if (state == 'over') textColor = Color.interpolateColor(textColor, 0x000000, 0.5);
			
			var tf:TextField = getTextField(_text, _setting.buttonTextSize, _setting.buttonLetterSpacing, textColor);
			tf.x = _bound.x + (_bound.width - tf.width) / 2 + _setting.buttonLetterSpacing / 2;
			tf.y = _bound.y + (_bound.height - tf.height) / 2;
			
			if (state == 'down') sp.y += 1;
			sp.addChild(tf);			
			
			return sp;
		}
		
		internal static function getTextField(string:String, textSize:Number, letterSpacing:Number = 0, textColor:uint = 0x000000):TextField
		{			
			var format:TextFormat = new TextFormat();
			format.letterSpacing = letterSpacing;
			format.size = textSize;
			format.color = textColor;
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = format;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.selectable = false;
			tf.text = string;			
			
			return tf;
		}
		
		
		internal function destroy():void
		{
			_bound = null;
			_setting = null;
			_execFunc = null;
			_execFuncParams = null;
			
			if (parent) parent.removeChild(this);
		}
		
		private var _text:String;
		private var _bound:Rectangle;
		private var _setting:DialogSetting;
		private var _align:String;
		
		internal var _closeDialog:Boolean;		
		internal var _execFunc:Function;
		internal var _execFuncParams:Array;
	}
}