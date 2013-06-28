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
			_direction = (params.direction == undefined) ? 'left' : params.direction;
			super(faceBitmapData, params);
		}		
		
		public function flip(flipTime:Number = 0.8, totalDelay:Number = 0.15, floatRange:Number = 100):void
		{
			var dDelay:Number = totalDelay / (numCol * numRow);		
			
			if (_state == 'fliping') return;
			_state = 'fliping';
			
			var floatTime:Number = flipTime / 2;
			var floatDelay:Number = floatTime + 0.05;
			var floatDownTime:Number = floatTime - 0.05;
			
			var row:int, col:int, point:DP, ty:Number, tx:Number, delay:Number = 0;
			
			switch(_direction)
			{			
				case 'top':
					for (col = numCol; col >= 0; col--)
					{
						for (row = 0; row <= numRow; row++)
						{
							point = dpArray[row][col];
							tx = point.tx + floatRange * row/ numRow;
							
							Tweener.addTween(point, { time:flipTime, delay:delay, y:factor * point.ty, transition:'easeInOutCubic' } );
							Tweener.addTween(point, { time:floatTime, delay:delay, x:tx, transition:'easeInSine' } );
							Tweener.addTween(point, { time:floatDownTime, delay:delay + floatDelay, x: point.tx, transition:'easeOutSine' } );
							delay += dDelay;
						}
					}
				break;
				
				default:
					for (row = 0; row <= numRow; row++)
					{
						for (col = 0; col <= numCol; col++)
						{
							point = dpArray[row][col];
							ty = point.ty - floatRange * col/ numCol;
							
							Tweener.addTween(point, { time:flipTime, delay:delay, x: factor * point.tx, transition:'easeInOutCubic' } );
							Tweener.addTween(point, { time:floatTime, delay:delay, y: ty, transition:'easeInSine' } );
							Tweener.addTween(point, { time:floatDownTime, delay:delay + floatDelay, y: point.ty, transition:'easeOutSine' } );
							delay += dDelay;					
						}
					}
			}
			
			Tweener.addTween(this, { time:floatDownTime, delay:delay + floatDelay, onComplete:flipComplete } );
			
			//Tweener.addTween(this, { time:delay+1, onComplete:flipComplete } );
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(evt:Event):void
		{
			draw();
		}
		
		protected function flipComplete():void
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			state = (factor == -1) ? 'back' : 'face';
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		override public function destroy():void
		{		
			Tweener.removeTweens(this);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			super.destroy();
		}
		
		private var _direction:String = 'left';
		
		public static const START_STATE_BACK:String = 'back';
		public static const START_STATE_FACE:String = 'face';
	}
}
