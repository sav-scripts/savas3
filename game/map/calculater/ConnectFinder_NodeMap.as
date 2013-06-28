package sav.game.map.calculater
{
	import flash.utils.Dictionary;
	import sav.game.map.prototype.ConnectInfo;
	import sav.game.map.prototype.MapNode;
	import sav.utils.MyTrace;
	public class ConnectFinder_NodeMap
	{
		public static function find(fromNode:MapNode, toNode:MapNode, extraTestFunc:Function = null):Object
		{
			if (fromNode == toNode) return { type:RESULT_SAME_NODE, nodeList:[], cost:0 };
			
			_extraTestFunc = extraTestFunc;
			
			//MyTrace.recoardStart('ConnectFined_NodeMap');
			
			_fromNode = fromNode;
			_toNode = toNode;
			
			_step = 0;
			
			_goalList = [];
			
			_searchingList = new Vector.<SearchObj>;
			
			_ignoreNodeDic = new Dictionary();	
			
			
			var searchObj:SearchObj = new SearchObj(_fromNode);
			searchObj.nodeList.push(_fromNode);
			
			_searchingList.push(searchObj);
			
			while (_searchingList.length > 0)
			{
				_step ++;
				
				var searchingDic:Vector.<SearchObj> = _searchingList;
				_searchingList = new Vector.<SearchObj>;
				
				for each (searchObj in searchingDic)
				{
					calculate(searchObj);
				}
				
				if (_goalList.length > 0) break;
			}
			
			//var result:Array;
			var result:Object = { };
			
			if (_goalList.length > 0)
			{
				_goalList.sortOn('cost', Array.NUMERIC);
				result.nodeList = SearchObj(_goalList[0]).nodeList;
				result.cost = SearchObj(_goalList[0]).cost;
				result.type = RESULT_FIND;
				//trace('goal cost = ' + SearchObj(_goalList[0]).cost);
			}
			else
			{
				trace("Can't find path");
				result.type = RESULT_NOT_FIND;
			}
			
			_fromNode = null;
			_toNode = null;
			_goalList = null;
			_searchingList = null;
			_ignoreNodeDic = null;
			
			//trace('step = ' + _step);
			//MyTrace.recoardStart('ConnectFined_NodeMap');
			
			return result;
			
		}
		
		private static function calculate(searchObj:SearchObj):void
		{
			var node:MapNode = searchObj.node;			
			_ignoreNodeDic[node] = true;
			
			for each(var connectInfo:ConnectInfo in node.neighborDic)
			{
				var connectNode:MapNode = connectInfo.node;		
				
				if (_ignoreNodeDic[connectNode]) continue;
				
				if (_extraTestFunc != null)
				{
					if (_extraTestFunc.apply(null, [connectNode]) === false) continue;
				}
				
				var newSearchObj:SearchObj = new SearchObj(connectNode);
				newSearchObj.nodeList = searchObj.nodeList.slice(0);
				
				newSearchObj.nodeList.push(connectNode);
				newSearchObj.cost = searchObj.cost + connectInfo.cost;
				
				_searchingList.push(newSearchObj);
				
				if (connectNode == _toNode) _goalList.push(newSearchObj);
			}
		}
		
		
		
		/************************
		*         params
		************************/
		private static var _fromNode:MapNode;
		private static var _toNode:MapNode;
		private static var _goalList:Array;
		private static var _searchingList:Vector.<SearchObj>;
		private static var _step:uint = 0;
		
		private static var _ignoreNodeDic:Dictionary;
		
		public static const RESULT_FIND:String = 'find';
		public static const RESULT_NOT_FIND:String = 'notFind';
		public static const RESULT_SAME_NODE:String = 'sameNode';
		
		public static var _extraTestFunc:Function;
	}
}


import sav.game.map.prototype.MapNode;

class SearchObj
{
	public function SearchObj(node:MapNode):void
	{
		this.node = node;
	}
	
	public var nodeList:Array = [];
	public var node:MapNode;
	public var cost:Number = 0;
}