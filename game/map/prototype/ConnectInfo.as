package sav.game.map.prototype
{
	public class ConnectInfo
	{
		public function ConnectInfo(node:MapNode, cost:Number = 1, path:Path = null, isInvertPath:Boolean = false):void
		{
			this.node = node;
			this.cost = cost;
			this.path = path;
			this.isInvertPath = isInvertPath;
		}
		
		public function destroy():void
		{
			node = null;
			path = null;
		}
		
		/************************
		*         params
		************************/
		public function toString():String
		{
			return "ConnectInfo : [node:" + node + ", cost:" + cost + ", path:" + path + ", invert:" + isInvertPath + "]";
		}
		
		public var node:MapNode;
		public var cost:Number;
		public var path:Path;
		public var isInvertPath:Boolean;
	}
}