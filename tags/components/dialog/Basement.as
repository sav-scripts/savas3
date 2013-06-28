package sav.components.dialog
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import fl.motion.Color;
	import flash.display.GradientType;
	import sav.gp.GraphicDrawer;
	
	public class Basement extends Sprite
	{
		public function Basement(setting:DialogSetting):void { _setting = setting; }
		
		internal function resize(bound:Rectangle, btnBound:Rectangle, btnRc:Number, scrollerHeight:Number = Number.NaN):void
		{
			_bound = bound;
			
			
			var bound:Rectangle = _bound.clone();
			
			var g:Graphics = graphics;
			g.clear();
			
			var boardSize:Number = _setting.boardSize;
			var boardColor:uint = _setting.boardColor;
			var c5:uint = Color.interpolateColor(boardColor, 0x000000, 0.5);
			var rc:Number = _setting.baseRoundConer;
			
			bound.inflate(1, 1);
			g.beginFill(c5);
			GraphicDrawer.drawRoundRect(g, bound, rc);			
			bound.inflate( -1, -1); rc --;
			
			g.beginFill(_setting.boardColor);			
			GraphicDrawer.drawRoundRect(g, bound, rc);
			
			bound.inflate( -boardSize, -boardSize); rc -= boardSize;
			//bound.inflate( 
			
			var color:uint = _setting.baseColor;
			var c3:uint = Color.interpolateColor(color, 0x000000, 0.18);
			var c4:uint = Color.interpolateColor(color, 0xffffff, 0.08);
			g.beginFill(c3);			
			//GraphicDrawer.drawRoundRect(g, bound, rc);
			
			drawShape(g, bound, btnBound, btnRc, rc, scrollerHeight);
			bound.inflate( -1, -1); rc --; btnBound.inflate(1, 0); btnBound.y -= 1, btnRc ++;
			g.beginFill(c4);			
			//GraphicDrawer.drawRoundRect(g, bound, rc);
			
			drawShape(g, bound, btnBound, btnRc, rc, scrollerHeight);
			bound.inflate( -1, -1); rc --; btnBound.inflate(1, 0); btnBound.y -= 1, btnRc ++;
			
			var c1:uint = Color.interpolateColor(color, 0x000000, 0.04);
			var c2:uint = Color.interpolateColor(color, 0xffffff, 0.02);
			var c6:uint = Color.interpolateColor(color, 0xffffff, 0.08);
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [color, c1, c2, c6];
			var alphas:Array = [1, 1, 1, 1];
			var ratios:Array = [0x00, 0xee, 0xf1, 0xff];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(bound.width, bound.height, Math.PI / 2);			
					
			g.beginGradientFill(fillType, colors, alphas, ratios, matr);	
			
			
			drawShape(g, bound, btnBound, btnRc, rc, scrollerHeight);
			
			
			//g.drawRoundRect(bound.x, bound.y, bound.width, bound.height, _setting.baseRoundConer - _setting.boardSize);
			
			g.endFill();
		}
		
		private function drawShape(g:Graphics, bound:Rectangle, btnBound:Rectangle, btnRc:Number, rc:Number, scrollerHeight:Number):void
		{
			g.moveTo(bound.left + rc, bound.top);
			g.lineTo(bound.right - rc, bound.top);
			g.curveTo(bound.right, bound.top, bound.right, bound.top + rc);
			
			if (!isNaN(scrollerHeight))
			{
				var b2:Rectangle = new Rectangle(
					_setting.maxWidth - _setting.scrollerWidth - _setting.boardSize,	
					_setting.contentInflateHeight,
					_setting.scrollerWidth,
					scrollerHeight);
					
				b2.inflate(_setting.boardSize, _setting.boardSize);
				b2.width -= _setting.boardSize;
				
				var rc2:Number = _setting.scrollerWidth / 2 + _setting.boardSize;
				
				g.lineTo(b2.right, b2.top - 2);
				g.curveTo(b2.right, b2.top, b2.right - 2, b2.top);
				g.lineTo(b2.left + rc2, b2.top);
				g.curveTo(b2.left, b2.top, b2.left, b2.top + rc2);
				g.lineTo(b2.left, b2.bottom - rc2);
				g.curveTo(b2.left, b2.bottom, b2.left + rc2, b2.bottom);
				g.lineTo(b2.right - 2, b2.bottom);
				g.curveTo(b2.right, b2.bottom, b2.right, b2.bottom + 2);
			}
			
			g.lineTo(bound.right, bound.bottom - rc);
			g.curveTo(bound.right, bound.bottom, bound.right - rc, bound.bottom);
			
			g.lineTo(btnBound.right, btnBound.bottom);
			g.lineTo(btnBound.right, btnBound.top + btnRc);
			g.curveTo(btnBound.right, btnBound.top, btnBound.right - btnRc, btnBound.top);
			g.lineTo(btnBound.left + btnRc, btnBound.top);
			g.curveTo(btnBound.left, btnBound.top, btnBound.left, btnBound.top + btnRc);
			g.lineTo(btnBound.left, btnBound.bottom);
			
			
			g.lineTo(bound.left + rc, bound.bottom);
			g.curveTo(bound.left, bound.bottom, bound.left, bound.bottom - rc);
			g.lineTo(bound.left, bound.top + rc);
			g.curveTo(bound.left, bound.top, bound.left + rc, bound.top);
			
		}
		
		internal function destroy():void
		{
			_bound = null;
			_setting = null;
			
			if (parent) parent.removeChild(this);
		}
		
		private var _setting:DialogSetting;
		private var _bound:Rectangle;	
	}
}