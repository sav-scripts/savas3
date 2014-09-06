package sav.geom.path
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import sav.geom.Utils2D;
	/**
	 * ...
	 * @author sav
	 */
	public class PathUtils 
	{
		/**
		 * 
		 * @param	path
		 * @param	textureWidth
		 * @param	textureHeight
		 * @param	segmentLength
		 * @param	u0
		 * @param	u1
		 * @param	hvType String "vertical" make it vertical, "horizontal" make it horizontal, default will parse texture according to path direction
		 * @return
		 */
		/*
		public static function getTrianglesData(path:Path, lineSize:Number, textureLength:Number, segmentLength:Number = 10, uv0:Number = 0, uv1:Number = 1, 
			textureDirection:String = "vertical", offsetType:String = "default", offset:Number = 0):TrianglesData
		{
			var u0:Number, u1:Number, v0:Number, v1:Number;
			if (textureDirection == "vertical")
			{
				u0 = uv0;
				u1 = uv1;
			}
			else if(textureDirection == "horizontal")
			{
				v0 = uv0;
				v1 = uv1;
			}
			else
			{
				throw new Error("illegal textureDirection");
			}
			
			var position:Number = path.position = 0;
			var location:Point = path.location;		
			
			var pathLength:Number = path.length;
			var dLength:Number = segmentLength;
			
			var vertices:Vector.<Number> = new Vector.<Number>;
			var indices:Vector.<int> = new Vector.<int>;
			var uvData:Vector.<Number> = new Vector.<Number>;
			
			var a:Point;
			var b:Point;
			var c:Point;
			var d:Point;
			
			var size:Number = lineSize / 2;
			
			while (position < pathLength)
			{
				var oldPosition:Number = position;
				var oldLocation:Point = location;
				
				position += dLength;
				if (position > pathLength) position = pathLength;
				
				path.position = position;
				location = path.location;
				
				var dPoint:Point = location.subtract(oldLocation);
				
				if (offset == 0)
				{
					dPoint.normalize(size);
				}
				else
				{
					var dPointA:Point = dPoint.clone();
					var dPointB:Point = dPoint.clone();
					dPointA.normalize(size + offset);
					dPointB.normalize(size - offset);
				}
				
				switch(offsetType)
				{
					case "vertical":
						a = (d != null) ? d : new Point(oldLocation.x, oldLocation.y + size + offset);
						b = (c != null) ? c : new Point(oldLocation.x, oldLocation.y - size + offset);
						c = new Point(location.x, location.y - size + offset);
						d = new Point(location.x, location.y + size + offset);
					break;
					
					case "horizontal":
						a = (d != null) ? d : new Point(oldLocation.x + size + offset, oldLocation.y);
						b = (c != null) ? c : new Point(oldLocation.x - size + offset, oldLocation.y);
						c = new Point(location.x - size, location.y);
						d = new Point(location.x + size, location.y);
					break;
					
					default:
						if (offset == 0)
						{
							a = (d != null) ? d : oldLocation.add(Utils2D.rotatePoint(dPoint, 90));
							b = (c != null) ? c : oldLocation.add(Utils2D.rotatePoint(dPoint, -90));
							c = location.add(Utils2D.rotatePoint(dPoint, -90));
							d = location.add(Utils2D.rotatePoint(dPoint, 90));
						}
						else
						{
							a = (d != null) ? d : oldLocation.add(Utils2D.rotatePoint(dPointA, 90));
							b = (c != null) ? c : oldLocation.add(Utils2D.rotatePoint(dPointB, -90));
							c = location.add(Utils2D.rotatePoint(dPointB, -90));
							d = location.add(Utils2D.rotatePoint(dPointA, 90));
						}
					break;
					
				}
				
				var si:int = vertices.length / 2;
				
				if (textureDirection == "vertical")
				{
					v0 = oldPosition / textureLength;
					v1 = position / textureLength;
				}
				else
				{
					u0 = oldPosition / textureLength;
					u1 = position / textureLength;
				}
				
				vertices.push(a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y);
				indices.push(0 + si, 1 + si, 3 + si, 1 + si, 2 + si, 3 + si);
				
				(textureDirection == "vertical") ? uvData.push(u0, v0, u1, v0, u1, v1, u0, v1) : uvData.push(u0, v1, u0, v0, u1, v0, u1, v1);
			}
			
			var obj:TrianglesData = new TrianglesData();
			obj.vertices = vertices;
			obj.indices = indices;
			obj.uvData = uvData;
			
			return obj;
		}
		*/
		
		
		/**
		 * 
		 * @param	pointList
		 * @param	lineSize
		 * @param	textureLength
		 * @param	verticalTexture
		 * @param	offsetLeft
		 * @return
		 */
		public static function getTrianglesData_fromPoints(
			pointList:Vector.<Point>, 
			lineSize:Number, textureLength:Number,
			verticalTexture:Boolean = true, 
			offsetLeft:Number = 0):TrianglesData
		{	
			if (pointList.length < 2) return null;
			
			var i:int, n:int = pointList.length;
			
			var u0:Number = 0, u1:Number = 1, v0:Number = 0, v1:Number = 1;
			
			var verticesPerNode:int = 2;
			var numbersPerNode:int = verticesPerNode * 2;
			var indicesPerNode:int = 6;
			var vertices:Vector.<Number> = new Vector.<Number>(numbersPerNode * n, true);
			var indices:Vector.<int> = new Vector.<int>(indicesPerNode * (n-1), true);
			var uvData:Vector.<Number> = new Vector.<Number>(numbersPerNode * n, true);
			
			var size:Number = lineSize / 2;
			
			var currLength:Number = 0;
			
			var prevLeftPoint:Point;
			var prevRightPoint:Point;
			
			for (i = 1; i < n;i++)
			{	
				var si:int;
				var vStart:int = i * numbersPerNode;
				var iStart:int = (i - 1) * indicesPerNode;
				
				var prevLocation:Point = pointList[i - 1];
				var location:Point = pointList[i];
				
				//prevLength = currLength;
				currLength += location.subtract(prevLocation).length;
				
				var dPoint:Point = location.subtract(prevLocation);
				
				var dPointLeft:Point = dPoint.clone();
				dPointLeft.normalize(size + offsetLeft);
				var dPointRight:Point = dPoint.clone();
				dPointRight.normalize(size - offsetLeft);
				
				var leftPoint:Point, rightPoint:Point;
				
				if (i == 1)
				{
					leftPoint = prevLocation.add(Utils2D.rotatePoint(dPointLeft, 90));
					rightPoint = prevLocation.add(Utils2D.rotatePoint(dPointRight, -90));
					
					vertices[0] = leftPoint.x;
					vertices[1] = leftPoint.y;
					vertices[2] = rightPoint.x;
					vertices[3] = rightPoint.y;
					
					if (verticalTexture)
					{
						uvData[0] = u0;
						uvData[1] = v0;
						uvData[2] = u1;
						uvData[3] = v0;
					}
					else
					{
						uvData[0] = u0;
						uvData[1] = v1;
						uvData[2] = u0;
						uvData[3] = v0;
					}
				}
				
				var degreeLeft:Number = 90;
				var degreeRight:Number = -90;
				
				if (i != n - 1)
				{
					var nextLocation:Point = pointList[i + 1];
					
					var vecA:Point = location.subtract(prevLocation);
					var arcA:Number = Math.atan2(vecA.y, vecA.x);
					var vecB:Point = nextLocation.subtract(location);
					var arcB:Number = Math.atan2(vecB.y, vecB.x);
					
					var vecToPrev:Point = prevLocation.subtract(location);
					var vecToNext:Point = vecB.clone();
	
					var productValue:Number = (vecToNext.x * vecToPrev.x) + (vecToNext.y * vecToPrev.y);
					var valNext:Number = vecToNext.length;
					var valPrev:Number = vecToPrev.length;
					var cosValue:Number = productValue / (valNext * valPrev);
					
					if(cosValue < -1 && cosValue > -2)
						cosValue = -1;
					else if(cosValue > 1 && cosValue < 2)
						cosValue = 1;
					var degree:Number = Math.acos(cosValue) / Math.PI * 180;
					
					if (arcB > arcA)
					{
						degreeLeft = 180 - (degree / 2);
						degreeRight = degreeLeft + 180;
					}
					else
					{
						degreeRight = 180 + (degree / 2);
						degreeLeft = degreeRight + 180;
					}
				}
				
				leftPoint = location.add(Utils2D.rotatePoint(dPointLeft, degreeLeft));
				rightPoint = location.add(Utils2D.rotatePoint(dPointRight, degreeRight));
				
				vertices[vStart + 0] = leftPoint.x;
				vertices[vStart + 1] = leftPoint.y;
				vertices[vStart + 2] = rightPoint.x;
				vertices[vStart + 3] = rightPoint.y;
				
				if (verticalTexture)
				{
					v1 = currLength / textureLength;
				}
				else
				{
					u1 = currLength / textureLength;
				}
				
				if (verticalTexture)
				{
					uvData[vStart + 0] = u0;
					uvData[vStart + 1] = v1;
					uvData[vStart + 2] = u1;
					uvData[vStart + 3] = v1;
				}
				else
				{
					uvData[vStart + 0] = u1;
					uvData[vStart + 1] = v1;
					uvData[vStart + 2] = u1;
					uvData[vStart + 3] = v0;
				}
				
				si = (i-1) * verticesPerNode;
				indices[iStart + 0] = 0 + si;
				indices[iStart + 1] = 1 + si;
				indices[iStart + 2] = 2 + si;
				indices[iStart + 3] = 2 + si;
				indices[iStart + 4] = 1 + si;
				indices[iStart + 5] = 3 + si;
			}
			
			var obj:TrianglesData = new TrianglesData();
			obj.vertices = vertices;
			obj.indices = indices;
			obj.uvData = uvData;
			
			//trace('vertices = ' + vertices);
			//trace('indices = ' + indices);
			//trace('uvData = ' + uvData);
			
			return obj;
		}
	}
}