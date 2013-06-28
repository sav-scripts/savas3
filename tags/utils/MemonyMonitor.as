package sav.utils
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	public class MemonyMonitor
	{
		protected static var stage:Stage;
		protected static var sprite:Sprite;
		protected static var textField:TextField;
		protected static var initiated:Boolean = false;
		protected static var isHiding:Boolean = true;

		protected static var time :Number;
		protected static var frameTime :Number;
		protected static var prevFrameTime :Number = getTimer();
		protected static var secondTime :Number;
		protected static var prevSecondTime :Number = getTimer();
		protected static var frames :Number = 0;
		protected static var fps :String = "...";
		protected static var scale:Number = 1;
		
		public static function init(s:Stage):void
		{
			if (initiated) return;
			
			stage = s;
			sprite = new Sprite();
			
			textField = new TextField();			
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.selectable = false;
			textField.x = 2;
			sprite.addChild(textField);
			
			var textFormat:TextFormat = new TextFormat('Arial Regular');
			textFormat.size = 9;
			
			textField.defaultTextFormat = textFormat;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN , switchKeyPressed);
			
			initiated = true;		
		}
		
		protected static function switchKeyPressed(evt:KeyboardEvent):void
		{
			if (evt.keyCode == 192) switchThis();
		}

		protected static function onEnterFrame(event:Event):void
		{
			time = getTimer();

			frameTime = time - prevFrameTime;
			secondTime = time - prevSecondTime;
	
			if(secondTime >= 1000) {
				fps = frames.toString();
				frames = 0;
				prevSecondTime = time;
			}
			else
			{
				frames++;
			}
	
			prevFrameTime = time;
			scale = scale - ((scale - (frameTime / 10)) / 5);
			sprite.graphics.clear();
			sprite.graphics.beginFill(0xff0000);
			sprite.graphics.drawRect(0, 0, stage.stageWidth / 10 * scale, 1);
			sprite.graphics.endFill();
			
			textField.htmlText = ((fps + " FPS / ") + frameTime) + " MS , " + String(int(System.totalMemory>>10) + ' KB');
		}
		
		protected static function switchThis():void
		{
			if (isHiding)
			{
				isHiding = false;
				stage.addChild(sprite);
				sprite.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			else
			{
				isHiding = true;
				stage.removeChild(sprite);
				sprite.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
	}
}