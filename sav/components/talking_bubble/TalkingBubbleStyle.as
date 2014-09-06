package sav.components.talking_bubble 
{
	import flash.filters.GlowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TalkingBubbleStyle
	{		
		public var text_size:Number = 12;
		public var text_solor:Number = 0xdddddd;
		//public var text_solor:Number = 0x232323;
		public var text_selectable:Boolean = false;
		public var text_filters:Array = [new GlowFilter(0x000000, 1, 2, 2, 10)];
		public var text_align:String = TextFieldAutoSize.LEFT;
		public var text_htmlText:Boolean = false;
		
		public var bubble_body_color:uint = 0x000000;
		//public var bubble_body_color:uint = 0xffffff;
		public var bubble_body_alpha:Number = 0.5;
		public var bubble_line_color:uint = 0x000000;
		//public var bubble_line_color:uint = 0xffffff;
		public var bubble_line_alpha:Number = 1;
		public var bubble_bleed_width:int = 20;
		public var bubble_bleed_height:int = 20;
		public var bubble_line_inflate:int = 2;
		public var bubble_line_thickness:int = 1;
		
		public var roundConer:Number = 20;
		public var extendLength:Number = 12;
		
		public var resizeTextField:Boolean = true;
		
		
		public function clone():TalkingBubbleStyle
		{
			var style:TalkingBubbleStyle = new TalkingBubbleStyle();
			
			style.text_size = text_size;
			style.text_solor = text_solor;
			style.text_selectable = text_selectable;
			style.text_filters = text_filters;
			style.text_align = text_align;
			style.text_htmlText = text_htmlText;
			
			style.bubble_body_color = bubble_body_color;
			style.bubble_body_alpha = bubble_body_alpha;
			style.bubble_line_color = bubble_line_color;
			style.bubble_line_alpha = bubble_line_alpha;
			style.bubble_bleed_width = bubble_bleed_width;
			style.bubble_bleed_height = bubble_bleed_height;
			style.bubble_line_inflate = bubble_line_inflate;
			style.bubble_line_thickness = bubble_line_thickness;
			
			style.roundConer = roundConer;
			style.extendLength = extendLength;
			
			style.resizeTextField = resizeTextField;
			
			return style;
		}
	}
}