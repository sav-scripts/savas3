package sav.components.dialog_v2
{
	import flash.text.StyleSheet;
	
	public class DialogSetting extends Object
	{	
		public var closeButtonText:String = 'CLOSE';
		
		// new stuffs
		public var font:String = null;
		
		public var offsetX:Number = 0;
		public var offsetY:Number = 0;
		
		public var scrollerColor:int = 0xcccccc;
		public var scrollerDragbarColor:int = 0x333333;
		
		public var titleHeight:int = 32;
		public var titleBrightHeight:int = 2;
		public var titleColor:int = 0x222222;
		public var titleTextColor:int = 0xB2B2B2;
		public var titleTextSize:int = 16;
		
		// main
		public var blockBackground:Boolean = true;
		public var coverColor:uint = 0x000000;
		public var coverAlpha:Number = 0.3;
		
		public var autoSize:Boolean = true;
		public var maxWidth:Number = 0;
		public var maxHeight:Number = 0;
		
		public var contentInflateWidth:Number = 20;
		public var contentInflateHeight:Number = 32;
		
		// basement 
		public var baseColor:uint = 0xE5E5E5;
		public var baseRoundConer:Number = 10;
		
		// content
		public var contentTextColor:uint = 0x333333;
		public var contentTextSize:uint = 16;
		public var scrollerWidth:uint = 6;
		public var styleSheet:StyleSheet;
		
		// button
		public var buttonAlign:String = ButtonAlign.HORIZONTAL;
		public var buttonTextColor:uint = 0x333333;
		public var buttonHeight:Number = 30;
		public var buttonTextSize:Number = 14;
		public var buttonInflateWidth:Number = 8;
		public var buttonLetterSpacing:Number = 0;
		
		public function clone():DialogSetting
		{
			var setting:DialogSetting = new DialogSetting();
			
			setting.closeButtonText = closeButtonText;
		
			setting.font = font;
			
			setting.offsetX = offsetX;
			setting.offsetY = offsetY;
			
			setting.scrollerColor = scrollerColor;
			setting.scrollerDragbarColor = scrollerDragbarColor;
			
			setting.titleHeight = titleHeight;
			setting.titleBrightHeight = titleBrightHeight;
			setting.titleColor = titleColor;
			setting.titleTextColor = titleTextColor;
			setting.titleTextSize = titleTextSize;
			
			setting.blockBackground = blockBackground;
			setting.coverColor = coverColor;
			setting.coverAlpha = coverAlpha;
			
			setting.autoSize = autoSize;		
			setting.maxWidth = maxWidth;
			setting.maxHeight = maxHeight;
			
			setting.contentInflateWidth = contentInflateWidth;
			setting.contentInflateHeight = contentInflateHeight;
			
			setting.baseColor = baseColor;
			setting.baseRoundConer = baseRoundConer;
			
			setting.contentTextColor = contentTextColor;
			setting.contentTextSize = contentTextSize;
			setting.scrollerWidth = scrollerWidth;
			setting.styleSheet = styleSheet;
			
			setting.buttonAlign = buttonAlign;
			setting.buttonTextColor = buttonTextColor;
			setting.buttonHeight = buttonHeight;
			setting.buttonTextSize = buttonTextSize;
			setting.buttonInflateWidth = buttonInflateWidth;
			setting.buttonLetterSpacing = buttonLetterSpacing;
			
			return setting;
		}
	}
}