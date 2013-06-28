package sav.gp.shapes
{
	import flash.display.Shape;
	
	public class TriangleV extends Shape
	{
		public function TriangleV(w:Number = 15, h:Number = 20, thinkness:Number = 5, color:Number = 0xffffff )
		{
			var arc:Number = Math.atan2(h, w);
			var dy:Number = Math.tan(arc) * thinkness;
			
			graphics.beginFill(color);
			graphics.moveTo( -w, 0);
			graphics.lineTo(0, h);
			graphics.lineTo(w, 0);
			graphics.lineTo(w - thinkness, 0);
			graphics.lineTo(0, h - dy);
			graphics.lineTo( -w + thinkness, 0);
			graphics.endFill();
		}
	}
}