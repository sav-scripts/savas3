package sav.starling.effects 
{
	import caurina.transitions.Equations;
	import caurina.transitions.Tweener;
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.ParticleSystem_sav;
	import starling.extensions.PDParticle;
	import starling.extensions.PDParticleSystem_sav;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author sav
	 */
	public class RotateInEffect 
	{
		public function RotateInEffect(st:Starling, bitmapData:BitmapData) 
		{
			_st = st;
			_sourceBitmapData = bitmapData;
			
			var time:Number = 2;
			
			_ps = makeParticle();
		}
		
		private var _ps:PDParticleSystem_sav;
		
		public function showAt(container:DisplayObjectContainer, tx:Number, ty:Number):Sprite
		{
			var time:Number = .5;
			
			var ps:PDParticleSystem_sav = makeParticle();
			//var ps:PDParticleSystem_sav = _ps;
			
			ps.emitterX = tx;
			ps.emitterY = ty;
			
			if (!ps.parent) container.addChild(ps);
			
			_st.juggler.add(ps);
			
			ps.startSize = ps.texture.width * .5;
			ps.endSize = ps.texture.width * 1;
			ps.blendFactorSource = Context3DBlendFactor.SOURCE_ALPHA;
			ps.blendFactorDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			ps.lifespan = time;
			ps.start(time);
			//ps.startRotation = Math.PI/2;
			
			BlendMode.register("alpha", Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA, false);
			
			
			var img:Image = new Image(ps.texture);
			img.x = - img.width / 2;
			img.y = - img.height / 2;
			var sprite:Sprite = new Sprite();
			sprite.x = ps.emitterX;
			sprite.y = ps.emitterY;
			sprite.alpha = 1;
			sprite.addChild(img);
			
			Tweener.addTween(ps, { time:time, onComplete:psComplete, onCompleteParams:[ps, time, sprite] } );
			
			return sprite;
		}
		
		private function psComplete(ps:PDParticleSystem_sav, time:Number, sprite:Sprite):void
		{
			//REF.st.juggler.remove(ps);
			
			
			
			ps.parent.addChildAt(sprite, ps.parent.getChildIndex(ps));
			//sprite.blendMode = 'alpha';
			ps.addEventListener(Event.COMPLETE, particleComplete);
			
			sprite.alpha = 0;
			Tweener.addTween(sprite, { time:time, alpha:1, rotation:0, transition:Equations.easeNone } );
		}
		
		private function particleComplete(evt:Event):void
		{
			var ps:PDParticleSystem_sav = PDParticleSystem_sav(evt.currentTarget);
			ps.removeEventListener(Event.COMPLETE, psComplete);
			
			_st.juggler.remove(ps);
			if (ps.parent) ps.parent.removeChild(ps);
			ps.dispose();
		}
		
		
		
		public function makeParticle():PDParticleSystem_sav
		{
			var xml:XML = _particalXML;
			var texture:Texture = Texture.fromBitmapData(_sourceBitmapData);
			
			var ps:PDParticleSystem_sav = new PDParticleSystem_sav(xml, texture);
			
			return ps;
		}
		
		/**** params ****/
		private var _st:Starling;
		private var _sourceBitmapData:BitmapData;
		
		
		private var _particalXML:XML = 
<particleEmitterConfig>
  <texture name="texture.png"/>
  <sourcePosition x="300.00" y="300.00"/>
  <sourcePositionVariance x="0.00" y="0.00"/>
  <speed value="100.00"/>
  <speedVariance value="30.00"/>
  <particleLifeSpan value="1"/>
  <particleLifespanVariance value="0"/>
  <angle value="0"/>
  <angleVariance value="0"/>
  <gravity x="0.00" y="0.00"/>
  <radialAcceleration value="0.00"/>
  <tangentialAcceleration value="0.00"/>
  <radialAccelVariance value="0.00"/>
  <tangentialAccelVariance value="0.00"/>
  <startColor red="1" green="1" blue="1" alpha="0"/>
  <startColorVariance red="0.00" green="0.00" blue="0.00" alpha="0.00"/>
  <finishColor red="1.00" green="1" blue="1.00" alpha=".3"/>
  <finishColorVariance red="0.00" green="0.00" blue="0.00" alpha="0.00"/>
  <maxParticles value="10"/>
  <startParticleSize value="100"/>
  <startParticleSizeVariance value="0"/>
  <finishParticleSize value="100"/>
  <FinishParticleSizeVariance value="5.00"/>
  <duration value="-1.00"/>
  <emitterType value="1"/>
  <maxRadius value="0"/>
  <maxRadiusVariance value="0.00"/>
  <minRadius value="0.00"/>
  <rotatePerSecond value="0.00"/>
  <rotatePerSecondVariance value="0.00"/>
  <blendFuncSource value="770"/>
  <blendFuncDestination value="1"/>
  <rotationStart value="45.00"/>
  <rotationStartVariance value="0.00"/>
  <rotationEnd value="0.00"/>
  <rotationEndVariance value="0.00"/>
</particleEmitterConfig>;
		
	}

}