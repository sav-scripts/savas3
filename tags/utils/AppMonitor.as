package sav.utils
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;	
	
	/// while your app running, press "ctrl" + "~" key for hide/show this. Use addMessage method for trace message on screen.
	public class AppMonitor
	{
		private static var stage:Stage;
		private static var sprite:Sprite;
		private static var shape:Shape;
		private static var textField:TextField;
		private static var initiated:Boolean = false;
		private static var isHiding:Boolean = true;

		private static var time :Number;
		private static var frameTime :Number;
		private static var prevFrameTime :Number = getTimer();
		private static var secondTime :Number;
		private static var prevSecondTime :Number = getTimer();
		private static var frames :Number = 0;
		private static var fps :String = "...";
		private static var scale:Number = 1;
		
		private static var mtf:TextField;
		
		/**
		 * Initiate AppMonitor 
		 * @param	s	Stage	Pass stage reference to this
		 */
		public static function init(s:Stage):void
		{
			if (initiated) return;
			
			stage = s;
			sprite = new Sprite();
			
			textField = new TextField();			
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.selectable = false;
			textField.textColor = 0xffffff;
			textField.x = 2;
			
			var textFormat:TextFormat = new TextFormat('Arial Regular');
			textFormat.size = 9;			
			textField.defaultTextFormat = textFormat;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN , switchKeyPressed);
			
			initiated = true;	
			
			mtf = new TextField();
			
			mtf = new TextField();		
			
			mtf.textColor = 0xffffff;
			mtf.multiline = true;
			mtf.selectable = false;
			mtf.x = 2;
			mtf.y = 20;
			mtf.width = stage.stageWidth - 4;
			mtf.height = 200;
			
			shape = new Shape();
			
			sprite.addChild(shape);
			sprite.addChild(mtf);
			sprite.addChild(textField);
			
			sprite.mouseEnabled = false;
			sprite.mouseChildren = false;
		}
		
		/**
		 * Add message to this monitor
		 * @param	message		String		Message
		 * @param	doTrace		Boolean		Set to true make it trace message
		 */
		public static function addMessage(message:*, doTrace:Boolean = true):void
		{
			message = String(message);
			if (!stage) throw new Error('AppMonitor not initiated, please call AppMonitor.init(stage) before add message.');
			if (doTrace) trace(message);
			mtf.htmlText = mtf.htmlText + message + '\n';
			
			if (mtf.numLines >= 15)
			{
				mtf.scrollV = 15;
			}
			
			var bound:Rectangle = mtf.getBounds(mtf.parent);
			
			shape.graphics.clear();
			shape.graphics.beginFill(0x000000, 0.5);
			shape.graphics.drawRect(0, 1, stage.stageWidth, bound.bottom);
			shape.graphics.endFill();
		}		
		
		private static function switchKeyPressed(evt:KeyboardEvent):void
		{
			if (evt.keyCode == 192 && evt.ctrlKey) switchThis();
			if (evt.keyCode == 192 && !evt.ctrlKey) forceGC();
		}
		
		public static function forceGC(traceOnMonitor:Boolean = true):void
		{
			var oldMemory:String = String(int(System.totalMemory >> 10) + ' KB');
			try {
				new LocalConnection().connect('foo');
				new LocalConnection().connect('foo');
			} catch (e:*) {}
			
			var newMemory:String = String(int(System.totalMemory >> 10) + ' KB');
			
			var msg:String = 'Memory usage : [ ' + oldMemory + ' ] >>> [ ' + newMemory + ' ]';
			
			(traceOnMonitor) ? addMessage(msg) : trace(msg);
		}

		private static function onEnterFrame(event:Event):void
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
		
		public static function switchThis():void
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