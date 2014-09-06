package sav.components.dialog_v2
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import sav.utils.ColorUtils;
	import flash.display.GradientType;
	import sav.gp.GraphicDrawer;
	
	public class Basement extends Sprite
	{
		public function Basement(setting:DialogSetting):void 
		{
			_setting = setting; 
			filters = [new GlowFilter(0, 1, 8, 8, .4, 3)];
		}
		
		internal function resize(title:String, bound:Rectangle, btnBound:Rectangle = null, numButtons:int=0, btnRc:Number = 10, scrollerHeight:Number = Number.NaN):void
		{
			_bound = bound;
			
			bound = _bound.clone();
			
			var g:Graphics = this.graphics;
			g.beginFill(_setting.baseColor);
			(title != null) ?
				GraphicDrawer.drawRoundRectComplex(g, bound, 0, 0, _setting.baseRoundConer, _setting.baseRoundConer) :
				GraphicDrawer.drawRoundRect(g, bound, _setting.baseRoundConer);
			//g.drawRoundRect(bound.x, bound.y, bound.width, bound.height, _setting.baseRoundConer, _setting.baseRoundConer);
			g.endFill();
			
			
			var darkColor:int = ColorUtils.brighten(_setting.baseColor, -.1);
			var lightColor:int = ColorUtils.brighten(_setting.baseColor, .06);
			
			g.beginFill(darkColor);
			g.drawRect(bound.x, btnBound.y-1, bound.width, 1);
			g.beginFill(lightColor);
			g.drawRect(bound.x, btnBound.y, bound.width, 1);
			g.endFill();
			
			if (title != null)
			{
				g.beginFill(darkColor);
				g.drawRect(bound.x, bound.y-1, bound.width, 1);
				g.beginFill(lightColor);
				g.drawRect(bound.x, bound.y, bound.width, 1);
				
				var titleLightColor:int = ColorUtils.brighten(_setting.titleColor, .03);
				var titleRect:Rectangle = new Rectangle(bound.x, bound.y - _setting.titleHeight, bound.width, _setting.titleHeight - 1);
				g.beginFill(titleLightColor);
				GraphicDrawer.drawRoundRectComplex(g, titleRect, _setting.baseRoundConer, _setting.baseRoundConer, 0, 0);
				titleRect.y += _setting.titleBrightHeight;
				titleRect.height -= _setting.titleBrightHeight;
				g.beginFill(_setting.titleColor);
				GraphicDrawer.drawRoundRectComplex(g, titleRect, _setting.baseRoundConer, _setting.baseRoundConer, 0, 0);
				
				
			
				_titleTF.x = bound.x + int((_bound.width - _titleTF.width) / 2);
				var titleHeight:int = _setting.titleHeight - _setting.titleBrightHeight;
				_titleTF.y = _bound.y - titleHeight + int((titleHeight - _titleTF.height) / 2);
			
				addChild(_titleTF);
			}
			
			if (_setting.buttonAlign == ButtonAlign.VERTICAL && numButtons > 1)
			{
				var i:int;
				
				for (i = 1; i < numButtons; i++)
				{
					g.beginFill(darkColor);
					g.drawRect(bound.x, btnBound.y - 1 + i * _setting.buttonHeight, bound.width, 1);
					g.beginFill(lightColor);
					g.drawRect(bound.x, btnBound.y + i * _setting.buttonHeight, bound.width, 1);
					g.endFill();
				}
			}
		}
		
		public function makeTitleTF(title:String):void
		{
			if (title == null) return;
			
			var format:TextFormat = new TextFormat();
			format.size = _setting.titleTextSize;
			format.color = _setting.titleTextColor;
			if (_setting.font != null) format.font = _setting.font;
		
			var tf:TextField = new TextField();
			tf.defaultTextFormat = format;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.selectable = false;
			tf.text = title;	
			if (_setting.font != null)
			{
				tf.embedFonts = true;	
				tf.antiAliasType = AntiAliasType.ADVANCED;
			}
			
			_titleTF = tf;
		}
		
		internal function destroy():void
		{
			_bound = null;
			_setting = null;
			
			if (_titleTF)
			{
				if (_titleTF.parent) removeChild(_titleTF);
				_titleTF = null;
			}
			
			if (parent) parent.removeChild(this);
		}
		
		/************************
		*         params
		************************/
		private var _setting:DialogSetting;
		private var _bound:Rectangle;	
		private var _titleTF:TextField;
		public function get titleTF():TextField { return _titleTF; }
	}
}