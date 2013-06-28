package sav.game.map.calculater
{
	import flash.utils.Dictionary;
	import sav.game.map.prototype.ConnectInfo;
	import sav.game.map.prototype.MapNode;
	import sav.utils.MyTrace;
	
	public class ConnectFinder_APlus
	{
		public static function find(fromNode:MapNode, toNode:MapNode, maxStep:int = 10000):Array
		{	
			MyTrace.recoardStart('Find Path_APlus');
			
			_step = 0;
			_targetNode = toNode;
			
			_calculatedDic = new Dictionary();
			_onSearchNodeDic = new Dictionary();
			
			_numSearchObj = 0;
			_searchObjDic = { };
			_costArray = [];
			_costArrayIndexDic = { };
			
			addSearchObj(new SearchObj(fromNode, [fromNode], 0, 0), 0);
			
			var res:Array;
			
			while (_step > -1)
			{
				//trace('num searchObj = ' + _numSearchObj);
				var searchObj:SearchObj = pickSearchObj();
				
				if (searchObj == null) 
				{
					trace('path impossible');
					break;
				}
				
				res = scanSearchObj(searchObj);
				
				//trace('res = ' + res);
				
				if (res != null)
				{
					//trace('found path');
					break;
				}
				
				
				
				_step ++;
				
				if (_step == maxStep)
				{
					trace('reach max step');
					break;
				}
			}
			
			
			_targetNode = null;
			_calculatedDic = null;
			_searchObjDic = null;
			_costArrayIndexDic = null;
			_costArray = null;
			_onSearchNodeDic = null;
			
			MyTrace.recoardStart('Find Path_APlus');
			
			//trace('total attempt = ' + _step);
			
			return res;
			
		}
		
		private static function scanSearchObj(searchObj:SearchObj):Array
		{
			
			var node:MapNode = searchObj.node;
			
			
			//trace('scanning ' + node.x + ', ' + node.y);
			
			var oldCostFromStartNode:Number = searchObj.costFromStartNode;
			var oldPath:Array = searchObj.path;
			//var goalNodes:
			
			for each(var connectInfo:ConnectInfo in node.neighborDic)
			{
				var connectNode:MapNode = connectInfo.node;
				if (_calculatedDic[connectNode]) continue;
				
				if (connectNode == _targetNode)
				{
					return oldPath.concat([connectNode]);
				}
				
				var dx:Number = _targetNode.x - connectNode.x;
				var dy:Number = _targetNode.y - connectNode.y;				
				var costToTarget:Number = Math.sqrt(dx * dx + dy * dy);
				
				var costFromStartNode:Number = oldCostFromStartNode + connectInfo.cost;
				var totalCost:Number = costToTarget + costFromStartNode;
				
				//trace('costFromStartNode = ' + costFromStartNode);
				
				var searchObj:SearchObj = new SearchObj(connectNode, oldPath.concat([connectNode]), costFromStartNode, 0);
				addSearchObj(searchObj, totalCost);
			}
			
			_calculatedDic[node] = true;
			
			return null;
		}
		
		private static function addSearchObj(searchObj:SearchObj, cost:Number):void
		{
			var searchingNode:MapNode = searchObj.node;
			if (_onSearchNodeDic[searchingNode]) return;
			
			var costIndex:int = int(cost * 100) * 1000;
			
			while (_searchObjDic[costIndex] != undefined)
			{
				costIndex += 1;
			}
			
			_onSearchNodeDic[searchingNode] = true;
			
			_searchObjDic[costIndex] = searchObj;
			
			var newCostArrayIndex:int = _costArray.push(costIndex) - 1;
			_costArrayIndexDic[costIndex] = newCostArrayIndex;
			
			_numSearchObj ++;
		}
		
		private static function pickSearchObj():SearchObj
		{
			if (_numSearchObj < 1) return null;
			
			
			var costIndex:int = Math.min.apply(null, _costArray);
			
			//trace('cost array = ' + _costArray);
			//trace('cost array length = ' + _costArray.length);
			//trace('cost index = ' + costIndex);
			
			var searchObj:SearchObj = _searchObjDic[costIndex];
			var costArrayIndex:int = _costArrayIndexDic[costIndex];
			//_costArray.splice(costArrayIndex, 1);
			_costArray[costArrayIndex] = uint.MAX_VALUE;
			
			delete _searchObjDic[costIndex];
			delete _costArrayIndexDic[costIndex];
			_numSearchObj --;			
			
			return searchObj;
		}

		
		/**********************
		 *       params
		 * *******************/
		private static var _calculatedDic:Dictionary;
		
		private static var _step:int;
		private static var _targetNode:MapNode;
		
		private static var _numSearchObj:int;
		
		private static var _searchObjDic:Object;
		private static var _costArray:Array;
		private static var _costArrayIndexDic:Object;
		
		private static var _onSearchNodeDic:Dictionary;
	}
}

import sav.game.map.prototype.MapNode;
class SearchObj
{
	public function SearchObj(node:MapNode, path:Array, costFromStartNode:Number = 0, numTurn:int = 0):void
	{
		this.node = node;
		this.path = path;
		this.numTurn = numTurn;
		this.costFromStartNode = costFromStartNode;
	}
	
	public var node:MapNode;
	public var path:Array;
	public var numTurn:int;
	public var costFromStartNode:Number;
}