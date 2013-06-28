package sav.game.map
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import sav.game.map.events.MapEvent;
	import sav.game.map.prototype.ConnectInfo;
	import sav.game.map.prototype.MapNode;
	import sav.game.map.prototype.Path;
	import sav.game.map.for_test.CirclePoint;
	import sav.game.map.prototype.PathRecoard;
	import sav.game.map.prototype.PathRecoardUnit;
	import sav.game.map.prototype.PathInfo;
	import sav.gp.BitmapUtils;
	
	[Event(name = 'nodeClick', type = 'sav.game.map.events.MapEvent')]
	[Event(name = 'nodeMouseOver', type = 'sav.game.map.events.MapEvent')]
	[Event(name = 'nodeMouseOut', type = 'sav.game.map.events.MapEvent')]
	[Event(name = 'pathClick', type = 'sav.game.map.events.MapEvent')]
	public class NodeMap extends Sprite
	{
		public function NodeMap(MapNodeClass:Class = null):void
		{
			_MapNodeClass = (MapNodeClass == null) ? MapNode : MapNodeClass;
			_pathLayer = new Sprite();
			addChild(_pathLayer);
		}
		
		/************************
		*        get data
		************************/
		public function getNodeById(id:String):MapNode
		{
			return _mapNodeDic[id];
		}
		
		/************************
		*         parse XML
		************************/
		public function parseXML(xml:XML):void
		{
			var sceneData:XML = xml.elements('Scene')[0];
			
			_sceneWidth = Number(sceneData.@width);
			_sceneHeight = Number(sceneData.@height);
			if ('@numSegmentType' in sceneData)_default_numSegmentType = String(sceneData.@numSegmentType);
			if ('@numSegmentProperty' in sceneData)_default_numSegmentProperty = Number(sceneData.@numSegmentProperty);
			
			var nodeList:XMLList = xml.elements("Node");
			var connectList:XMLList = xml.elements("Connect");
			
			for each(var nodeData:XML in nodeList)
			{
				processNodeData(nodeData);
			}
			
			for each(var connectData:XML in connectList)
			{
				processConnectData(connectData);
			}
		}
		
		protected function processNodeData(nodeData:XML):void
		{
			addNode(String(nodeData.@id), Number(nodeData.@x)*_scaleRate, Number(nodeData.@y)*_scaleRate);
		}
		
		/**
		 * 
		 * @param	id	String	a unique id of this node
		 * @param	x	Number
		 * @param	y	Number	
		 * @param	drawAndRegistIt	Boolean	if true, will draw interactiveObject and regist it into Dictionarys
		 * @return	return null if success, otherwise will return fail reason 
		 */
		public function addNode(id:String, x:Number, y:Number, drawAndRegistIt:Boolean = false):String
		{
			if (_mapNodeDic[id]) return "Duplicated mapd node id : " + id;
			
			var node:MapNode = new _MapNodeClass(id);
			node.x = x;
			node.y = y;
			
			_mapNodeDic[id] = node;
			
			if (drawAndRegistIt)
			{
				registNode(node, drawNode(node));
			}
			
			return null;
		}
		
		protected function processConnectData(connectData:XML):void
		{
			var fromNodeId:String = connectData.@from;
			var toNodeId:String = connectData.@to;
			var curveMode:String = String(connectData.@curveMode);
			var fromNode:MapNode = _mapNodeDic[fromNodeId];
			var toNode:MapNode = _mapNodeDic[toNodeId];
			
			if (curveMode != PathRecoard.BEZIER_CURVE) curveMode = PathRecoard.SINGLE_CURVE;
			
			if (!fromNode || !toNode) throw new Error("Illegal connect data from XML : \n" + connectData.toXMLString());
			
			var segmentList:XMLList = connectData.elements("Segment");
			
			var pathRecoard:PathRecoard = new PathRecoard(curveMode);
			
			var length:int = Number(segmentList.length());
			var i:int;
			
			var lastPoint:Point = new Point(fromNode.x, fromNode.y);
			
			pathRecoard.addPoint(lastPoint);
			
			
			for (i = 0; i < length; i++)
			{
				var segment:XML = segmentList[i];
				switch(String(segment.@type))
				{
					case "point":
						lastPoint = new Point(Number(segment.@x)*_scaleRate, Number(segment.@y)*_scaleRate);
						pathRecoard.addPoint(lastPoint);
					break;
					
					case "bezier":
						var a:Point = lastPoint;
						var b:Point = (curveMode == PathRecoard.BEZIER_CURVE) ? new Point(Number(segment.@bx)*_scaleRate, Number(segment.@by)*_scaleRate) : a;
						var c:Point = new Point(Number(segment.@cx)*_scaleRate, Number(segment.@cy)*_scaleRate);
						var d:Point = new Point(Number(segment.@dx)*_scaleRate, Number(segment.@dy)*_scaleRate);
						
						var numSegmentType:String = ('@nst' in segment) ? String(segment.@nst) : _default_numSegmentType;
						var numSegmentProperty:int = ('@nsp' in segment) ? Number(segment.@nsp) : _default_numSegmentProperty;
						
						//trace(segment.hasOwnProperty('numSegmentType'));
						//trace(Boolean('@nst' in segment));
						
						//pathRecoard.addPoint(a);
						
						//pathRecoard.addBezierSegment(a, b, c, d, segment.@numSegmentType, Number(segment.@numSegmentProperty));
						pathRecoard.addBezierSegment(a, b, c, d, numSegmentType, numSegmentProperty);
							
						lastPoint = d;
							
					break;
					
					default:
						throw new Error("unexpected segment type : " + segment.@type);
				}	
			}
			
			if ((lastPoint.x != toNode.x && lastPoint.y != toNode.y) || length == 0)
			{
				pathRecoard.addPoint(new Point(toNode.x, toNode.y));
			}
			
			connectTwoNode(fromNode, toNode, pathRecoard);
		}
		
		//public function connectTwoNode(fromNode:MapNode, toNode:MapNode, path:Path = null, doDrawPath:Boolean = false):void
		public function connectTwoNode(fromNode:MapNode, toNode:MapNode, pathRecoard:PathRecoard = null, doDrawPath:Boolean = false):void
		{
			if (pathRecoard == null)
			{
				pathRecoard = new PathRecoard();
				pathRecoard.addPoint(new Point(fromNode.x, fromNode.y));
				pathRecoard.addPoint(new Point(toNode.x, toNode.y));				
			}
			
			var path:Path = pathRecoard.getPath();
			
			fromNode.connect(toNode, path.length, path);
			
			var obj:PathInfo = new PathInfo();
			obj.path = path;
			obj.pathRecoard = pathRecoard;
			obj.fromNode = fromNode;
			obj.toNode = toNode;
			
			_pathInfoDic_path[path] = obj;
			
			if (doDrawPath)
			{
				var pathClip:Sprite = drawPath(path);
				
				if (pathClip)
				{
					pathClip.addEventListener(MouseEvent.CLICK, pathClicked);
					obj.clip = pathClip;
					_pathInfoDic_clip[pathClip] = obj;
				}
			}
		}
		
		public function changeNodePosition(node:MapNode, tx:Number, ty:Number):void
		{			
			for each(var connectInfo:ConnectInfo in node.neighborDic)
			{
				var path:Path = connectInfo.path;
				var pathInfo:PathInfo = _pathInfoDic_path[path];
				var pathRecoard:PathRecoard = pathInfo.pathRecoard;
				var pathRecoardUnit:PathRecoardUnit;
				var point:Point;
				
				if (connectInfo.isInvertPath)
				{
					pathRecoardUnit = pathRecoard.recoardList[pathRecoard.recoardList.length - 1];
				}
				else
				{
					pathRecoardUnit = pathRecoard.recoardList[0];
				}
				
				pathRecoardUnit.d.x = tx;
				pathRecoardUnit.d.y = ty;
				
				updatePath(path);
			}
			
			var clip:Sprite = _clipDic_node[node];
			clip.x = tx;
			clip.y = ty;
			
			node.x = tx;
			node.y = ty;
		}
		
		public function updatePath(path:Path):void
		{
			var pathInfo:PathInfo = _pathInfoDic_path[path];
			
			var fromNode:MapNode = pathInfo.fromNode;
			var toNode:MapNode = pathInfo.toNode;
			
			delete _pathInfoDic_path[path];
			
			var recoard:PathRecoard = pathInfo.pathRecoard;
			var clip:Sprite = pathInfo.clip;
			
			var newPath:Path = recoard.getPath();
			drawPath(newPath, clip);
			
			pathInfo.path = newPath;
			
			ConnectInfo(fromNode.neighborDic[toNode]).path = newPath;
			ConnectInfo(toNode.neighborDic[fromNode]).path = newPath;
			
			_pathInfoDic_path[newPath] = pathInfo;
		}
		
		/************************
		*         removing
		************************/
		public function removeNode(node:MapNode):void
		{			
			removeAllConnectFromNode(node);			
			
			var clip:Sprite = _clipDic_node[node];
			removeNodeListeners(clip);
			
			removeChild(clip);
			
			delete _mapNodeDic[node.id];			
			delete _nodeDic_clip[clip];
			delete _clipDic_node[node];
		}
		
		public function removeConnect(fromNode:MapNode, toNode:MapNode):Boolean
		{	
			var connectInfo:ConnectInfo = fromNode.neighborDic[toNode];
			if (!connectInfo) return false;
			removePath(connectInfo.path);
			
			fromNode.removeConnect(toNode);			
			connectInfo.destroy();
			return true;
		}
		
		public function removeAllConnectFromNode(node:MapNode):void
		{
			for (var nNode:* in node.neighborDic)
			{
				removeConnect(node, nNode);
			}
		}
		
		public function removePath(path:Path):void
		{
			var obj:PathInfo = _pathInfoDic_path[path];
			
			var clip:Sprite = obj.clip;
			
			if (clip)
			{
				clip.removeEventListener(MouseEvent.CLICK, pathClicked);
				_pathLayer.removeChild(clip);
			}
			
			delete _pathInfoDic_clip[clip];
			delete _pathInfoDic_path[path];
		}
		
		/*****************************************
		*        node interactive functions
		*****************************************/
		protected function addNodeListeners(clip:Sprite):void
		{
			clip.addEventListener(MouseEvent.CLICK, nodeClicked);
			clip.addEventListener(MouseEvent.MOUSE_OVER, nodeMouseOver);
			clip.addEventListener(MouseEvent.MOUSE_OUT, nodeMouseOut);
		}
		
		protected function removeNodeListeners(clip:Sprite):void
		{
			clip.removeEventListener(MouseEvent.CLICK, nodeClicked);
			clip.removeEventListener(MouseEvent.MOUSE_OVER, nodeMouseOver);
			clip.removeEventListener(MouseEvent.MOUSE_OUT, nodeMouseOut);
		}
		
		protected function nodeClicked(evt:MouseEvent):void
		{
			var sprite:Sprite = Sprite(evt.currentTarget);
			var node:MapNode = _nodeDic_clip[sprite];
			
			var event:MapEvent = new MapEvent(MapEvent.NODE_CLICK);
			event.node = node;
			event.clip = sprite;
			
			dispatchEvent(event);
		}
		
		protected function nodeMouseOver(evt:MouseEvent):void
		{
			var sprite:Sprite = Sprite(evt.currentTarget);
			var node:MapNode = _nodeDic_clip[sprite];
			
			var event:MapEvent = new MapEvent(MapEvent.NODE_MOUSE_OVER);
			event.node = node;
			event.clip = sprite;
			
			dispatchEvent(event);
		}
		
		protected function nodeMouseOut(evt:MouseEvent):void
		{
			var sprite:Sprite = Sprite(evt.currentTarget);
			var node:MapNode = _nodeDic_clip[sprite];
			
			var event:MapEvent = new MapEvent(MapEvent.NODE_MOUSE_OUT);
			event.node = node;
			event.clip = sprite;
			
			dispatchEvent(event);
		}
		
		protected function pathClicked(evt:MouseEvent):void
		{
			var clip:Sprite = Sprite(evt.currentTarget);
			var pathInfo:PathInfo = _pathInfoDic_clip[clip];
			var path:Path = pathInfo.path;
			
			var event:MapEvent = new MapEvent(MapEvent.PATH_CLICK);
			event.path = path;
			event.clip = clip;
			
			dispatchEvent(event);
		}
		
		/**************************
		*        inquires
		**************************/
		public function getInteractiveFromNode(mapNode:MapNode):Sprite
		{
			return _clipDic_node[mapNode];
		}
		
		public function getNodeFromInteractive(interactiveObject:Sprite):MapNode
		{
			return _nodeDic_clip[interactiveObject];
		}
		
		public function getInteractiveFromPath(path:Path):Sprite
		{
			return _pathInfoDic_path[path].clip;
		}
		
		public function getPathFromInteractive(interactiveObject:Sprite):Path
		{
			return _pathInfoDic_clip[interactiveObject].path;
		}
		
		public function getPathInfo(path:Path):PathInfo
		{
			return _pathInfoDic_path[path];
		}
		
		/************************
		*         draw methods
		************************/
		public function draw(drawNodes:Boolean = true, drawPaths:Boolean = true):void
		{
			clear();
			
			if (drawNodes)
			{				
				for each(var node:MapNode in _mapNodeDic)
				{
					var nodeClip:Sprite = drawNode(node);
					registNode(node, nodeClip);
				}
			}
			
			if (drawPaths)
			{
				for each (var pathInfo:PathInfo in _pathInfoDic_path)
				{
					var path:Path = pathInfo.path;
					var pathClip:Sprite = drawPath(path);
					
					if (pathClip)
					{
						pathClip.addEventListener(MouseEvent.CLICK, pathClicked);
						pathInfo.clip = pathClip;
						_pathInfoDic_clip[pathClip] = pathInfo;
					}
				}
			}
			
			_mapBound = getBounds(this);
		}
		
		protected function registNode(node:MapNode, nodeClip:Sprite):void
		{
			addNodeListeners(nodeClip);
					
			_nodeDic_clip[nodeClip] = node;
			_clipDic_node[node] = nodeClip;
		}
		
		protected function drawNode(node:MapNode):Sprite
		{	
			var sprite:CirclePoint = new CirclePoint();
			sprite.x = node.x;
			sprite.y = node.y;
			
			//node.relateTarget = sprite;
			
			addChild(sprite);
			
			sprite.useHandCursor = sprite.buttonMode = true;
			
			return sprite;
		}
		
		protected function drawPath(path:Path, targetClip:Sprite = null):Sprite
		{
			var sprite:Sprite = (targetClip == null) ? new Sprite() : targetClip;
			_pathLayer.addChild(sprite);
			
			var g:Graphics = sprite.graphics;
			g.clear();
			g.lineStyle(6, 0x333333);
			//g.lineStyle(5, 0x7891E7, 1);
			
			var pointList:Vector.<Point> = path.pointList;			
			var point:Point = pointList[0];
			
			g.moveTo(point.x, point.y);
			var i:uint, l:uint = pointList.length;
			for (i = 1; i < l; i++)
			{
				point = pointList[i];
				g.lineTo(point.x, point.y);
			}
					
			
			g.lineStyle(4, 0xeeeeee);
			point = pointList[0];			
			g.moveTo(point.x, point.y);
			for (i = 1; i < l; i++)
			{
				point = pointList[i];
				g.lineTo(point.x, point.y);
			}
			
			sprite.useHandCursor = sprite.buttonMode = true;
			
			return sprite;
		}
		
		/************************
		*         destroyer
		************************/
		public function clear():void
		{
			
		}
		
		public function destroy():void
		{
			_mapNodeDic = null;
			_pathInfoDic_path = null;
			_nodeDic_clip = null;
			_clipDic_node = null;
			
			if (parent) parent.removeChild(this);
		}
		
		/************************
		*         params
		************************/
		protected var _MapNodeClass:Class;
		
		protected var _sceneWidth:Number = 800;
		public function get sceneWidth():Number { return _sceneWidth; }
		
		protected var _sceneHeight:Number = 800;
		public function get sceneHeight():Number { return _sceneHeight; }
		
		protected var _default_numSegmentType:String = 'relative';
		public function get default_numSegmentType():String { return _default_numSegmentType; }
		
		protected var _default_numSegmentProperty:Number = 20;
		public function get default_numSegmentProperty():Number { return _default_numSegmentProperty; }
		
		protected var _pathLayer:Sprite;		
		
		protected var _clipDic_node:Dictionary = new Dictionary();
		public function get clipDic_node():Dictionary { return _clipDic_node; }
		
		protected var _nodeDic_clip:Dictionary = new Dictionary();
		public function get nodeDic_clip():Dictionary { return _nodeDic_clip; }
		
		protected var _mapNodeDic:Object = new Object();
		public function get mapNodeDic():Object { return _mapNodeDic; }
		
		protected var _pathInfoDic_clip:Dictionary = new Dictionary();
		public function pathInfoDic_clip():Dictionary { return _pathInfoDic_clip;}
		
		protected var _pathInfoDic_path:Dictionary = new Dictionary();
		public function get pathInfoDic_path():Dictionary { return _pathInfoDic_path; }
		
		protected var _mapBound:Rectangle;
		public function get mapBound():Rectangle { return _mapBound.clone(); }
		
		protected var _scaleRate:Number = 1;
	}
}