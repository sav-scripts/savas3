package sav.geom
{
	import flash.geom.Point;
	public class Utils2D
	{
		public static function rotatePoint(point:Point, degree:Number, givePrecisionValue:Boolean = true):Point
		{	
			var arc:Number = degreeToArc(degree);
			var cos:Number = Math.cos(arc);
			var sin:Number = Math.sin(arc);
			
			//var x:Number = cos * point.x + sin * point.y;
			//var y:Number = cos * point.y - sin * point.x;
			//trace('sin = ' + sin);
			//trace('cos = ' + (cos == 1));
			
			var x:Number = point.x * cos - point.y * sin;
			var y:Number = point.x * sin + point.y * cos;
			
			if (givePrecisionValue == false)
			{
				x = int(x * 10000) / 10000;
				y = int(y * 10000) / 10000;
			}
			
			return new Point(x, y);
		}
		
		public static function rotatePointByPoint(centerPoint:Point, targetPoint:Point, degree:Number, givePrecisionValue:Boolean = true):Point
		{	
			var dPoint:Point = targetPoint.subtract(centerPoint);
			dPoint = rotatePoint(dPoint, degree, givePrecisionValue);
			
			return dPoint.add(centerPoint);
		}
		
		public static function degreeToArc(degree:Number):Number
		{
			return Math.PI * (degree / 180);
		}
		
		public static function arcToDegree(arc:Number):Number {
			return arc / Math.PI * 180;
		}
		
		public static function roundDegree(degree:Number):Number 
		{
			if (degree > 180)
				degree = (degree + 180) % 360 - 180;
			else if (degree < -180)
				degree = (degree - 180) % 360 + 180;
			
			return degree;
		}
		
		/**
		 * test rotatingDegree with rotationDifference, change rotatingDegree value depand on if rotationDifference > 180 or < 180
		 * also will change rotatingDegree value if it is > rotationDifference
		 * 
		 * @param	rotationDifference
		 * @param	rotatingDegree
		 * @return
		 */
		public static function testRotatingDegree(rotationDifference:Number, rotatingDegree:Number):Number
		{	
			if (rotationDifference > 0)
			{
				if (rotationDifference > 180) 
				{
					rotationDifference = rotationDifference - 360;
					rotatingDegree = -rotatingDegree;
					if (rotatingDegree < rotationDifference) rotatingDegree = rotationDifference;
				}
				else
				{						
					if (rotatingDegree > rotationDifference) rotatingDegree = rotationDifference;
				}
			}
			else if (rotationDifference < 0)
			{
				if (rotationDifference < -180)
				{
					rotationDifference = 360 + rotationDifference;
					if (rotatingDegree > rotationDifference) rotatingDegree = rotationDifference;
				}
				else
				{
					rotatingDegree = -rotatingDegree;
					if (rotatingDegree < rotationDifference) rotatingDegree = rotationDifference;
				}
			}
			else
			{
				rotatingDegree = 0;
			}
			
			return rotatingDegree;
		}
		
		/**
		 * simler with testRotatinDegree(), but us arc instead
		 * 
		 * @param	arcDifference
		 * @param	rotatingArc
		 * @return
		 */
		public static function testRotatingArc(arcDifference:Number, rotatingArc:Number):Number
		{	
			if (arcDifference > 0)
			{
				if (arcDifference > Math.PI) 
				{
					arcDifference = arcDifference - (Math.PI*2);
					rotatingArc = -rotatingArc;
					if (rotatingArc < arcDifference) rotatingArc = arcDifference;
				}
				else
				{						
					if (rotatingArc > arcDifference) rotatingArc = arcDifference;
				}
			}
			else if (arcDifference < 0)
			{
				if (arcDifference < -Math.PI)
				{
					arcDifference = (Math.PI*2) + arcDifference;
					if (rotatingArc > arcDifference) rotatingArc = arcDifference;
				}
				else
				{
					rotatingArc = -rotatingArc;
					if (rotatingArc < arcDifference) rotatingArc = arcDifference;
				}
			}
			else
			{
				rotatingArc = 0;
			}
			
			return rotatingArc;
		}
		
		/**
		 * get contact points between circles (if two circles have contact points)
		 * 
		 * @param	xA
		 * @param	yA
		 * @param	rA
		 * @param	xB
		 * @param	yB
		 * @param	rB
		 * @return
		 */
		public static function getContactPointsBetweenCircles(xA:Number, yA:Number, rA:Number, xB:Number, yB:Number, rB:Number):Vector.<Point>
		{
			var a:Number, b:Number, c:Number;
			var x:Number;
			var x0:Number, x1:Number, y0:Number, y1:Number;
			
			if (yA == yB)
			{
				x = -(xA*xA - xB*xB -rA*rA + rB*rB) / (2*(xB-xA));
				
				a = 1;
				b = -2*yA;
				c = x * x + xA * xA - 2 * xA * x + yA * yA - rA * rA;
				
				y0 = ( -b + Math.sqrt(b * b - 4 * a * c)) / (2 * a);
				y1 = ( -b - Math.sqrt(b * b - 4 * a * c)) / (2 * a);
				
				x0 = x1 = x;
			}
			else
			{
				var m:Number = (xA - xB) / (yB - yA);
				var k:Number = (rA * rA - rB * rB + xB * xB - xA * xA + yB * yB - yA * yA) / (2 * (yB - yA));
				
				a = 1 + m*m;
				b = 2 * (m*k - m*yB - xB);
				c = xB*xB + yB*yB + k*k - 2*k*yB - rB*rB;
				
				x0 = ( -b + Math.sqrt(b * b - 4 * a * c)) / (2 * a);
				x1 = ( -b - Math.sqrt(b * b - 4 * a * c)) / (2 * a);
				
				y0 = m * x0 + k;
				y1 = m * x1 + k;
			}
			
			var vec:Vector.<Point> = new Vector.<Point>;
			
			if (isNaN(x0) || isNaN(y0))
			{
				return null;
			}
			else if (x0==x1 && y0==y1)
			{
				vec.push(new Point(x0, y0));
				return vec;
			}
			else
			{
				vec.push(new Point(x0, y0));
				vec.push(new Point(x1, y1));
				return vec;
			}
		}
		
		
		/**
		 * test if two circles contacts
		 * 
		 * @param	xA
		 * @param	yA
		 * @param	rA
		 * @param	xB
		 * @param	yB
		 * @param	rB
		 * @return Boolean
		 */
		public static function testCirclesContact(xA:Number, yA:Number, rA:Number, xB:Number, yB:Number, rB:Number):Boolean
		{
			return Boolean((xB - xA) * (xB - xA) + (yB - yA) * (yB - yA) <= (rA + rB) * (rA + rB));
		}
		
		/**
		 * giving circleA and circleB, and circleA moving alone vector(vx, vy), if circleA will contact with circleB, return two vectors which will make 
		 * circleA contact with circleB
		 * 
		 * @param	vx
		 * @param	vy
		 * @param	xA
		 * @param	yA
		 * @param	xB
		 * @param	yB
		 * @param	rA
		 * @param	rB
		 * @return Vector.<Point> if null, circleA won't contact with circleB, if vector length == 1, only one contact point
		 */
		public static function getVectorsMakeCirclesContact(vx:Number, vy:Number, xA:Number, yA:Number, rA:Number, xB:Number, yB:Number, rB:Number):Vector.<Point>
		{
			var t:Number = (vy == 0) ? 0 : vx / vy;
			
			var vx0:Number, vy0:Number, vx1:Number, vy1:Number;
			var a:Number, b:Number, c:Number;
			
			if (vy == 0)
			{
				a = 1;
				b = 2*xA - 2*xB;
				c = xA*xA + xB*xB - 2*xA*xB + yA*yA + yB*yB - 2*yA*yB - (rA+rB)*(rA+rB);
				
				vx0 = ( -b + Math.sqrt(b * b - 4 * a * c)) / (2 * a);
				vx1 = ( -b - Math.sqrt(b * b - 4 * a * c)) / (2 * a);
				
				vy0 = 0;
				vy1 = 0;
			}
			else
			{
			
				a = t*t+1;
				b = 2*xA*t - 2*xB*t + 2*yA - 2*yB;
				c = xA*xA + xB*xB - 2*xA*xB + yA*yA + yB*yB - 2*yA*yB - (rA+rB)*(rA+rB);
				
				vy0 = ( -b + Math.sqrt(b * b - 4 * a * c)) / (2 * a);
				vy1 = ( -b - Math.sqrt(b * b - 4 * a * c)) / (2 * a);
				
				vx0 = vy0 * t;
				vx1 = vy1 * t;
			}
			
			
			
			var vector:Vector.<Point> = new Vector.<Point>;
			
			if (isNaN(vx0) || isNaN(vy0))
			{
				return null;
			}
			else if (vx0 == vx1 && vy0 == vy1)
			{
				vector.push(new Point(vx0, vy0));
			}
			else 
			{
				if (vx0 * vx0 < vx1 * vx1)
				{
					vector.push(new Point(vx0, vy0));
					vector.push(new Point(vx1, vy1));
				}
				else
				{
					vector.push(new Point(vx1, vy1));
					vector.push(new Point(vx0, vy0));
				}
			}
			
			return vector;
			
			/*
			(xA + vx - xB) * (xA + vx - xB) + (yA + vy - yB) * (yA + vy - yB) = (rA + rB) * (rA + rB);
			
			(xA + t * v - xB) * (xA + t * v - xB) + (yA + v - yB) * (yA + v - yB) = (rA + rB) * (rA + rB);
			
			xA*xA + xA*t*v - xA*xB + xA*t*v + t*v*t*v - xB*t*v - xB*xA - xB*t*v + xB*xB + 
			yA*yA + yA*v - yA*yB + yA*v + v*v - yB*v - yB*yA - yB*v + yB*yB = 
			(rA + rB) * (rA + rB);
			
			xA*xA + xB*xB + t*v*t*v + 2*xA*t*v -2*xA*xB - 2*xB*t*v +
			yA*yA + yB*yB + v*v + 2*yA*v -2*yA*yB - 2*yB*v =
			(rA + rB) * (rA + rB);
			
			xA*xA + xB*xB - 2*xA*xB + yA*yA + yB*yB + 2*yA*yB + 
			2*xA*t*v - 2*xB*t*v + 2*yA*v - 2*yB*v +
			t*v*t*v + v*v = 
			(rA + rB) * (rA + rB);
			
			xA*xA + xB*xB - 2*xA*xB + yA*yA + yB*yB - 2*yA*yB + 
			v*(2*xA*t - 2*xB*t + 2*yA - 2*yB) +
			v*v*(t*t+1) =
			(rA + rB) * (rA + rB);
			
			v*v*(t*t+1) +
			v*(2*xA*t - 2*xB*t + 2*yA - 2*yB) +
			xA*xA + xB*xB - 2*xA*xB + yA*yA + yB*yB - 2*yA*yB - (rA+rB)*(rA+rB)
			= 0;
			*/
			
			/*
			(xA + v - xB) * (xA + v - xB) + (yA + t*v - yB) * (yA + t*v - yB) = (rA + rB) * (rA + rB);
			
			(xA + v - xB) * (xA + v - xB) + (yA - yB) * (yA - yB) = (rA + rB) * (rA + rB);
			
			(xA + v - xB) * (xA + v - xB) + (yA - yB) * (yA - yB) = (rA + rB) * (rA + rB);
			
			xA*xA + v*v + xB*xB +2*xA*v -2*xA*xB -2*xB*v + yA*yA + yB*yB - 2*yA*yB = (rA + rB) * (rA + rB);
			
			xA*xA + xB*xB - 2*xA*xB + yA*yA + yB*yB - 2*yA*yB - (rA+rB)*(rA+rB) +
			2*xA*v - 2*xB*v
			v*v = 0
			
			xA*xA + xB*xB - 2*xA*xB + yA*yA + yB*yB - 2*yA*yB - (rA+rB)*(rA+rB) +
			v * (2*xA - 2*xB) +
			v*v = 0
			*/
		}
	}
}