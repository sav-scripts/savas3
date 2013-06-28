package sav.effects.pixelswarm
{
	import flash.events.*;
	import flash.display.*;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.*;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import caurina.transitions.Tweener
	
	public class PixelSwarm extends EventDispatcher
	{
		public function PixelSwarm(source:DisplayObject, tx:Number, ty:Number, targetClip:DisplayObject = null):void
		{
			//if (!(source is IBitmapDrawable)) throw new Error("Source need be IBitmapDrawable");
			if (!source.parent) throw new Error("Source must have parent");
			
			_source = source;
			_parent = _source.parent;
			_tx = tx;
			_ty = ty;
			_targetClip = targetClip;
			
			var oldTimer:Number = getTimer();
			
			buildCanvas();
			buildUnits();
			
			trace('build complete in ' + (getTimer() - oldTimer));
			
			
		}
		
		
		/***************************
		 * 		Building phase
		 * ************************/		
		private function buildUnits():void
		{
			_unitList = new Vector.<SwarmUnit>();
			
			var bound:Rectangle = _source.getBounds(_parent);
			
			var dx:Number = _tx - _source.x;
			var dy:Number = _ty - _source.y;
			
			var startX:uint, startY:uint;
			
			var maxWidth:Number = bound.width;
			var maxHeight:Number = bound.height;
			
			var zeroPoint:Point = new Point();
			
			
			startY = 0;
			while (startY < maxHeight)
			{
				startX = 0;
				while (startX < maxWidth)
				{
					var sx:Number = startX + _source_x_in_canvas;
					var sy:Number = startY + _source_y_in_canvas;
					
					//dx = (sx - _source_center_in_canvas.x);
					//dy = (sy - _source_center_in_canvas.y);
					
					dx = Math.random() * 100 -50;
					dy = Math.random() * 100 -50;
					
					//dx = dy = 0;
					
					var aRGB:uint = _sourceBMD.getPixel32(sx, sy);
					
					var unit:SwarmUnit = new SwarmUnit(sx, sy, dx, dy, _unitWidth, _unitHeight, aRGB);
					
					var testResult:Boolean = _sourceBMD.hitTest(zeroPoint, 0x01, unit.rect);
					if (testResult) _unitList.push(unit);
					//_unitList.push(unit);
					
					startX += _unitWidth;
				}				
				startY += _unitHeight;
			}
			
			_unitAmount = _unitList.length;
			trace('list length = ' + _unitAmount);
			
			//_unitList.sort(sortFunc2);
			
			_startList = new Vector.<SwarmUnit>();
			_startList = _unitList.concat(_unitList);
			
			_activedList = new Vector.<SwarmUnit>();
			//_activedList = _activedList.concat(_unitList);
			//trace(_activedList.length);
			//_unitList = new Vector.<SwarmUnit>();
			_completedList = new Vector.<SwarmUnit>();
		}
		
		private function sortFunc(a:SwarmUnit, b:SwarmUnit):Number
		{
			var pointA:Point = new Point(a.sx - _source_center_in_canvas.x, a.sy - _source_center_in_canvas.y);
			var pointB:Point = new Point(b.sx - _source_center_in_canvas.x, b.sy - _source_center_in_canvas.y);
			
			
			if (pointA.length > pointB.length)
			{
				return 1;
			}
			else if (pointA.length < pointB.length)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		}
		
		private function sortFunc2(a:SwarmUnit, b:SwarmUnit):Number
		{
			//var pointA:Point = new Point(a.sx - _source_center_in_canvas.x, a.sy - _source_center_in_canvas.y);
			//var pointB:Point = new Point(b.sx - _source_center_in_canvas.x, b.sy - _source_center_in_canvas.y);
			
			
			if (a.brigtness > b.brigtness)
			{
				return 1;
			}
			else if (a.brigtness < b.brigtness)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		}
		
		private function buildCanvas():void
		{	
			var dx:Number = _tx - _source.x;
			var dy:Number = _ty - _source.y;
			
			var sourceStartBound:Rectangle = _source.getBounds(_parent);
			var sourceEndBound:Rectangle = sourceStartBound.clone();
			sourceEndBound.offset(dx, dy);	
			
			var targetStartBound:Rectangle = _targetClip.getBounds(_parent);
			var targetEndBound:Rectangle = targetStartBound.clone();
			targetEndBound.offset(dx, dy);
			
			var canvasBound:Rectangle = sourceStartBound.union(sourceEndBound).union(targetStartBound).union(targetEndBound);
			
			_source_x_in_canvas = sourceStartBound.left - canvasBound.left;
			_source_y_in_canvas = sourceStartBound.top - canvasBound.top;
			
			_source_center_in_canvas = new Point();
			_source_center_in_canvas.x = _source.x - canvasBound.x;
			_source_center_in_canvas.y = _source.y - canvasBound.y;
			
			var tempSprite:Sprite = new Sprite();
			_parent.addChildAt(tempSprite, _parent.getChildIndex(_source));
			tempSprite.addChild(_source);
			_sourceBMD = new BitmapData(canvasBound.width, canvasBound.height, true, 0x0000ff00);
			
			var matrix:Matrix = new Matrix();
			matrix.translate(-canvasBound.left, -canvasBound.top);			
			_sourceBMD.draw(tempSprite, matrix);
			
			_parent.addChildAt(_source, _parent.getChildIndex(tempSprite));
			
			_targetClip.x = _source.x;
			_targetClip.y = _source.y;
			tempSprite.addChild(_targetClip);
			_targetBMD = new BitmapData(canvasBound.width, canvasBound.height, true, 0x0000ff00);
			_targetBMD.draw(tempSprite, matrix);			
			
			_parent.removeChild(tempSprite);
			
			//var bitmap:Bitmap = new Bitmap(_targetBMD);
			//bitmap.x = canvasBound.x;
			//bitmap.y = canvasBound.y;
			//_parent.addChild(bitmap);
			
			_canvasBMD = new BitmapData(canvasBound.width, canvasBound.height, true, 0x00ff0000);
			_canvas = new Bitmap(_canvasBMD);
			_canvas.x = canvasBound.x;
			_canvas.y = canvasBound.y;
			
			var rect:Rectangle = new Rectangle(_source_x_in_canvas, _source_y_in_canvas, sourceStartBound.width, sourceStartBound.height);
			var pt:Point = new Point(sourceStartBound.x - canvasBound.x, sourceStartBound.y - canvasBound.y);
			_canvasBMD.copyPixels(_sourceBMD, rect, pt);
		}
		
		
		/****************************
		 *		Playing phase
		 * *************************/
		public function start():void
		{
			_parent.addChildAt(_canvas, _parent.getChildIndex(_source));
			_parent.removeChild(_source);
			
			var oldTimer:Number = getTimer();
			
			_timer = new Timer(40);
			_timer.addEventListener(TimerEvent.TIMER, timerTick);
			
			_timer.start();
		}
		
		private function timerTick(evt:TimerEvent):void
		{
			var oldTimer:Number = getTimer();
			
			//applyBlur();
			activeSome();
			render();
			
			_renderTimeTotal += (getTimer() - oldTimer);
			_numTick ++;
			
			//var unit:SwarmUnit = _activedList[1000];
			//var alpha:uint = unit.color >> 24;
			//trace('alpha = ' + alpha.toString(16));
			
			//if (_completedList.length == _unitAmount)
			if (_unitList[_unitAmount-1].progress == 0)
			{
				_timer.stop();			
				trace('all complete, average render time = ' + (_renderTimeTotal / _numTick) + ' ms.');
				
				//_targetClip.x = _tx;
				//_targetClip.y = _ty;
				//
				//_parent.addChildAt(_targetClip, _parent.getChildIndex(_canvas));
				//_parent.removeChild(_canvas);
				//
				//destroy();
			}
		}
		
		private function applyBlur():void
		{
			var scale:Number = _activedList.length / _unitAmount * 10;
			_canvas.filters = [new BlurFilter(scale,scale)];
		}
		
		private function activeSome():void
		{
			var i:uint, l:uint = int(_unitAmount/20);
			var unit:SwarmUnit;
			
			for (i = 0; i < l; i++)
			{
				if (_startList.length == 0) break;
				_activedList.push(_startList.shift());
			}
		}
		
		private function render():void
		{
			var rect:Rectangle = new Rectangle(0, 0, _canvasBMD.width, _canvasBMD.height);
			var pt:Point = new Point();;
			_canvasBMD.fillRect(rect, 0x00000000);
			
			var unit:SwarmUnit;			
			
			for each(unit in _startList)
			{
				pt.x = unit.sx;
				pt.y = unit.sy;
				//_canvasBMD.copyPixels(_sourceBMD, unit.rect, pt);
				_canvasBMD.setPixel32(pt.x, pt.y, unit.color);
			}
			
			
			var i:int, l:int = _activedList.length;
			var randomX:Number;
			var randomY:Number;
			for (i = 0; i < l;i++)
			{
				unit = _activedList[i];
				
				unit.progress -= 0.05;
				
				//if (unit.progress == 0)
				//{
					//_completedList.push(unit);
					//_activedList.splice(i, 1);
					//i--;
					//l--;
				//}
				//else
				//{				
					//randomX = Math.random() * 100 - 50;
					//randomY = Math.random() * 100 - 50;
					//pt.x = unit.dx + randomX * unit.scale;
					//pt.y = unit.dy + randomY * unit.scale;
					
					pt.x = unit.dx;
					pt.y = unit.dy;
					
					_canvasBMD.setPixel32(pt.x, pt.y, unit.color);
					
					//if (unit.progress > 0.5)
						//_canvasBMD.copyPixels(_sourceBMD, unit.rect, pt);
					//else
						//_canvasBMD.copyPixels(_targetBMD, unit.rect, pt);
				//}
			}
			
			for each(unit in _completedList)
			{
				pt.x = unit.tx;
				pt.y = unit.ty;
				//_canvasBMD.copyPixels(_sourceBMD, unit.rect, pt);
				_canvasBMD.setPixel32(pt.x, pt.y, unit.color);
			}
		}
		
		
		/***********************
		 * 		Misc
		 * ********************/
		public function destroy():void
		{
			if (_timer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, timerTick);
				_timer = null;
			}
		}
		 
		
		/***********************
		 * 		Params
		 * ********************/
		private var _parent:DisplayObjectContainer;
		
		private var _source:DisplayObject;
		private var _sourceBMD:BitmapData;
		
		private var _targetClip:DisplayObject;
		private var _targetBMD:BitmapData;
		
		private var _canvas:Bitmap;
		private var _canvasBMD:BitmapData;
		
		private var _timer:Timer;		
		
		private var _randomX:Number = 10;
		private var _randomY:Number = 10;
		
		private var _unitWidth:uint = 1;
		private var _unitHeight:uint = 1;
		
		private var _source_x_in_canvas:Number;
		private var _source_y_in_canvas:Number;
		
		private var _source_center_in_canvas:Point;
		
		private var _unitList:Vector.<SwarmUnit>;
		private var _startList:Vector.<SwarmUnit>;
		private var _activedList:Vector.<SwarmUnit>;
		private var _completedList:Vector.<SwarmUnit>;
		
		private var _unitAmount:uint;
		
		private var _tx:Number;
		private var _ty:Number;
		
		private var _numTick:uint = 0;
		private var _renderTimeTotal:Number = 0;
	}
}