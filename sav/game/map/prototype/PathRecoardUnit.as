package sav.game.map.prototype
{
	
	import flash.geom.Point;

	public class PathRecoardUnit
	{
		public function PathRecoardUnit(type:String):void
		{
			this.type = type;
		}
		public var type:String;
		
		//public var tx:Number;
		//public var ty:Number;
		//public var tp:Point;
		
		public var a:Point;
		public var b:Point;
		public var c:Point;
		public var d:Point;
		public var numSegmentType:String;
		public var numSegmentProperty:Number;
		public var position:Number;
		
		public function toString():String
		{
			return '['+type+']:'+d+'\n';
		}
	}
}