package sav.game.map
{
	import caurina.transitions.Tweener;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import sav.game.map.calculater.ConnectFinder_NodeMap;
	import sav.game.map.calculater.PathBuilder;
	import sav.game.map.prototype.ConnectInfo;
	import sav.game.map.prototype.MapNode;	
	import sav.game.map.for_test.CirclePoint;
	import sav.game.map.prototype.Path;
	
	[Event(name = 'nodeClick', type = 'sav.game.map.TestMap')]
	public class TestMap extends NodeMap
	{	
		private function putCharAt(char:Character, nodeName:String):void
		{
			var node:MapNode = _mapNodeDic[nodeName];
			
			char.x = node.x;
			char.y = node.y;
			char.currentNode = node;
		}
		
		private function moveCharTo(char:Character, toNode:MapNode):void
		{
			if (toNode == char.currentNode) return;
			if (char.currentNode == null) return;
			
			var fromNode:MapNode = char.currentNode;
			char.currentNode = null;
			
			var nodeArray:Array = ConnectFinder_NodeMap.find(fromNode, toNode);
			
			var path:Path = PathBuilder.buildFromNodeArray(nodeArray).path;
			
			var time:Number = path.length / 100;
			
			Tweener.addTween(path, { time:time, position:path.length, 
				transition:'linear', 
				onUpdate:moveCharTo_onUpdate, onUpdateParams:[char, path], 
				onComplete:moveCharTo_onComplete, onCompleteParams:[char, toNode] } );
				
			
		}
		
		private function moveCharTo_onUpdate(char:Character, path:Path):void
		{
			var point:Point = path.location;
			char.x = point.x;
			char.y = point.y;
		}
		
		private function moveCharTo_onComplete(char:Character, targetNode:MapNode):void
		{
			char.currentNode = targetNode;
		}
		
		/*
		private function buildPaths(nodeArray:Array):Path
		{
			var i:uint = 0, l:uint = nodeArray.length - 1;
			var fromNode:MapNode;
			var toNode:MapNode;
			var connectInfo:ConnectInfo;
			var path:Path;
			var pointList:Vector.<Point>;
			//var res:Vector.<Point> = new Vector.<Point>;
			var newPath:Path = new Path();
			
			for (i = 0; i < l; i++)
			{
				fromNode = nodeArray[i];
				toNode = nodeArray[i + 1];
				
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
			}
			
			return newPath;
		}
		*/
		
		private function node_click(evt:MouseEvent):void
		{
			var cp:CirclePoint = CirclePoint(evt.currentTarget);
			
			moveCharTo(_char1, cp.node);
		}
		
		private function calculatePath(fromNode:MapNode, toNode:MapNode):void
		{
			//trace('calculating ' + fromNode.id + ' to ' + toNode.id + '');
			
			var result:Array = ConnectFinder_NodeMap.find(fromNode, toNode);
			
			var i:int, l:int = result.length;
			
			var g:Graphics = _resultPath.graphics;
			g.clear();
			g.lineStyle(1, 0xff0000);
			var node:MapNode = result[0];
			g.moveTo(node.x, node.y);
			
			for (i = 1; i < l; i++)
			{
				node = result[i];
				g.lineTo(node.x, node.y);
			}
			
			g.endFill();
		}
		
		/************************
		*         params
		************************/
		private var _lastCirclePoint:CirclePoint;
		private var _resultPath:Sprite;
		
		public var _char1:Character;
		
		/************************
		*         events
		************************/
		public static const NODE_CLICK:String = 'nodeClick';
	}
}
import flash.display.Sprite;
import sav.game.map.prototype.MapNode;
import flash.display.Graphics;

class Character extends Sprite
{
	public function Character():void
	{
		this.mouseEnabled = this.mouseChildren = false;
			
		var g:Graphics = this.graphics;
		g.lineStyle(3, 0);
		g.beginFill(0xff0000);
		g.drawCircle(0, 0, 10);
		g.endFill();
	}
	
	/************************
	*         params
	************************/
	public var currentNode:MapNode;
}