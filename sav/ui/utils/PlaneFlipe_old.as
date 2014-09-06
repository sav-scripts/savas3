package sav.ui.utils
{
	import caurina.transitions.Tweener;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.TriangleCulling;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	public class PlaneFliper extends Sprite
	{
		protected var numCol:uint = 10;
		protected var numRow:uint =7;
		protected var dw:Number = 60;
		protected var dh:Number = 60;
		
		protected var floatY:Number = 100;
		
		protected var dDelay:Number;
		
		protected var dpArray:Array;
		
		protected var maxLength:Number;
		protected var currentLength:Number;
		
		protected var indices:Vector.<int> = new Vector.<int>();
		protected var uvtData:Vector.<Number> = new Vector.<Number>();
		
		protected var flipTime:Number = 0.8;
		
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
		
		protected var face:Shape;
		protected var back:Shape;
		
		protected var planeLayer:Sprite;
		
		protected var faceBitmapData:BitmapData;
		protected var backBitmapData:BitmapData;
		
		public function PlaneFliper(faceBitmapData:BitmapData, params:Object = null):void
		{
			if (params == null) params = { };
			
			var colSegments:uint =		(params.colSegments != undefined) ?	params.colSegments		:	5;
			var backColor:uint =		(params.backColor != undefined) ?	params.backColor 		:	0x000000;
			var state:String = 			(params.state != undefined)?		params.state			:	'face';
			this.floatY		 = 			(params.floatY != undefined)?		params.floatY			:	100;
			
			this.faceBitmapData = faceBitmapData;			
			this.backBitmapData = this.faceBitmapData.clone();
			
			this.numCol = colSegments;
			this.numRow = Math.floor(this.numCol * faceBitmapData.height / faceBitmapData.width);
			dw = faceBitmapData.width / this.numCol;
			dh = faceBitmapData.height / this.numRow;
			
			var r:uint = backColor >> 16;
			var g:uint = (backColor >> 8) % 0x100;
			var b:uint = backColor % 0x100;
			
			dDelay = 0.15 / (numCol * numRow)
			
			var rect:Rectangle = new Rectangle(0, 0, backBitmapData.width, backBitmapData.height);
			var colorTransform:ColorTransform = new ColorTransform(0, 0, 0, 1, r, g, b, 0);
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
		
		public function flip():void
		{
			if (_state == 'fliping') return;
			_state = 'fliping';
			
			var floatTime:Number = flipTime / 2;
			var floatDelay:Number = floatTime + 0.05;
			var floatDownTime:Number = floatTime - 0.05;
			
			var row:uint, col:uint, delay:Number = 0;
			for (row = 0; row <= numRow; row++)
			{
				for (col = 0; col <= numCol; col++)
				{
					var point:DP = dpArray[row][col];
					var ty:Number = point.ty - floatY * col/ numCol;
					
					Tweener.addTween(point, { time:flipTime, delay:delay, x: factor * point.tx, transition:'easeInOutCubic' } );
					Tweener.addTween(point, { time:floatTime, delay:delay, y: ty, transition:'easeInSine' } );
					Tweener.addTween(point, { time:floatDownTime, delay:delay + floatDelay, y: point.ty, transition:'easeOutSine' } );
					delay += dDelay;
				}
			}
			
			Tweener.addTween(this, { time:delay+1, onComplete:flipComplete } );			
			addEventListener(Event.ENTER_FRAME, draw);
		}
		
		protected function flipComplete():void
		{
			removeEventListener(Event.ENTER_FRAME, draw);
			state = (factor == -1) ? 'back' : 'face';
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function draw(evt:Event = null):void
		{
            var vertices:Vector.<Number> = new Vector.<Number>();
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
			faceBitmapData.dispose();
			backBitmapData.dispose();
			backBitmapData = null;
			faceBitmapData = null;
			
			planeLayer.removeChild(face);
			planeLayer.removeChild(back);
			removeChild(planeLayer);
			
			removeEventListener(Event.ENTER_FRAME, draw);
			
			if (parent) parent.removeChild(this);
		}
	}
}

class DP
{
	public var x:Number;
	public var y:Number;
	public var tx:Number;
	public var ty:Number;
	
	public function DP(x:Number, y:Number)
	{
		this.x = tx = x;
		this.y = ty = y;
	}
}