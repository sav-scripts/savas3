package sav.geom.path 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author sav
	 */
	public class SplineCurve 
	{
		public function SplineCurve(smoothPerNode:int = 1, smoothByLength:Number = Number.NaN, minSmoothLevel:int = -1)
		{
			changeSmooth(smoothPerNode, smoothByLength, minSmoothLevel);
		}
		
		public function changeSmooth(smoothPerNode:int, smoothByLength:Number, minSmoothLevel:int):void
		{
			_smoothPerNode = smoothPerNode;
			_smoothByLength = smoothByLength;
			_minSmoothLevel = (minSmoothLevel < 0) ? _smoothPerNode : minSmoothLevel;
		}
		
		public function fit(pointList:Vector.<Point>):void
		{
			_pointList = pointList;
			update();
		}
		
		public function update():void
		{
			if (!_pointList) return;
			
			if (_pointList == null || _pointList.length < 2) return;
			
			var i:int, j:int;
			var n:int = _pointList.length;
			var smoothingLevel:int = _smoothPerNode;
			
			var verticesPerNode:int = smoothingLevel + 1;
			var numVertices:int = (verticesPerNode * (n - 1)) + 1;
			
			if (!isNaN(_smoothByLength))
			{
				var segmentLengthList:Vector.<Number> = new Vector.<Number>(n - 1);
				var segmentSmoothingLevelList:Vector.<int> = new Vector.<int>(n - 1);
				var segmentLength:Number;
				var numParts:int = 0;
			}
			
			var newVertices:Vector.<Point> = new Vector.<Point>(numVertices);
			
			var nextVertex:int = 0;
			
			var dx:Number, dy:Number;
			
			var cubicX:Vector.<Number> = new Vector.<Number>(n);
			var cubicY:Vector.<Number> = new Vector.<Number>(n);
			
			for (i = 0; i < n; i++) 
			{
				cubicX[i] = _pointList[i].x;
				cubicY[i] = _pointList[i].y;
			}
			
			for (i = 1; i < n; i++) 
			{	
				if (!isNaN(_smoothByLength)) segmentLength = 0;
				
				for (j = 0; j < smoothingLevel + 1; j++) 
				{	
					if (j == 0) 
					{
						newVertices[nextVertex] = new Point(cubicX[i - 1], cubicY[i - 1]);
						nextVertex++;
						continue;
					}
					
					var u:Number = j / (smoothingLevel + 1);
					
					var X:Vector.<Cubic> = calcNaturalCubic(n - 1, cubicX);
					var Y:Vector.<Cubic> = calcNaturalCubic(n - 1, cubicY);
					
					newVertices [nextVertex] = new Point(X[i - 1].eval(u), Y[i - 1].eval(u));
					nextVertex++;
					
					if (!isNaN(_smoothByLength))
					{
						dx = newVertices[nextVertex - 1].x - newVertices[nextVertex - 2].x;
						dy = newVertices[nextVertex - 1].y - newVertices[nextVertex - 2].y;
						segmentLength += Math.sqrt(dx * dx + dy * dy);
					}
				}
				if (!isNaN(_smoothByLength))
				{
					dx = cubicX[i] - newVertices[nextVertex - 1].x;
					dy = cubicY[i] - newVertices[nextVertex - 1].y;
					segmentLength += Math.sqrt(dx * dx + dy * dy);					
					
					segmentLengthList[i - 1] = segmentLength;
					
					var segmentSmoothingLevel:Number = segmentLength / _smoothByLength;
					if (segmentSmoothingLevel == int(segmentSmoothingLevel) && segmentSmoothingLevel != 0)
						segmentSmoothingLevel -= 1;
					segmentSmoothingLevelList[i - 1] = Math.max(int(segmentSmoothingLevel), _minSmoothLevel);
					numParts += (segmentSmoothingLevelList[i - 1] + 1);
				}
			}
			
			newVertices [numVertices-1] = _pointList [n-1];
			
			if (!isNaN(_smoothByLength))
			{
				var oldVertices:Vector.<Point> = newVertices.concat(new Vector.<Point>);
				
				newVertices = new Vector.<Point>(numParts);
				nextVertex = 0;
				
				for (i = 1; i < n; i++)
				{
					smoothingLevel = segmentSmoothingLevelList[i - 1];
					
					for (j = 0; j < smoothingLevel + 1; j++) 
					{	
						if (j == 0) 
						{
							newVertices[nextVertex] = new Point(cubicX[i - 1], cubicY[i - 1]);
							nextVertex++;
							continue;
						}
						
						u = j / (smoothingLevel + 1);
						
						newVertices [nextVertex] = new Point(X[i - 1].eval(u), Y[i - 1].eval(u));
						nextVertex++;
					}
				}
				
				//trace("old vertices = " + oldVertices);
				//trace("segment length list = " + segmentLengthList);
				//trace("segment smoothing level list = " + segmentSmoothingLevelList);
				
				newVertices [numParts-1] = _pointList [n-1];
			}
			
			_resultPointList = newVertices;
		}
	
	
		public function calcNaturalCubic(n:int, x:Vector.<Number>):Vector.<Cubic>
		{	
			var gamma:Vector.<Number> = new Vector.<Number>(n + 1);
			var delta:Vector.<Number> = new Vector.<Number>(n + 1);
			var D:Vector.<Number> = new Vector.<Number>(n + 1);
			var i:int;
		
			gamma[0] = 1.0 / 2.0;
			
			for (i = 1; i < n; i++) 
			{
			  gamma[i] = 1/(4-gamma[i-1]);
			}
			
			gamma[n] = 1/(2-gamma[n-1]);
			
			delta[0] = 3*(x[1]-x[0])*gamma[0];
			
			for ( i = 1; i < n; i++) 
			{
			  delta[i] = (3*(x[i+1]-x[i-1])-delta[i-1])*gamma[i];
			}
			
			delta[n] = (3*(x[n]-x[n-1])-delta[n-1])*gamma[n];
			
			D[n] = delta[n];
			
			for ( i = n-1; i >= 0; i--) 
			{
			  D[i] = delta[i] - gamma[i]*D[i+1];
			}
			
			var C:Vector.<Cubic> = new Vector.<Cubic>(n + 1);
			
			for ( i = 0; i < n; i++) {
			  C[i] = new Cubic(
				x[i], 
				D[i], 
				3 * (x[i + 1] - x[i]) - 2 * D[i] - D[i + 1],
				2*(x[i] - x[i+1]) + D[i] + D[i+1]);
			}
				
			return C;
		}
		
		/**** params ****/
		private var _pointList:Vector.<Point>;
		private var _resultPointList:Vector.<Point>;
		public function get resultPointList():Vector.<Point> { return _resultPointList; }
		
		private var _smoothPerNode:int;
		private var _smoothByLength:Number;
		private var _minSmoothLevel:int;
	}

}



class Cubic
{
	private var a:Number, b:Number, c:Number, d:Number;

	public function Cubic(a:Number, b:Number, c:Number, d:Number)
	{
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
	}
  
	public function eval(u:Number):Number
	{
		return (((d * u) + c) * u + b) * u + a;
	}
}