package sav.components.dialog_v2
{
	import flash.display.Graphics;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import sav.components.simpleScroller.SimpleScroller;
	import sav.utils.ColorUtils;
	
	public class Content extends Sprite
	{
		public function Content(setting:DialogSetting, dialog:Dialog):void 
		{ 
			_setting = setting; 
			_dialog = dialog;
			_mask = new Sprite();
			_contentLayer = new Sprite();
			addChild(_contentLayer);
			
			_maskBound = new Rectangle();
		}
		
		internal function clear():void
		{
			while (_contentLayer.numChildren) _contentLayer.removeChildAt(0);
		}
		
		internal function checkForScroll():Number
		{
			if (_setting.autoSize) return Number.NaN;
			
			var contentBound:Rectangle = _contentLayer.getBounds(this);
			
			if (_maskBound.height < contentBound.height)
			{
				//var scrollerColor:uint = ColorUtils.blend(_setting.boardColor, _setting.baseColor, 0.3);
				
				
				_scroller = new SimpleScroller(0, false, false, _setting.scrollerColor, 1, _setting.scrollerDragbarColor);
				var rc:Number = _setting.scrollerWidth / 2;
				_scroller.setRoundConer(rc, 1, rc, 1);
				
				_scroller.x = maskBound.width + _setting.contentInflateWidth - _setting.scrollerWidth;
				
				_scroller.bindWith(_contentLayer, _dialog);
				_scroller.resize(new Rectangle(0, 0, _setting.scrollerWidth, _maskBound.height));
				addChild(_scroller);
				
				return _maskBound.height;
			}
			else
			{
				return Number.NaN;
			}
		}
		
		internal function addContent(displayObject:DisplayObject, arrangeIt:Boolean = true):void
		{
			_isEmpty = false;
			
			_contentLayer.addChild(displayObject);
			
			if (arrangeIt)
			{
				var bound:Rectangle = displayObject.getBounds(_contentLayer);
				_contentLayer.x -= bound.x;
				_contentLayer.y -= bound.y;
			}
		}
		
		internal function toText(string:String):void
		{
			clear();
			
			_isEmpty = false;
			
			var format:TextFormat = new TextFormat();
			format.size = _setting.contentTextSize;
			if (_setting.font != null)
			{
				format.font = _setting.font;;
			}
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = format;
			tf.textColor = _setting.contentTextColor;
            tf.multiline = true;
			
			if (_setting.font != null)
			{
				tf.antiAliasType = AntiAliasType.ADVANCED;
				tf.embedFonts = true;
			}
			
			
			if (_setting.autoSize)
			{			
				tf.autoSize = TextFieldAutoSize.LEFT;	
			}
			else
			{
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.width = _setting.maxWidth - _setting.contentInflateWidth * 2;
				tf.wordWrap = true;
			}
			
			
			tf.selectable = false;			
			tf.styleSheet = _setting.styleSheet;
			tf.htmlText = string;
			
			_contentLayer.addChild(tf);
			
			_alertTf = tf;
		}
		
		internal function get maskBound():Rectangle { return _maskBound; }
		internal function set maskBound(rect:Rectangle):void
		{
			_maskBound = rect.clone();
			_maskBound.x = _maskBound.y = 0;
			var g:Graphics = _mask.graphics;
			g.clear();
			g.beginFill(0);
			g.drawRect(0, 0, rect.width, rect.height);
		}		
		
		internal function destroy():void
		{			
			if (_mask.parent) removeChild(_mask);
			_mask = null;
			
			if (_alertTf)
			{
				_contentLayer.removeChild(_alertTf);
				_alertTf = null;
			}
			
			clear();
			removeChild(_contentLayer);
			_contentLayer.mask = null;
			_contentLayer = null;
			
			_setting = null;
			_maskBound = null;
			
			if (_scroller) _scroller.destroy();
			_dialog = null;			
			
			if (parent) parent.removeChild(this);			
		}
		
		/************************
		*         params
		************************/
		private var _dialog:Dialog;
		private var _scroller:SimpleScroller;
		private var _alertTf:TextField;
		private var _setting:DialogSetting;
		private var _mask:Sprite;
		private var _contentLayer:Sprite;
		private var _maskBound:Rectangle;
		
		private var _enableMask:Boolean = false;
		public function get enableMask():Boolean { return _enableMask; }
		public function set enableMask(b:Boolean):void
		{
			_enableMask = b;
			if (_enableMask)
			{
				_contentLayer.mask = _mask;
				addChild(_mask);
			}
			else
			{
				_contentLayer.mask = null;
				if(_mask.parent) removeChild(_mask);
			}
		}
		
		private var _isEmpty:Boolean = true;
		public function get isEmpty():Boolean { return _isEmpty; }
	}
}