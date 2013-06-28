package sav.game.map.prototype 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import ng.objects.MapObject;
	/**
	 * ...
	 * @author sav
	 */
	public class MovingInfo 
	{
		public var type:String;
		
		public var lastNode:MapNode;
		public var nextNode:MapNode;
		
		public var oldPosition:Number;
		public var position:Number;
		public var speed:Number;
		public var doFlip:Boolean = true;
		
		public var obj:MapObject;
		//public var nodeList:Array;
		public var clip:Sprite;
		public var finalNode:MapNode;
		
		public var arrowShape:Shape;
		
		public var targetObj:MapObject;
		
		public var onCompleteFunc:Function;
		public var onCompleteParams:Array;
		
		public var onNodeFunc:Function;
		public var onNodeParams:Array;
		
		public function get restPathLength():Number { return path.length - position; }
		
		private var _path:Path;
		public function get path():Path { return _path; }
		public function set path(p:Path):void
		{
			_path = p;
			jumpingGap = _path.length / int(_path.length / 30);
		}
		
		public var jumpingGap:Number = 0;
		
	}

}