package sav.effects.swarm
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import sav.utils.ArrayUtils;
	import sav.effects.swarm.swarm_namespace;
	use namespace swarm_namespace;
	
	dynamic public class SwarmPath extends Array
	{			
		
		public function add(percent:Number, displayObject:DisplayObject = null, tx:Number = Number.NaN, ty:Number = Number.NaN, type:String = 'random'):void
		{			
			var spp:SwarmPathPoint = new SwarmPathPoint(percent, displayObject, tx, ty, type);
			addSPP(spp);
		}
		
		
		public function addSPP(swarmPathPoint:SwarmPathPoint):void
		{
			var index:int = ArrayUtils.searchIndex(this, 'percent', swarmPathPoint.percent);
			if (index != -1)
			{
				this[index] = swarmPathPoint;
			}
			else
			{			
				this.push(swarmPathPoint);
				this.sortOn('percent' , Array.NUMERIC);
			}
		}
		
		public function lastPointHasSample(index:uint):SwarmPathPoint
		{
			for (var i:uint = index; i >= 0; i--)
			{
				if (this[i].sample) return this[i];
			}
			return null;
		}
		
		public function nextPointHasSample(index:uint):SwarmPathPoint
		{
			for (var i:uint = index+1; i < this.length; i++)
			{
				if (this[i].sample) return this[i];
			}
			return null;		
		}
		
		/*
		public function getPosition(percent:Number):Point
		{
			var i:uint, l:uint = length - 1;
			var fromPoint:SwarmPathPoint;
			var towardPoint:SwarmPathPoint;
			for (i = 0; i < l; i++)
			{
				fromPoint = this[i];
				towardPoint = this[i + 1];
				if (percent >= fromPoint.percent && percent < towardPoint.percent) break;
			}
			return null;
		}
		*/
	}
}