package sav.geom.path
{
	import flash.geom.Point;
	
	public class Path
	{
		public function Path(minNodesDistance:Number = 1)
		{
			_minNodesDistance = minNodesDistance;
		}
		
		/**
		 * 
		 * @param	px0  Number  anchorX0, if it is Number.NaN, will use path's last location x instead
		 * @param	py0  Number  anchorY0, if it is Number.NaN, will use path's last location y instead
		 * @param	px1  Number  controlX0
		 * @param	py1  Number  controlY0
		 * @param	px2  Number  controlX1
		 * @param	py2  Number  controlY1
		 * @param	px3  Number  anchorX1
		 * @param	py3  Number  anchorY1
		 * @param	curveCropType  String	"numSegments"(add cropProperty segments into path) or "relative"(add length/cropProperty segments into path )
		 * @param	cropProperty  Number	a value depand on curveCropType property
		 */
		public function addQubicBezier(px0:Number, py0:Number, px1:Number, py1:Number, px2:Number, py2:Number, px3:Number, py3:Number, curveCropType:String = "relative", cropProperty:Number = 20):void
		{
			if (isNaN(px0)) px0 = _currentPosition.x;
			if (isNaN(py0)) py0 = _currentPosition.y;
			
			var dt:Number;
			
			switch(curveCropType)
			{
				case PathCurveCropType.NUM_SEGMENTS:
					dt = 1 / cropProperty;
				break;
				
				case PathCurveCropType.RELATIVE:
					var bl:Number = 
						Math.sqrt((px1 - px0) * (px1 - px0) + (py1 - py0) * (py1 - py0)) + 
						Math.sqrt((px2 - px1) * (px2 - px1) + (py2 - py1) * (py2 - py1)) + 
						Math.sqrt((px3 - px2) * (px3 - px2) + (py3 - py2) * (py3 - py2));
					var numSegments:int = int(bl / cropProperty);
					dt = 1 / numSegments;
				break;
				
				default:
					throw new Error("illegal curveCropType : " + curveCropType);
			}
			
			var t:Number, invertT:Number, t_p2:Number, invertT_p2:Number,t_p3:Number, invertT_p3:Number;
			var tx:Number, ty:Number;
			
			for (t = 0; t <= 1; t += dt)
			{
				invertT = (1 - t);
				t_p2 = t * t;
				invertT_p2 = invertT * invertT;
				t_p3 = t * t * t;
				invertT_p3 = invertT * invertT * invertT;
				
				tx = (px0 * invertT_p3) + (3 * px1 * t * invertT_p2) + (3 * px2 * t_p2 * invertT) + (px3 * t_p3);
					
				ty = (py0 * invertT_p3) +  (3 * py1 * t * invertT_p2) + (3 * py2 * t_p2 * invertT) + (py3 * t_p3);
				
				add(tx, ty);
			}
			
			add(px3, py3);
		}
		
		public function addQubicBezier_point(p0:Point, p1:Point, p2:Point, p3:Point, curveCropType:String = "relative", cropProperty:Number = 20):void
		{
			addQubicBezier(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, curveCropType, cropProperty);
		}
		
		/**
		 * 
		 * @param	px0  Number  anchorX0, if it is Number.NaN, will use path's last location x instead
		 * @param	py0  Number  anchorY0, if it is Number.NaN, will use path's last location y instead
		 * @param	px1  Number  controlX
		 * @param	py1  Number  controlY
		 * @param	px2  Number  anchorX1
		 * @param	py2  Number  anchorY1
		 * @param	curveCropType
		 * @param	cropProperty
		 */
		public function addQuadBezier( px0:Number, py0:Number, px1:Number, py1:Number, px2:Number, py2:Number, curveCropType:String = "relative", cropProperty:Number = 20):void
		{
			if (isNaN(px0)) px0 = _currentPosition.x;
			if (isNaN(py0)) py0 = _currentPosition.y;
			
			var dt:Number;
			
			switch(curveCropType)
			{
				case PathCurveCropType.NUM_SEGMENTS:
					dt = 1 / cropProperty;
				break;
				
				case PathCurveCropType.RELATIVE:
					var bl:Number = 
						Math.sqrt((px1 - px0) * (px1 - px0) + (py1 - py0) * (py1 - py0)) + 
						Math.sqrt((px2 - px1) * (px2 - px1) + (py2 - py1) * (py2 - py1));
					var numSegments:int = int(bl / cropProperty);
					dt = 1 / numSegments;
				break;
				
				default:
					throw new Error("illegal curveCropType : " + curveCropType);
			}
			
			var t:Number, invertT:Number, t_p2:Number, invertT_p2:Number;
			var tx:Number, ty:Number;
			
			for (t = 0; t <= 1; t += dt)
			{
				invertT = (1 - t);
				t_p2 = t * t;
				invertT_p2 = invertT * invertT;
				tx = (invertT_p2 * px0) + (2 * t * invertT * px1) + (t_p2 * px2);
				ty = (invertT_p2 * py0) + (2 * t * invertT * py1) + (t_p2 * py2);
				
				add(tx, ty);
			}
			
			add(px2, py2);
		}
		
		public function addQuadBezier_point(p0:Point, p1:Point, p2:Point, curveCropType:String = "relative", cropProperty:Number = 20):void
		{
			addQuadBezier(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, curveCropType, cropProperty);
		}
		
		/**
		 * add new point to path
		 * 
		 * @param	tx	Number
		 * @param	ty	Number
		 * @param	forceAdd	Boolean		force add this point even if new point is same as last point
		 */
		public function add(tx:Number, ty:Number, forceAdd:Boolean = false):void
		{
			if (forceAdd == false && _currentPosition && tx == _currentPosition.x && ty == _currentPosition.y) return;
			if (forceAdd == false && _minNodesDistance > 0 && _currentPosition)
			{
				var dx0:Number = tx - _currentPosition.x;
				var dy0:Number = ty - _currentPosition.y;
				
				if (Math.sqrt(dx0 * dx0 + dy0 * dy0) <= _minNodesDistance)
				{
					//trace('check');
					//return;
					removeLastPoint();
				}
			}
			
			_currentPosition = new Point(tx, ty);
			
			//var newNode: = new Point(tx, ty);
			var newNode:Point = new Point();
			newNode.x = tx;
			newNode.y = ty;
			
			_pointList.push(newNode);
			
			if (_pointList.length == 1)
			{
				_location = new Point(tx, ty);
				_position = 0;
				
				_currentNode_index = 0;
				_segmentDic.push(new Segment());
				
				_length = 0;
			}
			else
			{
				var index:uint = _pointList.length - 2;
				
				var lastNode:Point = _pointList[index];				
				//var newLength:Number = getLength(newNode, lastNode);
				
				var dx:Number = newNode.x - lastNode.x;
				var dy:Number = newNode.y - lastNode.y;
				var newLength:Number = Math.sqrt(dx * dx + dy * dy);
				var vx:Number = dx / newLength;
				var vy:Number = dy / newLength;
				
				
				_length = _length + newLength;	
				
				var oldSegment:Segment = _segmentDic[index];
				
				oldSegment.endMark = _length;
				oldSegment.length = newLength;
				oldSegment.vx = vx;
				oldSegment.vy = vy;
				
				_segmentDic.push(new Segment(index + 1, _length));
			}
		}
		
		public function removeLastPoint():void
		{
			if (_pointList.length <= 1) throw new Error("path have no segment yet");
			var lastPoint:Point = _pointList.pop();
			
			_segmentDic.pop();
			var lastSegment:Segment = _segmentDic[_segmentDic.length - 1];
			
			var lastSegmentLength:Number = lastSegment.length;
			lastSegment.length = 0;
			lastSegment.endMark = 0;
			lastSegment.vx = 0;
			lastSegment.vy = 0;
			
			
			_currentPosition = _pointList[_pointList.length - 1].clone();
			//trace("current position = " + _currentPosition);
			//trace('last point = ' + lastPoint);
			//trace('last segment = ' + lastSegment);
			_length -= lastSegmentLength;;
		}
		
		public function breakAt(breakPosition:Number):Object
		{
			var result:Object = { };
			
			if (breakPosition == 0)
			{
				result.pathToStart = null;
				result.pathToEnd = this.clone();
			}
			else if(breakPosition == _length)
			{
				result.pathToStart = this.getInvertPath();
				result.pathToEnd = null;
			}
			else
			{	
				var oldPosition:Number = position;
				toPosition(breakPosition);
				var firstPoint:Point = location;
				toPercent(oldPosition);
				
				var i:int, l:int = _pointList.length, point:Point;
				var pathToStart:Path = new Path();
				var pathToEnd:Path = new Path();
				
				pathToStart.add(firstPoint.x, firstPoint.y);
				pathToEnd.add(firstPoint.x, firstPoint.y);
				
				
				var lastSegmentIndex:uint = getLastSegmentIndex(breakPosition);
				var lastSegment:Segment = _segmentDic[lastSegmentIndex];
				
				i = lastSegmentIndex;
				while (i >= 0)
				{
					point = _pointList[i];
					pathToStart.add(point.x, point.y);
					i--;
				}
				
				i = lastSegmentIndex;
				if (lastSegment.startMark < breakPosition) i++;
				while (i < l)
				{
					point = _pointList[i];
					pathToEnd.add(point.x, point.y);
					i++;
				}
				
				result.pathToStart = pathToStart;
				result.pathToEnd = pathToEnd;
				
				//trace('path to start = ' + pathToStart);
				//trace('path to end = ' + pathToEnd);
			}
			
			return result;
		}
		
		public function getLastSegmentIndex(targetPosition:Number):uint
		{
			if (targetPosition < 0 || targetPosition > _length) throw new Error('unexpected target position');
			
			var i:uint, l:uint = _segmentDic.length;
			
			for (i = 0; i < l; i++)
			{
				var segment:Segment = _segmentDic[i];
				if (segment.startMark <= targetPosition && segment.endMark > targetPosition)
				{
					return i;
				}
			}
			
			return l - 1;
		}
		
		/**
		 * move position according to given percent value	
		 * 
		 * @param	n	Number
		 */
		public function toPercent(n:Number):void
		{
			toPosition(n * _length);
		}
		
		/**
		 * move position according to given length
		 * 
		 * @param	targetLength	Number
		 */
		public function toPosition(targetLength:Number):void
		{
			if (targetLength > length) targetLength = length;
			if (targetLength < 0) targetLength = 0;
			
			move(targetLength - _position);
		}
		
		/**
		 * move some range, according to current position
		 * 
		 * @param	range	:Number
		 */
		public function move(range:Number):void
		{
			if (range == 0) return;
			
			var oldPositionLength:Number = _position;
			
			_position += range;
			
			if (_position >= _length)
			{
				_position = _length;
				_currentNode_index = _pointList.length - 1;
				_location = _pointList[_currentNode_index].clone();
			}
			else if (_position <= 0) 
			{
				_position = 0;
				_currentNode_index = 0;
				_location = _pointList[_currentNode_index].clone();
			}
			else
			{
				var segment:Segment;
				var node:Point;
				var dLength:Number;
				var i:int;
				var startIndex:int;
				var endIndex:int;
				
				if (range > 0)
				{
					startIndex = _currentNode_index;
					endIndex = _segmentDic.length - 1;
					
					for (i = startIndex; i < endIndex; i++)
					{
						segment = _segmentDic[i];
						if (segment.endMark > _position) break;
					}
				}
				else
				{
					startIndex = _currentNode_index;
					endIndex = 0;
					
					for (i = startIndex; i >= endIndex; i--)
					{
						segment = _segmentDic[i];
						if (segment.startMark < _position) break;
					}
				}
				
				_currentNode_index = i;
				node = _pointList[_currentNode_index];
				
				dLength = _position - segment.startMark;
				
				_location.x = node.x + (dLength * segment.vx);
				_location.y = node.y + (dLength * segment.vy);
				
				
				//trace('position = ' + _position);
				//trace('currentNode_index = ' + _currentNode_index);
			}
		}
		
		/************************
		*      misc methods
		************************/
		private function getLength(p1:Object, p0:Object):Number
		{
			return Math.sqrt((p1.x - p0.x) * (p1.x - p0.x) + (p1.y - p0.y) * (p1.y - p0.y));
		}
		
		public function toString():String 
		{
			var string:String = "Path : ";
			
			var i:uint, l:uint = _pointList.length;
			
			for (i = 0; i < l; i++)
			{
				if (i != 0) string += "-";
				var point:Point = _pointList[i];
				string += "[" + int(point.x) + "," + int(point.y) + "]";
			}
			
			return string;
		}
		
		public function getLocationAt(targetPosition:Number):Point
		{
			var oldPosition:Number = position;
			position = targetPosition;
			var result:Point = location;
			position = oldPosition;
			
			return result;
		}
		
		/************************
		*         clone
		************************/
		public function clone():Path
		{
			var path:Path = new Path();
			
			path._currentPosition = _currentPosition.clone();
			path._pointList = _pointList.concat(new Vector.<Point>);
			path._segmentDic = _segmentDic.concat(new Vector.<Segment>);
			path._currentNode_index = _currentNode_index;
			path._currentNode_length = _currentNode_length;
			path._length = _length;
			path._position = _position;
			path._location = _location.clone();
			
			return path;
		}
		
		public function getInvertPath():Path
		{
			var path:Path = new Path();
			
			var i:int, startIndex:int = _pointList.length - 1, endIndex:int = 0;
			
			
			for (i = startIndex; i >= endIndex; i--)
			{
				var point:Point = _pointList[i];
				path.add(point.x, point.y);
			}
			
			return path;
		}
		
		/*****************
		 * 	   parms
		 * **************/
		private var _currentPosition:Point;
		 
		private var _pointList:Vector.<Point> = new Vector.<Point>;
		public function get pointList():Vector.<Point> { return _pointList; }
		
		private var _segmentDic:Vector.<Segment> = new Vector.<Segment>;		
		private var _currentNode_index:uint = 0;		
		private var _currentNode_length:Number = 0;
		
		
		private var _length:Number = 0;		
		public function get length():Number { return _length; }
		
		private var _position:Number = 0;
		public function get position():Number { return _position; }
		public function set position(n:Number):void
		{
			if (_position == n) return;
			move(n - _position);
		}
		
		private var _location:Point
		public function get location():Point
		{
			return _location.clone();
		}
		
		public function get numSegments():int { return _pointList.length - 1; }
		
		public function get percent():Number { return _position / _length; }
		
		private var _minNodesDistance:Number = 0;
		
		/************************
		*         events
		************************/
	}
}

class Segment
{
	public function Segment(nodeIndex:uint = 0, startMark:Number = 0, endMark:Number = 0, length:Number = 0, vx:Number = 0, vy:Number = 0):void
	{
		this.nodeIndex = nodeIndex;
		this.startMark = startMark;
		this.endMark = endMark;
		this.length = length;
		this.vx = vx;
		this.vy = vy;
	}
	
	public function toString():String
	{
		return "[nodeIndex:" + nodeIndex + ", startMark:" + startMark + ", endMark:" + endMark + ", length:" + length + ", vx:" + vx + ", vy:" + vy + "]";
	}
	
	public var nodeIndex:uint;
	public var startMark:Number;
	public var endMark:Number;
	public var length:Number;
	public var vx:Number;
	public var vy:Number;
	//public var isBezierStart:Boolean = false;
	//public var numSegmentsToBezierEnd:uint = 0;
	//public var isBezierEnd:Boolean = false;
	//public var numSegmentsToBezierStart:uint = 0;
}