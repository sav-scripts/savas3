package sav.effects.swarm
{
	import flash.geom.Point;
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
		swarm_namespace var sample:SwarmSample;
		
		public function SwarmPoint(tx:Number, ty:Number, sample:SwarmSample)
		{
			x = tx;
			y = ty;
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