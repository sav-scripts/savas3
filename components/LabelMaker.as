package sav.components
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class LabelMaker
	{
		private static var stage:DisplayObjectContainer;
		
		public static var labelColor		:Number = 0x000000;
		public static var labelAlpha		:Number = 0.65;
		public static var textColor			:Number = 0xbbbbbb;
		public static var wGap				:Number = 10;
		public static var hGap				:Number = -1;
		public static var roundConer		:Number = 20;
		
		public static function init(s:DisplayObjectContainer):void
		{
			stage = s;
		}
		
		private static var labels:Array = [];
		
		public static function paste(string:String , x:Number , y:Number , labelName:String = ''):String
		{
			var textFormat:TextFormat = new TextFormat();
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.color = textColor;
			textFormat.kerning = true;
			textFormat.font = 'Arial Bold Italic';
			
			var textField:TextField = new TextField();
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.selectable = false;
			textField.htmlText = string;
			textField.setTextFormat(textFormat);
			textField.x = -textField.width / 2;
			textField.y = -textField.height / 2;
			
			var rect:Rectangle = new Rectangle(0, 0, textField.width, textField.height);
			rect.offset(-rect.width / 2 , -rect.height / 2);
			rect.inflate(wGap, hGap);
			
			var label:Sprite = new Sprite();
			label.addChild(textField);
			label.x = x;
			label.y = y;
			label.alpha = 0;
			
			var shadow:GlowFilter = new GlowFilter(0x000000 , 0.5 , 3 , 3);
			label.filters = [shadow];
			
			label.graphics.beginFill(labelColor , labelAlpha);
			label.graphics.drawRoundRect(rect.x, rect.y, rect.width, rect.height, roundConer);			
			
			stage.addChild(label);
			
			if (labelName == '') labelName = label.name;
			
			labels.push(new LabelObject(labelName, label));
			
			Tweener.addTween(label , { time:0.5 , alpha:1 } );
			
			return labelName;
		}
		
		public static function remove(labelName:String):void
		{
			for (var i:uint = 0; i < labels.length;i++ )
			{
				var labelObject:LabelObject = labels[i];
				
				if (labelObject.labelName == labelName)
				{
					labels.splice(i, 1);
					i--;
					Tweener.removeTweens(labelObject.label);
					Tweener.addTween(labelObject.label , { time:0.5 , alpha:0 , onComplete:removeLabel , onCompleteParams:[labelObject.label]} );
				}
			}
		}
		
		private static function removeLabel(label:Sprite):void
		{
			if (label.parent) label.parent.removeChild(label);
		}
	}
}

import flash.display.Sprite;

class LabelObject extends Object
{
	public var labelName:String;
	public var label:Sprite;
	
	public function LabelObject(labelName:String , label:Sprite)
	{
		this.labelName = labelName;
		this.label = label;
		this.label.mouseChildren = false;
		this.label.mouseEnabled = false;
	}
}