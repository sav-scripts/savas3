package sav.gp
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class GraphicDrawer
	{
		/**
		 * draw board line, property "b" is the border width
		 * @param	g			Graphics	Target Graphics object
		 * @param	bound		Rectangle	Rectangle bound of this border
		 * @param	c			Number		Color
		 * @param	a			Number		Alpha
		 * @param	rc			Number		Round Coner
		 * @param	b			Number		Border width
		 * @param	inflate		Number		Inflate value before this bound been draw
		 */
		public static function drawBorder(g:Graphics, bound:Rectangle, rc:Number, b:Number, inflate:Number = 0):void
		{
			bound = bound.clone();
			bound.inflate(inflate, inflate);
			rc += inflate;
			drawRoundRect(g, bound, rc, 'move');
			bound.inflate(-b, -b);
			rc -= b;
			if (rc < 0) rc = 0;
			drawRoundRect(g, bound, rc, 'line');
		}
		
		public static function drawBorderComplex(g:Graphics, bound:Rectangle, rc1:Number, rc2:Number, rc3:Number, rc4:Number, b:Number, inflate:Number = 0):void
		{
			bound = bound.clone();
			bound.inflate(inflate, inflate);
			rc1 += inflate;
			rc2 += inflate;
			rc3 += inflate;
			rc4 += inflate;
			drawRoundRectComplex(g, bound, rc1, rc2, rc3, rc4, 'move');
			bound.inflate(-b, -b);
			rc1 -= b;
			rc2 -= b;
			rc3 -= b;
			rc4 -= b;
			if (rc1 < 0) rc1 = 0;
			if (rc2 < 0) rc2 = 0;
			if (rc3 < 0) rc3 = 0;
			if (rc4 < 0) rc4 = 0;
			drawRoundRectComplex(g, bound, rc1, rc2, rc3, rc4, 'line');
		}
		
		/// This function not ready yet
		public static function drawMultiBorder(g:Graphics, bound:Rectangle, settings:Array, rc:Number):void
		{
			bound = bound.clone();
			var i:uint, l:uint = settings.length;
			for (i = 0; i < l;i++ )
			{
				var object:Object = settings[i];
				var c:Number = object.color;
				var a:Number = object.alpha;
				var t:Number = object.thickness;
				
				g.beginFill(c, a);
				
				(i==0) ? drawRoundRect(g, bound, rc, 'move') : drawRoundRect(g, bound, rc, 'line');
				bound.inflate( -t, -t);
				rc -= 2;
			}			
			g.endFill();
		}
		
		/**
		 * 
		 * @param	g			Graphics	Target Graphics object
		 * @param	bound		Rectangle	Rectangle bound of this border
		 * @param	c			Number		Color
		 * @param	a			Number		Alpha
		 * @param	rc			Number		Round Coner
		 * @param	b			Number		Border width
		 * @param	firstStep	String		"move" or "line" in first step
		 */
		public static function drawRoundRect(g:Graphics, bound:Rectangle, rc:Number, firstStep:String = 'move'):void
		{
			(firstStep == 'move') ? g.moveTo(	bound.left + rc,	bound.top) : g.lineTo(	bound.left + rc,	bound.top)
			
			g.lineTo(	bound.right - rc,	bound.top);
			g.curveTo(	bound.right,		bound.top,
						bound.right,		bound.top + rc);
			g.lineTo(	bound.right,		bound.bottom - rc);
			g.curveTo(	bound.right,		bound.bottom,
						bound.right - rc,	bound.bottom);
			g.lineTo(	bound.left + rc,	bound.bottom);
			g.curveTo(	bound.left,			bound.bottom,
						bound.left,			bound.bottom - rc);
			g.lineTo(	bound.left,			bound.top + rc);
			g.curveTo(	bound.left,			bound.top,
						bound.left + rc,	bound.top);			
		}
		
		public static function drawRoundRectComplex(g:Graphics, bound:Rectangle, 
			rc1:Number, rc2:Number, rc3:Number, rc4:Number, firstStep:String = 'move'):void
		{
			(firstStep == 'move') ? g.moveTo(	bound.left + rc1,	bound.top) : g.lineTo(	bound.left + rc1,	bound.top)
			
			g.lineTo(	bound.right - rc2,	bound.top);
			g.curveTo(	bound.right,		bound.top,
						bound.right,		bound.top + rc2);
			g.lineTo(	bound.right,		bound.bottom - rc4);
			g.curveTo(	bound.right,		bound.bottom,
						bound.right - rc4,	bound.bottom);
			g.lineTo(	bound.left + rc3,	bound.bottom);
			g.curveTo(	bound.left,			bound.bottom,
						bound.left,			bound.bottom - rc3);
			g.lineTo(	bound.left,			bound.top + rc1);
			g.curveTo(	bound.left,			bound.top,
						bound.left + rc1,	bound.top);			
		}
	}
}