package sav.effects.emitter
{
	import flash.display.Sprite;
	import flash.events.Event;
	import idv.cjcat.emitter.Emitter;
	import idv.cjcat.emitter.EmitterGlobal;
	import idv.cjcat.emitter.fields.UniformField;
	import idv.cjcat.emitter.geom.Vector2D;
	import idv.cjcat.emitter.Particle;
	import idv.cjcat.emitter.PointSource;
	import idv.cjcat.emitter.fields.RadialField;
	import caurina.transitions.Tweener;
	import idv.cjcat.emitter.AddChildMode;
	
	[Event(name = 'complete', type = 'flash.events.Event')]
	
	public class Bubble extends Emitter
	{
		private var uniformField	:UniformField;
		private var source			:PointSource;		
		private var ParticleClass	:Class;
		public var particle:Particle;
		public var particle2:Particle;
		
		private var _scale:Number = 1;
		public function set scale(s:Number):void
		{
			_scale = s;
			uniformField.y = -0.4 - 1.5 * _scale;
			particle.rate = 4 * _scale;
			particle.speed = 4 + 12 * _scale;
			particle.scale = _scale;
			
			particle2.rate = 4 * _scale;
			particle2.speed = 4 + 12 * _scale;
			particle2.scale = _scale;
			
		}
		
		public function get scale():Number
		{
			return _scale;
		}		
		
		public function Bubble(C:Class)
		{
			ParticleClass = C;
			
			addChildMode = AddChildMode.TOP;	
			
			if (this.stage) init();
		}
		
		public function init(startAfter:Boolean = false):void
		{
			particle = buildParticle(ParticleClass);
			
			particle2 = buildParticle(ParticleClass);
			particle2.direction = new Vector2D(0, -1);
			particle2.bidirectional = false;
			
			uniformField = new UniformField(0, -2.4);
			particle.addGravity(uniformField);
			particle2.addGravity(uniformField);

			//set up source
			source = new PointSource();
			source.addParticle(particle);
			source.addParticle(particle2);

			//set up emitter
			addSource(source);
			
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
		
		private function buildParticle(C:Class):Particle
		{
			var pt:Particle = new Particle(C);
			pt.life = 30;
			pt.speed = 16;
			pt.scaleDecayRange = 20;
			//particle2.scaleGrowRange = 10;
			pt.scaleVar = 0.7;
			pt.scaleGrowRangeVar = 0;
			pt.rate = 3;
			//pt.alpha = 1;
			//pt.alphaVar = 1;
			//pt.finalAlpha = 0;
			//pt.alphaDecayRange = 15;
			pt.damping = 0.2;
			pt.direction = new Vector2D(1, 0);
			pt.directionVar = 45;
			pt.rotationVar = 0;
			pt.bidirectional = true;
			
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
	}
	
}