package sav.geom.path
{
	import flash.geom.Point;
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
	}
}