package sav.game.map.prototype
{
	import flash.geom.Point;
	
	public class PathRecoard
	{	
		public function PathRecoard(curveMode:String = 'single')
		{	
			this.curveMode = curveMode;
		}
		
		public function clear():void
		{
			_recoardList = new Vector.<PathRecoardUnit>;
		}
		
		public function addPoint(targetPoint:Point, targetIndex:int = -1):void
		{
			var recoard:PathRecoardUnit = new PathRecoardUnit(PathRecoardType.POINT);
			//recoard.tp = targetPoint;
			recoard.d = targetPoint;
			
			if (targetIndex == -1)
			{
				_recoardList.push(recoard);
			}
			else
			{
				_recoardList.splice(targetIndex, 0, recoard);
			}
		}
		
		public function addBezierSegment(a:Point, b:Point, c:Point, d:Point, numSegmentType:String = 'relative', numSegmentProperty:Number = 20):void
		{
			//addPoint(a);
			
			var recoard:PathRecoardUnit = new PathRecoardUnit(PathRecoardType.BEZIER);
			recoard.a = a;
			recoard.b = b;
			recoard.c = c;
			recoard.d = d;
			recoard.numSegmentType = numSegmentType;
			recoard.numSegmentProperty = numSegmentProperty;
			
			_recoardList.push(recoard);
			
			
			//addPoint(d);
		}
		
		public function bezierToPoint(segmentIndex:uint):Boolean
		{
			if (segmentIndex >= _recoardList.length) return false;
			
			var segment:PathRecoardUnit = _recoardList[segmentIndex];
			
			segment.a = segment.b = segment.c = null;
			segment.type = PathRecoardType.POINT;
			
			return true;
		}
		
		public function removeSegmentByIndex(index:int):Boolean
		{
			if (index >= _recoardList.length) return false;
			
			var nextSegment:PathRecoardUnit, prevSegment:PathRecoardUnit;
			
			if (index != 0 && index != (_recoardList.length - 1))
			{
				nextSegment = _recoardList[index + 1];
				prevSegment = _recoardList[index - 1];
				
				if (nextSegment.type == PathRecoardType.BEZIER)
				{
					nextSegment.a = prevSegment.d;
				}
			}
			
			
			_recoardList.splice(index, 1);
			
			return true;
		}
		
		/**
		 * inset a point into path, return index of new point
		 * @param	targetPoint		Point	a position close to path
		 * @param	minDistance		Number	how far should path to targetPoint at least, if no position on path which distance to targetPoint is smaller than this value, will return -1
		 * @return	new point(segment) index in path
		 */
		public function insertPoint(targetPoint:Point, minDistance:Number = 10):int
		{
			//trace('edit clip mouse down at ' + targetPoint);
			
			var obj:Object = findClosestPoint(targetPoint, minDistance);
			
			if (obj == null) return -1;
			
			var closestPoint:Point = obj.point;
			var closestPosition:Number = obj.position;
			
			var segmentIndex:int = findIndexByPosition(closestPosition);
			
			//trace('old list = ' + _recoardList);			
			var lastPoint:Point = _recoardList[segmentIndex].d;
			_recoardList.splice(segmentIndex, 1);
			addPoint(lastPoint, segmentIndex);
			addPoint(closestPoint, segmentIndex);
			//trace('new list = ' + _recoardList);
			
			return segmentIndex;
		}
		
		public function findClosestPoint(targetPoint:Point, minDistance:Number = 10):Object
		{
			var obj:Object = { };
			
			var path:Path = getPath();
			path.position = 0;
			
			var d:Number = 0;
			var minPosition:Number;
			var minLocation:Point;
			var oldMinDistance:Number = minDistance;
			
			while (d < path.length)
			{
				d++;
				path.position = d;
				
				var loc:Point = path.location.subtract(targetPoint);
				if (loc.length < minDistance)
				{
					minPosition = d;
					minLocation = path.location.clone();
					minDistance = loc.length;
				}
			}
			
			if (oldMinDistance == minDistance) return null;
			
			obj.position = minPosition;
			obj.point = minLocation;
			
			//trace('found cloest loc = ' + minLocation + ', on position ' + minPosition);
			
			return obj;
		}
		
		public function findIndexByPosition(targetPosition:Number):int
		{
			var i:int, l:int = _recoardList.length;
			for (i = 1; i < l; i++)
			{
				var length:Number = getPositionByIndex(i);
				if (length >= targetPosition) break;
			}
			
			//trace('target index = ' + i);
			if (i >= _recoardList.length) i = _recoardList.length - 1;
			
			return i;
		}
		
		public function toCurve(numSegmentType:String, numSegmentProperty:Number):void
		{
			curveMode = SINGLE_CURVE;
			
			var i:uint, l:uint = _recoardList.length;
			var pointA:Point, pointB:Point, newD:Point;
			
			var traceData:Array = [];
			traceData.push(_recoardList[0].d);
			
			for (i = 1; i < l; i++)
			{
				pointA = _recoardList[i - 1].d;
				pointB = _recoardList[i].d;
				newD = new Point((pointB.x + pointA.x) / 2, (pointB.y + pointA.y) / 2);
				traceData.push(newD);
				traceData.push(pointB);
			}
			
			//trace('traceData = ' + traceData);
			
			_recoardList = new Vector.<PathRecoardUnit>;
			
			
			addPoint(traceData[0]);			
			var lastPoint:Point = traceData[1];
			addPoint(lastPoint);
			
			l = traceData.length - 1;
			
			
			var curvePoint:Point, endPoint:Point;
			
			
			for (i = 2; i < l; i += 2)
			{
				curvePoint = traceData[i];
				endPoint = traceData[i + 1];
				//addBezierSegment(lastPoint, curvePoint, curvePoint.clone(), endPoint);
				addBezierSegment(lastPoint, lastPoint, curvePoint, endPoint, numSegmentType, numSegmentProperty);
				
				lastPoint = endPoint;
			}
			
			addPoint(traceData[l]);
			
		}
		
		public function getPositionByIndex(pathRecoardUnitIndex:uint):Number
		{
			if (pathRecoardUnitIndex >= _recoardList.length || pathRecoardUnitIndex == 0) throw new Error('unexpected parhRecoardUnit index');
			
			var tempPathRecoard:PathRecoard = clone();			
			var targetIndex:int = pathRecoardUnitIndex + 1;
			var deleteCount:int = tempPathRecoard.recoardList.length - targetIndex;
			
			tempPathRecoard.recoardList.splice(targetIndex, deleteCount);
			
			var path:Path = tempPathRecoard.getPath();	
			
			return path.length;
		}
	
		public function getPath():Path
		{
			var path:Path = new Path();
			
			var i:int, l:int = _recoardList.length;
			for (i = 0; i < l; i++)
			{
				var recoard:PathRecoardUnit = _recoardList[i];
				switch(recoard.type)
				{
					case PathRecoardType.POINT:
						path.add(recoard.d.x, recoard.d.y);
					break;
					
					case PathRecoardType.BEZIER:
						path.addBezierSegment(recoard.a, recoard.b, recoard.c, recoard.d, recoard.numSegmentType, recoard.numSegmentProperty);
					break;
				}
			}
			
			return path;
		}
		
		/************************
		*         clone
		************************/
		public function clone():PathRecoard
		{
			var pathRecoard:PathRecoard = new PathRecoard();
			pathRecoard._recoardList = _recoardList.concat(new Vector.<PathRecoardUnit>);
			return pathRecoard;
		}
		
		/************************
		*         params
		************************/
		private var _recoardList:Vector.<PathRecoardUnit> = new Vector.<PathRecoardUnit>;
		public function get recoardList():Vector.<PathRecoardUnit> { return _recoardList; }
		
		public static var SINGLE_CURVE:String = 'single';
		public static var BEZIER_CURVE:String = 'bezier';
		
		private var _curveMode:String = BEZIER_CURVE;
		public function get curveMode():String { return _curveMode; }
		public function set curveMode(s:String):void
		{
			if (s != SINGLE_CURVE && s != BEZIER_CURVE)
			{
				throw new Error('Warning : illegal curve mode : ' + s);
			}
			if (s == _curveMode) return;
			_curveMode = s;
			
			var recoardUnit:PathRecoardUnit;
			
			if (_curveMode == SINGLE_CURVE)
			{
				for each(recoardUnit in _recoardList)
				{
					if (recoardUnit.type == PathRecoardType.BEZIER)
					{
						recoardUnit.b = recoardUnit.a;
					}
				}
			}
			else
			{
				for each(recoardUnit in _recoardList)
				{
					if (recoardUnit.type == PathRecoardType.BEZIER)
					{
						recoardUnit.b = recoardUnit.a.clone();
					}
				}
			}
		}
	}
}

