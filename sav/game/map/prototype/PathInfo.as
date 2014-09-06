package sav.game.map.prototype 
{
	import flash.display.Sprite;
	import sav.game.map.prototype.MapNode;
	import sav.game.map.prototype.Path;
	import sav.game.map.prototype.PathRecoard;

	/**
	 * ...
	 * @author sav
	 */

	public class PathInfo
	{
		public var path:Path;
		public var pathRecoard:PathRecoard;
		public var fromNode:MapNode;
		public var toNode:MapNode;
		public var clip:Sprite;
	}

}