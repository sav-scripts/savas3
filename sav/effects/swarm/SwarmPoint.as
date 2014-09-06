package sav.effects.swarm
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import sav.effects.swarm.swarm_namespace;
	use namespace swarm_namespace;
	
	public class SwarmPoint extends Point
	{
		swarm_namespace var tx:Number;
		swarm_namespace var ty:Number;
		swarm_namespace var dx:Number = 0;
		swarm_namespace var dy:Number = 0;
		swarm_namespace var sampleType:String = 'source';
		swarm_namespace var percent:Number = 0;
		swarm_namespace var completed:Boolean = false;
		swarm_namespace var sample:SwarmSample;
		swarm_namespace var actived:Boolean = false;
		swarm_namespace var index:uint;
		
		public function SwarmPoint(index:uint, tx:Number, ty:Number, sample:SwarmSample)
		{
			x = tx;
			y = ty;
			this.index = index;
			this.tx = tx;
			this.ty = ty;
			this.sample = sample;
		}
		
		override public function offset(dx:Number, dy:Number):void 
		{
			this.dx += dx;
			this.dy += dy;			
			
			super.offset(dx, dy);
		}
	}
}