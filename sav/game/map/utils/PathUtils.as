package sav.game.map.utils 
{
	import flash.geom.Point;
	import sav.game.map.prototype.Path;
	import sav.geom.Utils2D;
	/**
	 * ...
	 * @author sav
	 */
	public class PathUtils 
	{
		public static function getTrianglesData(path:Path, textureWidth:Number, textureHeight:Number, segmentLength:Number = 10, u0:Number = 0, u1:Number = 1):Object
		{
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
			
			var size:Number = textureWidth / 2;
			
			while (position < pathLength)
			{
				var oldPosition:Number = position;
				var oldLocation:Point = location;
				
				position += dLength;
				if (position > pathLength) position = pathLength;
				
				path.position = position;
				location = path.location;
				
				var dPoint:Point = location.subtract(oldLocation);
				dPoint.normalize(size);
				
				
				a = (d != null) ? d : oldLocation.add(Utils2D.rotatePoint(dPoint, 90));
				b = (c != null) ? c : oldLocation.add(Utils2D.rotatePoint(dPoint, -90));
				c = location.add(Utils2D.rotatePoint(dPoint, -90));
				d = location.add(Utils2D.rotatePoint(dPoint, 90));
				
				var si:int = vertices.length / 2;
				
				var v0:Number = oldPosition / textureHeight;
				var v1:Number = position / textureHeight;
				
				vertices.push(a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y);
				indices.push(0 + si, 1 + si, 3 + si, 1 + si, 2 + si, 3 + si);
				uvData.push(u0, v0, u1, v0, u1, v1, u0, v1);
			}
			
			return { vertices:vertices, indices:indices, uvData:uvData };
		}
		
	}

}