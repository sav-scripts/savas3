package sav.components.dialog_v2
{
	import flash.display.Graphics;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import sav.utils.ColorUtils;
	import flash.display.GradientType;
	import sav.gp.GraphicDrawer;
	
	public class DialogButton extends SimpleButton
	{
		public function DialogButton(string:String, func:Function, funcParams:Array, closeDialog:Boolean, w:Number, setting:DialogSetting):void
		{
			_setting = setting;
			_text = string;
			_closeDialog = closeDialog;
			_bound = new Rectangle(0, 0, w, _setting.buttonHeight);
			_execFunc = func;
			_execFuncParams = funcParams;
			
			
			upState = getState('up');
			overState = getState('over');
			downState = getState('down');
			hitTestState = getState('hitTest');
		}
		
		private function getState(state:String = ''):Sprite
		{
			var sp:Sprite = new Sprite();
			
			var textColor:int = _setting.buttonTextColor;
			
			var tf:TextField = getTextField(_text, _setting.buttonTextSize, _setting.buttonLetterSpacing, textColor, _setting.font);
			tf.x = _bound.x + (_bound.width - tf.width) / 2 + _setting.buttonLetterSpacing / 2;
			tf.y = _bound.y + (_bound.height - tf.height) / 2;
			
			if (state == 'down') tf.y += 2;
			sp.addChild(tf);			
			
			if (state == 'hitTest')
			{
				var g:Graphics = sp.graphics;
				g.beginFill(0xff0000);
				g.drawRect(_bound.x, _bound.y, _bound.width, _bound.height);
				g.endFill();
			}
			
			
			return sp;
		}
		
		internal static function getTextField(string:String, textSize:Number, letterSpacing:Number = 0, textColor:uint = 0x000000, font:String = null):TextField
		{			
			var format:TextFormat = new TextFormat();
			format.letterSpacing = letterSpacing;
			format.size = textSize;
			format.color = textColor;
			if(font != null) format.font = font;
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = format;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.selectable = false;
			tf.text = string;	
			if (font != null)
			{
				tf.embedFonts = true;	
				tf.antiAliasType = AntiAliasType.ADVANCED;
			}
			
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
		
		internal var _closeDialog:Boolean;		
		internal var _execFunc:Function;
		internal var _execFuncParams:Array;
	}
}