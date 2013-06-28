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
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	public class PlaneFliper extends BitmapDataMesh
	{
		public function PlaneFliper(faceBitmapData:BitmapData, params:Object = null):void
		{
			if (params == null) params = { };
			super(faceBitmapData, params);
		}		
		
		public function flip(flipTime:Number = 0.8, totalDelay:Number = 0.15, floatY:Number = 100):void
		{
			var dDelay:Number = totalDelay / (numCol * numRow);			
			
			flipId = '';
			
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
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		public function flipV2(id:String):void
		{
			if (!flipDataArray[id]) throw new Error('flipId not exist');
			flipId = id;	
			
			var flipData:FlipData = flipDataArray[flipId];
			
			currentStep = (state == 'face') ? 0 : flipData.toBackStep;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private static var flipDataArray:Array = [];
		
		private var oldState:String;
		private var flipId:String = '';
		private var timer:Timer;
		private var dispatcher:EventDispatcher;
		private var calculateCount:uint = 0;
		private var currentStep:uint;
		
		private var currentTime:Number;
		private var dDelay:Number;
		private var totalDelay:Number;
		
		private var movingCount:int = 0;
		
		public function preCalculate(id:String, flipTime:Number = 0.8, totalDelay:Number = 0.15, floatY:Number = 100):void
		{
			var flipData:FlipData = new FlipData();
			
			calculateCount = 0;
			
			dDelay = totalDelay / (numCol * numRow);
			currentTime = 0;
			
			movingCount = 0;
			
			flipId = id;
			flipDataArray[id] = flipData;
			
			oldState = state;
			//state = 'face';
			
			timer = new Timer(2);
			timer.addEventListener(TimerEvent.TIMER, timerTick);
			timer.start();
		}
		
		private function timerTick(evt:TimerEvent):void
		{
			var dpChanged:Boolean = false;
			
			var row:uint, col:uint, delay:Number = 0, dp:DP, tx:Number, dx:Number, count:int = 0;
			for (row = 0; row <= numRow; row++)
			{
				for (col = 0; col <= numCol; col++)
				{					
					dp = dpArray[row][col];
					tx = dp.tx * factor;
					
					var pointTime:Number = delay * dDelay;
					
					if (count > movingCount) break;
					if (tx == dp.x) continue;
					dpChanged = true;
					
					dx = (tx - dp.x) * 0.2;
					if (Math.abs(dx) < 0.1)
					{
						dp.x = tx;
					}
					else
					{
						dp.x += dx;
					}
					
					//delay ++;
					count++;
				}
				
				if (count > movingCount) break;
			}
			
			//currentTime += 0.033;
			movingCount += 20;
			
			if (dpChanged == false)
			{
				if (calculateCount == 1)
				{
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER, timerTick);
					timer = null;
					
					state = oldState;
					if (state == 'back') FlipData(flipDataArray[flipId]).invert();	
					trace(FlipData(flipDataArray[flipId]).vData.length);			
					flipId = '';				
					
					dispatchEvent(new Event('preCalculateComplete'));
					
				}
				else
				{
					calculateCount = 1;
					state = (state == 'face') ? 'back' : 'face';
					currentTime = 0;
					movingCount = 0;
				}
				return;
			}
			
			var vertices:Vector.<Number> = new Vector.<Number>();
			var a:Array = dpArray;
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
			var flipData:FlipData = flipDataArray[flipId];
			flipData.vData.push(vertices);
			(calculateCount == 0) ? flipData.toBackStep++ : flipData.toFaceStep++;
		}
		
		private function enterFrameHandler(evt:Event):void
		{
			draw();
		}
		
		override protected function draw():void 
		{
			if (flipId == '' || !flipDataArray[flipId])
			{			
				super.draw();
			}
			else
			{
				var flipData:FlipData = flipDataArray[flipId];
				
				vertices = flipData.vData[currentStep];
				doBitmapFill();
				
				currentStep ++;				
				if (currentStep == flipData.toBackStep || currentStep == flipData.totalStep) flipComplete();
			}
		}
		
		protected function flipComplete():void
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			state = (factor == -1) ? 'back' : 'face';
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
	}
}

class FlipData
{	
	public var vData:Vector.<Vector.<Number>>;
	public var toBackStep:uint;
	public var toFaceStep:uint;
	public function get totalStep():uint { return (toBackStep + toFaceStep); }
	
	public function FlipData()
	{
		vData = new Vector.<Vector.<Number>>();
	}
	
	public function invert():void
	{
		for (var i = 0; i < toBackStep; i++)
		{
			var data:* = vData.shift();
			vData.push(data);
		}
		
		var step:uint = toFaceStep;
		toBackStep = toFaceStep;
		toFaceStep = step;
	}
}