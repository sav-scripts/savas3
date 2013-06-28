package sav.gp.simple_canvas.methods
{
	import flash.display.Graphics;
	public class SmoothLine implements IDrawMethod
	{
		/**
		 * <p>Default value of drawing method properties, notice every params in constructor have a copy of public property with same name in this class.</p>
		 * 
		 * @param	thickness	Line thickness
		 * @param	lineColor	Line color
		 * @param	lineAlpha	Line Alpha
		 * @param	stepGap		Decide how many step of mouse moving will be ignored, line will be more smooth when this value larger
		 */
		public function SmoothLine(thickness:Number = 2, lineColor:uint = 0x00000, lineAlpha:uint = 1, stepGap:uint = 5):void 
		{
			this.thickness = thickness;
			this.lineColor = lineColor;
			this.lineAlpha = lineAlpha;			
			this.stepGap = stepGap;
			
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
			_count ++;
			if (_count % stepGap != 0) return;
			_count = 0;
			
			_dotArray.push( { x:mouseX, y:mouseY } );
			
			if (_dotArray.length >= 3)
			{
				redraw(_g);
			}
		}
		
		public function mouseUpHandler(mouseX:Number, mouseY:Number):Boolean
		{
			if (_dotArray.length < 3) return false;
			if ((_dotArray.length - 1) % 2 == 1) _dotArray.pop();
			return true;
		}
		
		public function redraw(targetCanvas:*):void
		{
			if (!(targetCanvas is canvasType)) throw new Error('Illegal target canvas type');
			
			_g = targetCanvas;
			
			_g.clear();
			_g.lineStyle(thickness, lineColor, lineAlpha);
			
			var p0:Object, p1:Object;
			p0 = _dotArray[0];
			_g.moveTo(p0.x, p0.y);	
			
			var i:uint, l:uint = _dotArray.length - 1;
			for (i = 1; i < l; i++) 
			{
				p0 = _dotArray[i];
				p1 = _dotArray[i + 1];
				if (i == (l-1)) 
				{
					_g.curveTo(p0.x, p0.y, p1.x, p1.y);
				}
				else
				{
					var tp:Object = { x:(p0.x + p1.x) / 2, y:(p0.y + p1.y) / 2 };
					_g.curveTo(p0.x, p0.y, tp.x, tp.y);
				}
			}
		}
		
		public function semiClone():IDrawMethod
		{
			return new SmoothLine(thickness, lineColor, lineAlpha);
		}
		
		/*
		public function getSaveData():Object
		{		
			var saveData:Object		= { };
			saveData.methodStamp	= 'sav.gp.simple_canvas.methods.CurveLine';
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
		public var stepGap:uint;
		
		private var _count:uint = 0;
		
		public function get canvasType():Class { return Graphics; }		
	}	
}