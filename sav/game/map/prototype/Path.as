package sav.game.map.prototype
{
	import fl.motion.BezierSegment;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	//import flash.geom.Point;
	
	[Event(name = 'arrived', type = 'sav.geom.prototype.Path')]
	public class Path extends EventDispatcher
	{	
		
		/**
		 * add a bezier segment to this path
		 * 
		 * @param	a	Point
		 * @param	b	Point
		 * @param	c	Point
		 * @param	d	Point
		 * @param	numSegmentType	String	"numSegments"(add numSegmentProperty segments into path) or "relative"(add length/numSegmentProperty segments into path )
		 * @param	numSegmentProperty	Number	a value depand on numSegmentType property
		 */
		public function addBezierSegment(a:Point, b:Point, c:Point, d:Point, numSegmentType:String = 'relative', numSegmentProperty:Number = 20):void
		{
			var bz:BezierSegment = new BezierSegment(a, b, c, d);
			
			var dt:Number;
			
			switch(numSegmentType)
			{
				case 'numSegments':
					dt = 1 / numSegmentProperty;
				break;
				
				case 'relative':
					var bl:Number = b.subtract(a).length + c.subtract(b).length + d.subtract(c).length;
					dt = numSegmentProperty / bl;
				break;
				
				default:
					throw new Error("illegal numSegmentType : " + numSegmentType);
			}
			
			var t:Number;
			
			for (t = 0; t < 1; t += dt)
			{
				var p:Point = bz.getValue(t);
				//if (t == 0 && _currentPosition && _currentPosition.x == p.x && _currentPosition.y == p.y) continue;
				add(p.x, p.y);
			}
			
			//p = bz.getValue(1);
			//add(p.x, p.y);
			add(d.x, d.y);
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
				
				if(oldPositionLength != _position) dispatchEvent(new Event(ARRIVED));
			}
			else if (_position <= 0) 
			{
				_position = 0;
				_currentNode_index = 0;
				_location = _pointList[_currentNode_index].clone();
				if(oldPositionLength != _position) dispatchEvent(new Event(ARRIVED));
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
		
		override public function toString():String 
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
		
		/************************
		*         events
		************************/
		public static const ARRIVED:String = 'arrived';
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