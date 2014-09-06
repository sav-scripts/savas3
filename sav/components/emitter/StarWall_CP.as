package sav.components.emitter
{
	import sav.effects.emitter.StarWall;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class StarWall_CP extends Sprite
	{		
		public function StarWall_CP():void
		{
			super();
			while (numChildren > 0) removeChildAt(0);
			
			init();
			
			progress = 0;
			
		}
		
		public function init():void
		{				
			_starWall = new StarWall(sav.effects.emitter.StarSample);
			addChild(_starWall);
			_starWall.init(true);
		}
		
		public function destroy():void
		{
			_starWall.destroy();
			if (parent) parent.removeChild(this);
		}
		
		private var _starWall		:StarWall;
		
		private var _progress		:Number = 0.5;		
		[Inspectable (type=Number, defaultValue=0, name="progress") ]
		public function get progress():Number { return _progress; }
		public function set progress(n:Number):void
		{
			if (n > 1) n = 1;
			_progress = n;
			_starWall.scale = _progress;
			_starWall.start();
		}
		
		[Inspectable (type=Number, defaultValue=100, name="length") ]
		public function get length():Number { return _starWall.length; }
		public function set length(n:Number):void
		{
			_starWall.length = n;
		}
	}	
}