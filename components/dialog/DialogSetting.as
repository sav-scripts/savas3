package sav.components.dialog
{
	import flash.text.StyleSheet;
	
	public class DialogSetting extends Object
	{
		public var closeButtonText:String = 'CLOSE';
		
		// main
		public var blockBackground:Boolean = true;
		public var coverColor:uint = 0x000000;
		public var coverAlpha:Number = 0.3;
		
		public var autoSize:Boolean = true;
		public var maxWidth:Number = 0;
		public var maxHeight:Number = 0;
		
		public var contentInflateWidth:Number = 16;
		public var contentInflateHeight:Number = 12;
		
		// basement 
		public var baseColor:uint = 0x6488C9;
		public var baseRoundConer:Number = 10;
		public var boardColor:uint = baseColor;
		public var boardSize:uint = 2;
		
		// content
		public var contentTextColor:uint = 0xf0f0f0;
		public var contentTextSize:uint = 12;
		public var scrollerWidth:uint = 6;
		public var styleSheet:StyleSheet;
		
		// button
		public var buttonColor:uint = 0xE7E0D3;
		public var buttonTextColor:uint = 0x333333;
		public var buttonHeight:Number = 18;
		public var buttonTextSize:Number = 12;
		public var buttonInflateWidth:Number = 8;
		public var buttonGapToContent:Number = 6;
		public var buttonLetterSpacing:Number = 0;
		
		public function clone():DialogSetting
		{
			var setting:DialogSetting = new DialogSetting();
			
			setting.closeButtonText = closeButtonText;
			
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
			setting.boardColor = boardColor;
			setting.boardSize = boardSize;
			
			setting.contentTextColor = contentTextColor;
			setting.contentTextSize = contentTextSize;
			setting.scrollerWidth = scrollerWidth;
			setting.styleSheet = styleSheet;
			
			setting.buttonColor = buttonColor;
			setting.buttonHeight = buttonHeight;
			setting.buttonTextSize = buttonTextSize;
			setting.buttonInflateWidth = buttonInflateWidth;
			setting.buttonGapToContent = buttonGapToContent;
			setting.buttonLetterSpacing = buttonLetterSpacing;
			
			return setting;
		}
	}
}