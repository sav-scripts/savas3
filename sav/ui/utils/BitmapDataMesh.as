package sav.ui.utils
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.TriangleCulling;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	public class BitmapDataMesh extends Sprite
	{
		protected var numCol:uint = 10;
		protected var numRow:uint =7;
		protected var dw:Number = 60;
		protected var dh:Number = 60;
		
		protected var dpArray:Array;
		
		protected var vertices:Vector.<Number> = new Vector.<Number>();
		protected var indices:Vector.<int> = new Vector.<int>();
		protected var uvtData:Vector.<Number> = new Vector.<Number>();
		
		protected var face:Shape;
		protected var back:Shape;
		
		protected var planeLayer:Sprite;
		
		protected var faceBitmapData:BitmapData;
		protected var backBitmapData:BitmapData;
		
		protected var factor:int = -1;
		protected var _state:String = 'face';
		public function get state():String { return _state; }
		public function set state(s:String):void
		{
			if (s != 'face' && s != 'back') throw new Error('Illegal state');
			_state = s;
			if (_state == 'face') 
			{
				factor = -1;
				planeLayer.addChild(face);
			}
			else
			{
				factor = 1;
				planeLayer.addChild(back);
			}
		}
		
		protected var smooth:Boolean = true;
		
		public function BitmapDataMesh(faceBitmapData:BitmapData, params:Object = null):void
		{
			if (params == null) params = { };
			
			var colSegments:uint =		(params.colSegments != undefined) ?	params.colSegments		:	5;
			var backColor:uint =		(params.backColor != undefined) ?	params.backColor 		:	0x000000;
			var backAlpha:Number =		(params.backAlpha != undefined) ? params.backAlpha : 1;
			var state:String = 			(params.state != undefined)?		params.state			:	'face';
			smooth =		 			(params.smooth != undefined)?		params.smooth			:	true;
			
			this.faceBitmapData = faceBitmapData;			
			this.backBitmapData = this.faceBitmapData.clone();
			
			this.numCol = colSegments;
			this.numRow = Math.floor(this.numCol * faceBitmapData.height / faceBitmapData.width);
			dw = faceBitmapData.width / this.numCol;
			dh = faceBitmapData.height / this.numRow;
			
			var r:uint = backColor >> 16;
			var g:uint = backColor >> 8 & 0xFF
			var b:uint = backColor  & 0xFF;
			
			var rect:Rectangle = new Rectangle(0, 0, backBitmapData.width, backBitmapData.height);
			var colorTransform:ColorTransform = new ColorTransform(0, 0, 0, backAlpha, r, g, b, 0);
			this.backBitmapData.colorTransform(rect, colorTransform);
			
			dpArray = [];
			
			var mx:int = (state == 'face') ? 1 : -1;
			var row:uint, col:uint, indStep:uint = 0;
			for (row = 0; row <= numRow; row++)
			{
				dpArray[row] = [];
				for (col = 0; col <= numCol; col++)
				{
					var dp:DP = new DP(col * dw, row * dh);
					dp.x *= mx;
					dpArray[row][col] = dp;	
					
					if (row == numRow || col == numCol) continue;
					uvtData.push(col / numCol, row / numRow, (col + 1) / numCol, row / numRow, (col + 1) / numCol, (row + 1) / numRow, col / numCol, (row + 1) / numRow);										
					indices.push(indStep,indStep+1,indStep+3,indStep+1,indStep+2,indStep+3);					
					indStep+=4;
				}
			}
			
			planeLayer = new Sprite();
			addChild(planeLayer);
			
			back = new Shape();
			planeLayer.addChild(back);
			
			face = new Shape();
			planeLayer.addChild(face);
			
			this.state = state;
			
			draw();
		}
		
		protected function draw():void
		{
            vertices = new Vector.<Number>();
			var a:Array = dpArray;
            
			var row:uint,col:uint
            for (row = 0; row < numRow; row++)
			{
                for (col = 0; col < numCol; col++) 
				{					
					vertices.push(a[row][col].x, a[row][col].y);
					vertices.push(a[row][col+1].x, a[row][col+1].y);
					vertices.push(a[row+1][col+1].x, a[row+1][col+1].y);
					vertices.push(a[row+1][col].x, a[row+1][col].y);
                }
            }	
			
			doBitmapFill();
		}
		
		protected function doBitmapFill():void
		{	
            var g:Graphics = face.graphics;
            g.clear();			
            g.beginBitmapFill(faceBitmapData, null, false, true);
            g.drawTriangles(vertices, indices, uvtData, TriangleCulling.NEGATIVE);
            g.endFill();
			
            g = back.graphics;
            g.clear();			
            g.beginBitmapFill(backBitmapData, null, false, true);
            g.drawTriangles(vertices, indices, uvtData, TriangleCulling.POSITIVE);
            g.endFill();	
		}
		
		public function destroy():void
		{
			vertices = null;
			
			if (faceBitmapData)
			{
				faceBitmapData.dispose();
				faceBitmapData = null;
			}
			
			if (backBitmapData)
			{
				backBitmapData.dispose();
				backBitmapData = null;				
			}
			
			planeLayer.removeChild(face);
			planeLayer.removeChild(back);
			removeChild(planeLayer);
			
			if (parent) parent.removeChild(this);
		}
	}
}

