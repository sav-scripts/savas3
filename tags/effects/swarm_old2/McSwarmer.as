package sav.effects.swarm
{
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	
	public class McSwarmer
	{
		private static var datas:Array = [];
		private static var timer:Timer;
		
		public static function init(d:uint = 30):void
		{
			if (timer) return;
			timer = new Timer(d);
			timer.addEventListener(TimerEvent.TIMER , timerTick);
			timer.start();
		}
		
		public static function start():void	{ if (!timer.running) timer.start(); }
		
		public static function stop():void { if (timer.running) timer.stop(); }
		
		public static function set delay(d:uint):void {	(timer) ? timer.delay = d : init(d); }
		public static function get delay():uint { return (timer) ? timer.delay : 0; }
		
		private static function timerTick(evt:TimerEvent):void { for each(var swarmData:Swarmer in datas) swarmData.render(delay * 0.001); }
		
		public static function addSwarmer(sourceClip:DisplayObject , params:Object = null , startAfterBuilden:Boolean = true):Swarmer
		{
			init();
			var swarmer:Swarmer = new Swarmer(sourceClip, params);
			swarmer.addEventListener('completed' , swarmCompleted);				
			if (startAfterBuilden) datas.push(swarmer);
			return swarmer;
		}
		
		public static function startSwarmer(swarmer:Swarmer):void
		{
			datas.push(swarmer);			
		}
		
		private static function swarmCompleted(evt:Event):void
		{
			var swarmer:Swarmer = Swarmer(evt.target);
			swarmer.removeEventListener(Event.COMPLETE , swarmCompleted);
			var index:uint = datas.indexOf(swarmer);
			datas.splice(index , 1);			
		}
	}	
}