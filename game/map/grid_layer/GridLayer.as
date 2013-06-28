package sav.game.map.grid_layer 
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import sav.gp.GraphicDrawer;
	
	/**
	 * ...
	 * @author sav
	 */
	public class GridLayer extends MovieClip
	{		
		public function GridLayer(withRuler:Boolean = true):void
		{
			mouseChildren = mouseEnabled = false;
			_withRuler = withRuler;
			
			if (_withRuler)
			{
				_ruler = new Sprite();
				_ruler.addChild(new Sprite());
				
			}
		}
		
		public function resize(viewWidth:Number = 800, viewHeight:Number = 600, wGap:Number = 50, hGap:Number = 50):void
		{
			_viewWidth = viewWidth;
			_viewHeight = viewHeight;
			_wGap = wGap;
			_hGap = hGap;
			
			
			if (_withRuler)
			{
				var g:Graphics = _ruler.graphics;
				g.clear();		
				GraphicDrawer.drawBorder(g, new Rectangle(0, 0, _viewWidth, _viewHeight), _rulerBaseColor, 1, 0, _rulerSize );		
			}
		}
		
		public function setStyle(lineColor:uint = 0x999999, lineTickness:Number = 1, lineAlpha:Number = 1, 
			enableRoughLine:Boolean = true, roughLinePerLines:uint = 5, roughLinePerRows:uint = 5, roughLineColor:uint = 0x555555, roughLineTickness:Number = 1, roughLineAlpha:Number = 1):void
		{
			_lineColor = lineColor;
			_lineTickness = lineTickness;
			_lineAlpha = lineAlpha;
			
			_roughEnabled = enableRoughLine;
			_roughLinePerLines = roughLinePerLines;
			_roughLinePerRows = roughLinePerRows;
			_roughLineColor = roughLineColor;
			_roughLineTickness = roughLineTickness;
			_roughLineAlpha = roughLineAlpha;
		}
		
		public function move(dx:Number, dy:Number):void
		{
			_offsetX += dx;
			_offsetY += dy;
			update();
		}
		
		public function setTo(tx:Number, ty:Number, scaleRate:Number = 1):void
		{
			_offsetX = tx;
			_offsetY = ty;
			_scaleRate = scaleRate;
			update();
		}
		
		public function update():void
		{
			var rLayer:Sprite = Sprite(_ruler.getChildAt(0));
			var rg:Graphics = rLayer.graphics;
			rg.clear();
			rg.lineStyle(1, 0xaaaaaa);
			
			while (rLayer.numChildren > 0) rLayer.removeChildAt(0);
			
			
			var g:Graphics = this.graphics;
			g.clear();
			
			var roughLine_wGap:Number = wGap * _roughLinePerLines;
			var startRoughLineX:Number = _offsetX % roughLine_wGap;
			if (startRoughLineX < 0) startRoughLineX += roughLine_wGap;
			var startX:Number = _offsetX % wGap;
			if (startX < 0) startX += wGap;			
			
			//var maxWidth:Number = _viewWidth;
			//
			//if (_withRuler) 
			//{
				//startX += _rulerSize;
				//maxWidth -= (_rulerSize * 2);
			//}
			
			var minRulerX:Number = _rulerSize;
			var maxRulerX:Number = _viewWidth - _rulerSize;
			var topRulerY2:Number = _rulerSize-_rulerSize2;
			var bottomRulerY:Number = _viewHeight - _rulerSize;
			var bottomRulerY2:Number = bottomRulerY + _rulerSize2;
			
			var tf:TextField, rect:Rectangle;
			var format:TextFormat = new TextFormat();
			format.size = 10;
			
			while (startX <= _viewWidth)
			{
				g.moveTo(startX, 0);
				
				if (_roughEnabled && Math.abs(startX - startRoughLineX) <= 1)
				{
					g.lineStyle(_roughLineTickness, _roughLineColor, _roughLineAlpha);
					startRoughLineX += roughLine_wGap;
					
					
					if (_withRuler && startX > minRulerX && startX < maxRulerX)
					{
						rg.moveTo(startX, 0);
						rg.lineTo(startX, _rulerSize);
						rg.moveTo(startX, bottomRulerY);
						rg.lineTo(startX, _viewHeight);
						
						tf = new TextField();
						tf.autoSize = TextFieldAutoSize.LEFT;
						tf.defaultTextFormat = format;
						tf.text = String(Math.round((startX - _offsetX) / _scaleRate));
						tf.textColor = (tf.text == '0') ? 0x00ff00 : 0xcccccc;						
						tf.selectable = false;
						
						tf.x = startX;
						tf.y = -4;
						
						rect = tf.getBounds(rLayer);						
						if (rect.right < maxRulerX) rLayer.addChild(tf);
					}
					
				}
				else
				{			
					g.lineStyle(_lineTickness, _lineColor, _lineAlpha);
					
					if (_withRuler && startX > minRulerX && startX < maxRulerX)
					{
						rg.moveTo(startX, topRulerY2);
						rg.lineTo(startX, _rulerSize);
						rg.moveTo(startX, bottomRulerY);
						rg.lineTo(startX, bottomRulerY2);
					}
				}
				
				g.lineTo(startX, _viewHeight); 
				
				
				
				startX += wGap;
			}
			
			var minRulerY:Number = _rulerSize;
			var maxRulerY:Number = _viewHeight - _rulerSize;
			var leftRulerX2:Number = _rulerSize-_rulerSize2;
			var rightRulerX:Number = _viewWidth - _rulerSize;
			var rightRulerX2:Number = rightRulerX + _rulerSize2;
			
			var roughLine_hGap:Number = hGap * _roughLinePerRows;
			var startRoughLineY:Number = _offsetY % roughLine_hGap;
			if (startRoughLineY < 0) startRoughLineY += roughLine_hGap;
			var startY:Number = _offsetY % hGap;
			if (startY < 0) startY += hGap;
			while (startY <= _viewHeight)
			{
				g.moveTo(0, startY);
				
				if (_roughEnabled && Math.abs(startY - startRoughLineY) <= 1)
				{
					g.lineStyle(_roughLineTickness, _roughLineColor, _roughLineAlpha);
					startRoughLineY += roughLine_hGap;
					
					if (_withRuler && startY > minRulerY && startY < maxRulerY)
					{
						rg.moveTo(0, startY);
						rg.lineTo(_rulerSize, startY);
						rg.moveTo(rightRulerX, startY);
						rg.lineTo(_viewWidth, startY);
						
						tf = new TextField();
						tf.defaultTextFormat = format;
						tf.autoSize = TextFieldAutoSize.LEFT;
						tf.embedFonts = true;
						tf.text = String(Math.round((startY - _offsetY)/_scaleRate));
						tf.textColor = (tf.text == '0') ? 0x00ff00 : 0xcccccc;						
						tf.selectable = false;
						
						tf.rotation = -90;
						tf.x = -3;
						tf.y = startY;
						
						
						rect = tf.getBounds(rLayer);						
						if (rect.top > minRulerY) rLayer.addChild(tf);
						//rLayer.addChild(tf);
					}
				}
				else
				{			
					g.lineStyle(_lineTickness, _lineColor, _lineAlpha);
					
					if (_withRuler && startY > minRulerY && startY < maxRulerY)
					{
						rg.moveTo(_rulerSize-3, startY);
						rg.lineTo(_rulerSize, startY);
						rg.moveTo(rightRulerX, startY);
						rg.lineTo(rightRulerX2, startY);
					}
				}
				
				g.lineTo(_viewWidth, startY); 
				startY += hGap;
			}
			
			//if (_withRuler) updateRuler();
			
		}
		
		protected function updateRuler():void
		{
			var g:Graphics = _ruler.graphics;
			g.beginFill(0x333333);
			
			GraphicDrawer.drawBorder(g, new Rectangle(0, 0, _viewWidth, _viewHeight), 0x333333, 1, 0, _rulerSize );
			/*
			g.moveTo(0, 0);
			g.lineTo(_viewWidth, 0);
			g.lineTo(_viewWidth, bSize);
			g.lineTo(bSize, bSize);
			g.lineTo(bSize, _viewHeight);
			g.lineTo(0, _viewHeight);
			*/
			
		}
		
		/************************
		*         params
		************************/
		protected var _lineColor:uint = 0x999999;
		protected var _lineTickness:Number = 0;
		protected var _lineAlpha:Number = 1;
		
		protected var _viewWidth:Number = 800;
		public function get viewWidth():Number { return _viewWidth; }
		
		protected var _viewHeight:Number = 600;
		public function get viewHeight():Number { return _viewHeight; }
		
		protected var _wGap:Number = 50;
		protected function get wGap():Number { return _wGap * _scaleRate; }
		protected var _hGap:Number = 50;
		protected function get hGap():Number { return _hGap * _scaleRate; }
		
		protected var _roughLineColor:uint = 0xaa7777;
		protected var _roughLineTickness:Number = 2;
		protected var _roughLineAlpha:Number = 1;
		
		protected var _roughEnabled:Boolean = true;
		protected var _roughLinePerLines:uint = 5;
		protected var _roughLinePerRows:uint = 5;
		
		protected var _offsetX:Number = 0;
		protected var _offsetY:Number = 0;
		
		protected var _scaleRate:Number = 1;
		
		private var _withRuler:Boolean = true;
		public function get withRuler():Boolean { return _withRuler; }
		
		private var _ruler:Sprite;
		public function get ruler():Sprite { return _ruler; }
		
		private var _rulerSize:Number = 9;
		private var _rulerSize2:Number = 3;
		
		private var _rulerBaseColor:int = 0x333333;
	}

}