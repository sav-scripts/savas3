package sav.game.map.prototype
{
	import flash.utils.Dictionary;
	
	public class MapNode
	{
		public function MapNode(id:String = ''):void
		{
			this.id = id;
			_neighborDic = new Dictionary();
		}
		
		/**
		 * connect two MapNodes with each others, connect them will create two ConnectInfos( A to B, and B to A ), if given path property, this path will assign to both ConnectInfos)
		 * @param	targetNode	MapNode	
		 * @param	cost	Number	A reference value of moving cost between two node
		 * @param	path	Path	
		 */
		public function connect(targetNode:MapNode, cost:Number = 1, path:Path = null):void
		{
			_neighborDic[targetNode] = new ConnectInfo(targetNode, cost, path);
			targetNode.neighborDic[this] = new ConnectInfo(this, cost, path, true);
		}
		
		/**
		 * connect with another node, but not doing inverse
		 * 
		 * @param	targetNode	MapNode
		 * @param	cost	Number	A reference value of moving cost between two node
		 * @param	path	Path
		 */
		public function connect_single(targetNode:MapNode, cost:Number = 1, path:Path = null):void
		{
			_neighborDic[targetNode] = new ConnectInfo(targetNode, cost, path);
		}
		
		public function removeConnect(targetNode:MapNode):void
		{
			delete _neighborDic[targetNode];
			delete targetNode.neighborDic[this];
		}
		
		public function removeConnect_single(targetNode:MapNode):void
		{
			delete _neighborDic[targetNode];
		}
		
		/**
		 * get ConnectInfo to target node(if it is connected)
		 * @param	node
		 * @return
		 */
		public function getConnectInfo(node:MapNode):ConnectInfo
		{
			return _neighborDic[node];
		}
		
		
		public function getPathCopyToNode(node:MapNode):Path
		{
			var connectInfo:ConnectInfo = getConnectInfo(node);
			
			if (connectInfo.isInvertPath) return connectInfo.path.getInvertPath();
			return connectInfo.path.clone();
		}
		
		public function isConnectedWith(node:MapNode):Boolean
		{
			return Boolean(_neighborDic[node]);
		}
		
		public function destroy():void
		{
			_neighborDic = null;
			relateTarget = null;
		}
		
		public function toString():String
		{	
			return "MapNode:[id: " + id + ", x:" + x + ", y:" + y + "]";
		}
		
		
		/**********************
		 *       params
		 * *******************/
		private var _neighborDic:Dictionary;
		public function get neighborDic():Dictionary { return _neighborDic; }
		
		public var relateTarget:*;
		
		public var x:Number;
		public var y:Number;
		
		public var id:String;
	}
}