package sav.gp.simple_canvas.methods
{
	import flash.display.Graphics;
	import flash.utils.ByteArray;
	public class Line implements IDrawMethod
	{
		/**
		 * <p>Default value of drawing method properties, notice every params in constructor have a copy of public property with same name in this class.</p>
		 * 
		 * @param	thickness	Line thickness
		 * @param	lineColor	Line color
		 * @param	lineAlpha	Line Alpha
		 */
		public function Line(thickness:Number = 2, lineColor:uint = 0x00000, lineAlpha:uint = 1):void 
		{
			this.thickness = thickness;
			this.lineColor = lineColor;
			this.lineAlpha = lineAlpha;
			
			_dotArray = new Vector.<Object>();
		}
		
		public function mouseDownHandler(targetCanvas:*, mouseX:Number, mouseY:Number):void
		{
			if (!(targetCanvas is canvasType)) throw new Error('Illegal target canvas type');
			
			_g = targetCanvas;
			_g.lineStyle(thickness, lineColor, lineAlpha);
			_g.endFill();
			
			_dotArray.push( { x:mouseX, y:mouseY } );
			_g.moveTo(mouseX, mouseY);
		}
		
		public function mouseMoveHandler(mouseX:Number, mouseY:Number):void
		{
			_dotArray.push( { x:mouseX, y:mouseY } );
			
			if (_dotArray.length < 2) return;
			
			_g.lineTo(mouseX, mouseY);
		}
		
		public function mouseUpHandler(mouseX:Number, mouseY:Number):Boolean
		{
			if (_dotArray.length < 2) return false;
			return true;
		}
		
		public function redraw(targetCanvas:*):void
		{
			if (!(targetCanvas is canvasType)) throw new Error('Illegal target canvas type');
			
			_g = targetCanvas;
			
			_g.lineStyle(thickness, lineColor, lineAlpha);
			_g.endFill();
			
			var i:uint, l:uint = _dotArray.length;
			for (i = 0; i < l; i++)
			{
				var dot:Object = _dotArray[i];
				if (i == 0)
					_g.moveTo(dot.x, dot.y);
				else
					_g.lineTo(dot.x, dot.y);
			}
		}
		
		public function semiClone():IDrawMethod
		{
			
			return new Line(thickness, lineColor, lineAlpha);
		}
		
		/*
		public function getSaveData():Object
		{		
			var saveData:Object		= { };
			saveData.methodStamp	= 'sav.gp.simple_canvas.methods.Line';
			saveData.thickness		= thickness;
			saveData.lineColor		= lineColor;
			saveData.lineAlpha		= lineAlpha;
			saveData.dotArray		= _dotArray;	
			
			return saveData;			
		}
		
		public function redrawSaveData(g:Graphics, saveData:Object):void
		{
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
		
		public var thickness:Number;
		public var lineColor:uint;
		public var lineAlpha:uint;
		
		public function get canvasType():Class { return Graphics; }
		
	}	
}