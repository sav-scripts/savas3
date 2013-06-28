package sav.gp.simple_canvas.methods
{
	import flash.display.Graphics;
	public class Rect implements IDrawMethod
	{
		/**
		 * Default value of drawing method properties, notice every params in constructor have a copy of public property with same name in this class.
		 * 
		 * @param	color		Inner color
		 * @param	alpha		Inner alpha
		 * @param	thickness	Line thickness, default value is Number.NaN(no line)
		 * @param	lineColor	Line color
		 * @param	lineAlpha	Line alpha
		 */
		public function Rect(color:uint = 0x000000, alpha:Number = 1, thickness:Number = Number.NaN, lineColor:uint = 0x000000, lineAlpha:uint = 1):void 
		{					
			this.color = color;
			this.alpha = alpha;
			this.thickness = thickness;
			this.lineColor = lineColor;
			this.lineAlpha = lineAlpha;
			
			_dotArray = new Vector.<Object>(2, true);
		}
		
		public function mouseDownHandler(targetCanvas:*, mouseX:Number, mouseY:Number):void
		{
			if (!(targetCanvas is canvasType)) throw new Error('Illegal target canvas type');
			
			_g = targetCanvas;
			_dotArray[0] = { x:mouseX, y:mouseY };
			_g.moveTo(mouseX, mouseY);
		}
		
		public function mouseMoveHandler(mouseX:Number, mouseY:Number):void
		{
			var p0:Object = _dotArray[0];
			_g.clear();
			_g.lineStyle(thickness, lineColor, lineAlpha);
			_g.beginFill(color, alpha);
			_g.drawRect(p0.x, p0.y, mouseX - p0.x, mouseY - p0.y);
		}
		
		public function mouseUpHandler(mouseX:Number, mouseY:Number):Boolean
		{
			_dotArray[1] = { x:mouseX, y:mouseY };
			var p0:Object = _dotArray[0];
			var p1:Object = _dotArray[1];
			
			if (p0.x == p1.x && p0.y == p1.y) return false;
			return true;
		}
		
		
		public function redraw(targetCanvas:*):void
		{
			if (!(targetCanvas is canvasType)) throw new Error('Illegal target canvas type');
			
			_g = targetCanvas;
			_g.lineStyle(thickness, lineColor, lineAlpha);
			_g.beginFill(color, alpha);
			
			var p0:Object = _dotArray[0];
			var p1:Object = _dotArray[1];
			
			_g.drawRect(p0.x, p0.y, p1.x - p0.x, p1.y - p0.y);
		}
		
		public function semiClone():IDrawMethod
		{
			return new Rect(color, alpha, thickness, lineColor, lineAlpha);
		}
		
		/*
		public function getSaveData():Object
		{		
			var saveData:Object		= { };
			saveData.methodStamp	= 'sav.gp.simple_canvas.methods.Rect';
			saveData.color			= color;
			saveData.alpha			= alpha;
			saveData.thickness		= thickness;
			saveData.lineColor		= lineColor;
			saveData.lineAlpha		= lineAlpha;
			saveData.dotArray		= _dotArray;	
			
			return saveData;			
		}		
		
		public function redrawSaveData(g:Graphics, saveData:Object):void
		{
			color		= saveData.color;
			alpha		= saveData.alpha;
			thickness	= saveData.thickness;
			lineColor	= saveData.lineColor;
			lineAlpha	= saveData.lineAlpha;
			_dotArray	= saveData.dotArray;
			
			redraw(g);
		}
		*/
		
		public function destroy():void
		{
			_g = null;
			_dotArray = null;
		}
		
		private var _g:Graphics;
		private var _dotArray:Vector.<Object>;
		
		public var color:uint;
		public var alpha:Number;
		
		public var thickness:Number;
		public var lineColor:uint;
		public var lineAlpha:Number;		
		
		public function get canvasType():Class { return Graphics; }		
	}	
}