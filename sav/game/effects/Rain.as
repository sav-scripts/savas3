package sav.game.effects
{
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import caurina.transitions.Tweener;
	
	public class Rain extends Sprite
	{
		public var SampleClass				:Class;
		public var delay					:uint = 30;
		public var waveCount				:uint = 5;
		public var wRange					:int;
		public var hRange					:int;
		
		private var timer					:Timer;
		
		public function Rain(sc:Class)
		{
			SampleClass = sc;
			init();
		}
		
		public function init():void
		{
			timer = new Timer(delay);
			timer.addEventListener(TimerEvent.TIMER , timerUpdate);
			
		}
		
		public function start(w:int = -100 , h:int = -100):void
		{
			if (w == -100)
			{
				wRange = this.stage.stageWidth;
				hRange = int(this.stage.stageHeight / 3);
			}
			else
			{
				wRange = w;
				hRange = h;
			}
			timer.start();
		}
		
		public function stop():void
		{
			timer.stop();
		}
		
		private function timerUpdate(evt:TimerEvent):void
		{
			for (var i=0;i<waveCount;i++)
			{
				var aRain = new SampleClass();
				aRain.x = int(Math.random() * wRange);
				aRain.y = int(Math.random() * hRange - hRange/2);
				this.addChild(aRain);
				
				Tweener.addTween(aRain , {time:0.03 , y:(aRain.y + aRain.height/2) , onComplete:rainComplete , onCompleteParams:[aRain]});
			}			
		}
		
		private function rainComplete(aRain:*):void
		{
			this.removeChild(aRain);
		}
	}
}