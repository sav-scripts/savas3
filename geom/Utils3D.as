package sav.geom
{
	import flash.geom.Vector3D;
	public class Utils3D
	{
		public static function projectVector3D(vp:Vector3D, degree_axisX:Number = 0, degree_axisY:Number = 0, degree_axisZ:Number = 0, focalLength:Number = 300):Object
		{	
			var sin_x:Number = Math.sin(Math.PI * (degree_axisX / 180));
			var cos_x:Number = Math.cos(Math.PI * (degree_axisX / 180));
			var sin_y:Number = Math.sin(Math.PI * (degree_axisY / 180));
			var cos_y:Number = Math.cos(Math.PI * (degree_axisY / 180));
			var sin_z:Number = Math.sin(Math.PI * (degree_axisZ / 180));
			var cos_z:Number = Math.cos(Math.PI * (degree_axisZ / 180));
			
			var x:Number, y:Number, z:Number, xy:Number, xz:Number, yx:Number, yz:Number, zx:Number, zy:Number, ratio:Number;
			
		   x = vp.x;
		   y = vp.y;
		   z = vp.z;
		   xy = cos_x * y - sin_x * z;
		   xz = sin_x * y + cos_x * z;
		   yz = cos_y * xz - sin_y * x;
		   yx = sin_y * xz + cos_y * x;
		   zx = cos_z * yx - sin_z * xy;
		   zy = sin_z * yx + cos_z * xy;
		   ratio = focalLength / (focalLength + yz);
		   
		   x = zx*ratio;
		   y = zy*ratio;
		   z = yz;
		   
		   var res:Object = { x:x, y:y, z:z, scale:ratio };
			
			return res;
		}
		
		public static function degreeToPI(degree:Number):Number
		{
			return Math.PI * (degree / 180);
		}
	}
}