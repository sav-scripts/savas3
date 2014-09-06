package sav.game.map.calculater
{
	import flash.geom.Point;
	import sav.game.map.prototype.ConnectInfo;
	import sav.game.map.prototype.MapNode;
	import sav.game.map.prototype.Path;
	public class PathBuilder
	{	
		/**
		 * 
		 * @param	nodeList	a array of nodes, they must connect with each others
		 * @return	return a connected path from all nodes on list
		 */
		//public static function buildFromNodeList(nodeList:Array):MovingProgress
		public static function buildFromNodeList(nodeList:Array):Object
		{
			var i:uint = 0, l:uint = nodeList.length - 1;
			var fromNode:MapNode;
			var toNode:MapNode;
			var connectInfo:ConnectInfo;
			var path:Path;
			var pointList:Vector.<Point>;
			var newPath:Path = new Path();
			
			var result:Object = { };
			var totalPosition:Number = 0;
			var recoards:Array = [];
			
			for (i = 0; i < l; i++)
			{
				fromNode = nodeList[i];
				toNode = nodeList[i + 1];
				
				
				connectInfo = fromNode.getConnectInfo(toNode);
				path = connectInfo.path;
				pointList = path.pointList.slice(0);
				if (connectInfo.isInvertPath) pointList.reverse();
				
				var index:uint; 
				var startIndex:uint = (i == 0) ? 0 : 1;
				var endIndex:uint = pointList.length;
				
				for (index = startIndex; index < endIndex; index++)
				{
					var point:Point = pointList[index];					
					newPath.add(point.x, point.y);
				}
				
				totalPosition += path.length;
				
				recoards.push( { position:totalPosition, node:toNode } );
			}
			
			result.path = newPath;
			result.recoards = recoards;
			
			return result;
		}
		
		public static function getLengthFromNodeList(nodeList:Array):Number
		{
			var i:uint = 0, l:uint = nodeList.length - 1;
			var fromNode:MapNode;
			var toNode:MapNode;
			var connectInfo:ConnectInfo;
			var path:Path;
			
			var length:Number = 0;
			
			for (i = 0; i < l; i++)
			{
				fromNode = nodeList[i];
				toNode = nodeList[i + 1];
				
				connectInfo = fromNode.getConnectInfo(toNode);
				path = connectInfo.path;
				
				length += path.length;
			}
			
			return length;
		}
	}
}