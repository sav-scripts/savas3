package sav.effects.simpleswarm
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import sav.effects.swarm.swarm_namespace;
	use namespace swarm_namespace;
	
	public class SwarmPathPoint extends Point
	{
		swarm_namespace var _percent:Number;
		public function get percent():Number { return _percent; }
		
		public var swarmType:String;
		public var tPoints:Array;
		public var clip:DisplayObject;
		public var sample:SwarmSample;
		public var shifting:Boolean = false;
		
		public function SwarmPathPoint(percent:Number, targetClip:DisplayObject = null, tx:Number = Number.NaN, ty:Number = Number.NaN, swarmType:String = 'random')
		{
			this._percent = percent;
			this.clip = targetClip;
			this.x = (targetClip && isNaN(tx)) ? targetClip.x : tx;
			this.y = (targetClip && isNaN(ty)) ? targetClip.y : ty;
			this.tPoints = [];
			this.swarmType = swarmType;
		}
		
		public function cloneV2():SwarmPathPoint
		{
			var spp:SwarmPathPoint = new SwarmPathPoint(percent, null, x, y, swarmType);
			spp.tPoints = tPoints.concat([]);
			return spp;
		}
		
		public function destroy():void
		{
			clip = null;
			tPoints = null;
			if (sample) 
			{
				sample.destroy();
				sample = null;
			}
		}
	}
}