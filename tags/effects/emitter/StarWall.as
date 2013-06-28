package sav.effects.emitter
{
	import flash.display.Sprite;
	import flash.events.Event;
	import idv.cjcat.emitter.*;
	import idv.cjcat.emitter.geom.Vector2D;
	import idv.cjcat.emitter.fields.*;
	import caurina.transitions.Tweener;
	
	[Event(name = 'complete', type = 'flash.events.Event')]
	public class StarWall extends Emitter
	{		
		public function StarWall(C:Class)
		{
			_ParticleClass = C;
			
			addChildMode = AddChildMode.TOP;
			
			if (this.stage) init();
		}
		
		public function init(startAfter:Boolean = false, activeSource:Boolean = true):void
		{
			ptc = buildParticle(_ParticleClass);
			
			_source = new LineSource();
			_source.addParticle(ptc);
			_source.active = activeSource;

			addSource(_source);
			
			if (startAfter) start();
		}
		
		private var isStart:Boolean = false;
		public function start():void
		{
			if (isStart) return;
			isStart = true;
			//loop(null);
			
			addEventListener(Event.ENTER_FRAME, loop);
			addEventListener(Event.ENTER_FRAME, checkNumChildren);
		}
		
		public function stop():void
		{
			if (!isStart) return;
			isStart = false;
			removeEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function loop(evt:Event):void
		{
			step();
		}
		
		private function checkNumChildren(evt:Event):void
		{
			if (numChildren == 0)
			{
				removeEventListener(Event.ENTER_FRAME, checkNumChildren);
				stop();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function bustAt(tx:Number = 0, ty:Number = 0, num:uint = 15, duration:Number = 1):void
		{
			_source.x = tx;
			_source.y = ty;
			start();
			_source.burst(num, duration);
		}
		
		private function buildParticle(C:Class):Particle
		{
			var pt:Particle = new Particle(C);
			
			pt.life = 30;
			pt.scaleVar = 0.7;
			pt.rate = .5;
			
			pt.initAlpha = 0;
			
			pt.direction = new Vector2D(0, -1);
			pt.directionVar = 45;
			pt.rotationVar = 40;
			pt.bidirectional = false;
			
			return pt;
		}
		
		public function destroy():void
		{
			stop();
			removeEventListener(Event.ENTER_FRAME, checkNumChildren);
			clear();
			EmitterGlobal.destroy(this);
			if (parent) parent.removeChild(this);
		}
		
		
		/***************************************
		 * 				Params
		 * *************************************/
		private var _uniformField	:UniformField;
		private var _source			:LineSource;		
		private var _ParticleClass	:Class;
		public var ptc:Particle;
		
		private var _scale:Number = 1;
		public function get scale():Number { return _scale; }	
		public function set scale(s:Number):void
		{
			_scale = s;
			
			ptc.rate = 1 * _length / 100;
			ptc.speed = 2;
			ptc.scale = 0.5;
			
			var life:Number = 100 * _scale;
			ptc.life = life;
			
			ptc.scaleDecayRange = life * 2 / 3;
			ptc.alphaGrowRange = life * 1 / 2;
		}
		
		public function get source():ParticleSource { return ParticleSource(_source); }
		
		private var _length:Number = 100;
		public function get length():Number { return _length; }
		public function set length(n:Number):void
		{
			_source.length = n;
			scale = _scale;
		}
	}
	
}