package sav.components.emitter
{
	import sav.effects.emitter.Bubble;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class BubbleSwarm extends Sprite
	{
		private var bubble		:Bubble;
		private var bubble2		:Bubble;
		
		private var _progress		:Number = 0;
		[Inspectable (type=Number, defaultValue=0, name="progress") ]
		public function get progress():Number { return _progress; }
		public function set progress(n:Number):void
		{
			_progress = n;
			bubble2.scale = _progress;
			bubble.scale = _progress * 0.8;
			start();
		}
		
		public function start():void
		{
			bubble2.start();
			bubble.start();
			
		}
		
		public function stop():void
		{
			bubble.stop();
			bubble2.stop();
			
		}
		
		public function BubbleSwarm():void
		{
			super();
			while (numChildren > 0) removeChildAt(0);
			init();
			progress = 0;
		}
		
		public function init():void
		{
			bubble2 = new Bubble(BubbleSwarm_Circle);	
			addChild(bubble2);
			bubble2.init(true);
				
			bubble = new Bubble(BubbleSwarm_Circle2);	
			addChild(bubble);
			bubble.init(true);
		}
		
		public function destroy():void
		{
			bubble.destroy();
			bubble2.destroy();
			if (parent) parent.removeChild(this);
		}
	}	
}
import flash.display.Graphics;
import flash.display.Shape;

class BubbleSwarm_Circle extends Shape
{
	public function BubbleSwarm_Circle()
	{
		var g:Graphics = this.graphics;
		g.beginFill(0xffffff, 1);
		g.drawCircle(0, 0, 20);
		g.endFill();
	}
}

class BubbleSwarm_Circle2 extends Shape
{
	public function BubbleSwarm_Circle2()
	{
		var g:Graphics = this.graphics;
		g.beginFill(0xCCFFFF, 1);
		g.drawCircle(0, 0, 20);
		g.endFill();
	}
}