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
		//public function PixelSwarm(source:DisplayObject, tx:Number, ty:Number, targetClip:DisplayObject = null):void
		public function PixelSwarm(
			source:DisplayObject, 
			dx:int = 0, 
			dy:int = 0, 
			unitWidth:uint = 1, 
			unitHeight:uint = 1, 
			sortType:* = SortType.SOURCE_ORIGIN, 
			sortInvert:Boolean = false, 
			removeAlphaZeroUnits:Boolean = true):void
		{
			//if (!(source is IBitmapDrawable)) throw new Error("Source need be IBitmapDrawable");
			if (!source.parent) throw new Error("Source must have parent");
			
			_unitWidth = unitWidth;			
			_unitHeight = unitHeight;
			
			_source = source;
			_parent = _source.parent;
			
			_dx = dx;
			_dy = dy;
			
			var oldTimer:Number = getTimer();
			
			buildCanvas();
			buildUnitList(removeAlphaZeroUnits);
			
			sortUnitList(sortType, sortInvert);
			
			_startList = new Vector.<SwarmUnit>();
			_startList = _unitList.concat(new Vector.<SwarmUnit>());			
			_activedList = new Vector.<SwarmUnit>();
			
			trace('build complete in ' + (getTimer() - oldTimer));
		}
		
		
		/***************************
		 * 		Building phase
		 * ************************/
		private function buildUnitList(removeAlphaZeroUnits:Boolean = true):void
		{
			_unitList = new Vector.<SwarmUnit>();
			
			var bound:Rectangle = _source.getBounds(_parent);
			
			var dx:Number = 0;
			var dy:Number = 0;
			
			var startX:uint, startY:uint;
			
			var maxWidth:Number = bound.width;
			var maxHeight:Number = bound.height;
			
			var zeroPoint:Point = new Point();
			
			var rx2:Number = _randomRangeX * 2;
			var ry2:Number = _randomRangeY * 2;
			
			
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
					
					dx = Math.random() * rx2 - _randomRangeX + _dx;
					dy = Math.random() * ry2 - _randomRangeY + _dy;
					
					//dx = dy = 0;
					
					var aRGB:uint = _sourceBMD.getPixel32(sx, sy);
					
					var unit:SwarmUnit = new SwarmUnit(sx, sy, dx, dy, _unitWidth, _unitHeight, aRGB);
					
					if (!removeAlphaZeroUnits || _sourceBMD.hitTest(zeroPoint, 0x01, unit.rect)) _unitList.push(unit);
					//_unitList.push(unit);
					
					startX += _unitWidth;
				}				
				startY += _unitHeight;
			}
			
			_unitAmount = _unitList.length;
			
			
			trace('list length = ' + _unitAmount);
		}
		
		private function sortUnitList(sortType:* = SortType.SOURCE_ORIGIN, invert:Boolean = false):void
		{	
			var point:Point;
			var bound:Rectangle = _source.getBounds(_parent);
			
			if (sortType is String)
			{
				switch(sortType)
				{
					case SortType.NONE:
						return;
					break;
					
					case SortType.SOURCE_ORIGIN:
						point = new Point(_source.x, _source.y);
					break;
					
					case SortType.TOP_LEFT:
						point = new Point(bound.left, bound.top);
					break;
					
					case SortType.TOP_RIGHT:
						point = new Point(bound.right, bound.top);
					break;
					
					case SortType.BOTTOM_LEFT:
						point = new Point(bound.left, bound.bottom);
					break;
					
					case SortType.BOTTOM_RIGHT:
						point = new Point(bound.right, bound.bottom);
					break;
					
					case SortType.TOP:
						point = new Point(int(bound.x + bound.width / 2), bound.top);
					break;
					
					case SortType.BOTTOM:
						point = new Point(int(bound.x + bound.width / 2), bound.bottom);
					break;
					
					case SortType.LEFT:
						point = new Point(bound.left, int(bound.y + bound.height / 2));
					break;
					
					case SortType.RIGHT:
						point = new Point(bound.right, int(bound.y + bound.height / 2));
					break;
					case SortType.CENTER:
						point = new Point(int(bound.x + bound.width / 2), int(bound.y + bound.height / 2));
					break;
				}
			}
			else if (sortType is Point)
			{
				point = Point(sortType);
			}
			
			if (point)
			{	
				_source_center_in_canvas = new Point();
				_source_center_in_canvas.x = point.x - _canvasBound.x;
				_source_center_in_canvas.y = point.y - _canvasBound.y;
				
				(invert) ? _unitList.sort(sortFunc_invert) : _unitList.sort(sortFunc);	
			}
			else
			{
				throw new Error('illegal sortType : ' + sortType);
			}
			
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
		
		private function sortFunc_invert(a:SwarmUnit, b:SwarmUnit):Number
		{
			var pointA:Point = new Point(a.sx - _source_center_in_canvas.x, a.sy - _source_center_in_canvas.y);
			var pointB:Point = new Point(b.sx - _source_center_in_canvas.x, b.sy - _source_center_in_canvas.y);
			
			
			if (pointA.length > pointB.length)
			{
				return -1;
			}
			else if (pointA.length < pointB.length)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		
		private function buildCanvas():void
		{	
			var dx:Number = _dx;
			var dy:Number = _dy;
			
			var sourceStartBound:Rectangle = _source.getBounds(_parent);
			
			//sourceStartBound.x = int(sourceStartBound.x);
			//sourceStartBound.y = int(sourceStartBound.y);
			//sourceStartBound.width = Math.ceil(sourceStartBound.width);
			//sourceStartBound.height = Math.ceil(sourceStartBound.height);
			
			
			var sourceEndBound:Rectangle = sourceStartBound.clone();
			sourceEndBound.offset(dx, dy);			
			
			_canvasBound = sourceStartBound.union(sourceEndBound);
			_canvasBound.inflate(_randomRangeX, _randomRangeY);
			
			_source_x_in_canvas = sourceStartBound.left - _canvasBound.left;
			_source_y_in_canvas = sourceStartBound.top - _canvasBound.top;
			
			//_canvasBound.x = int(_canvasBound.x);
			//_canvasBound.y = int(_canvasBound.y);
			//_canvasBound.width = Math.ceil(_canvasBound.width);
			//_canvasBound.height = Math.ceil(_canvasBound.height);
			//trace('sourceStartBound = ' + sourceStartBound);
			//trace('canvasBound = ' + _canvasBound);
			
			
			var tempSprite:Sprite = new Sprite();
			_parent.addChildAt(tempSprite, _parent.getChildIndex(_source));
			tempSprite.addChild(_source);
			_sourceBMD = new BitmapData(_canvasBound.width, _canvasBound.height, true, 0x0000ff00);
			
			var matrix:Matrix = new Matrix();
			matrix.translate(-_canvasBound.left, -_canvasBound.top);			
			_sourceBMD.draw(tempSprite, matrix);
			
			_parent.addChildAt(_source, _parent.getChildIndex(tempSprite));
			
			_parent.removeChild(tempSprite);
			
			_baseCanvasBMD = new BitmapData(_canvasBound.width, _canvasBound.height, true, 0x00ff0000);
			_baseCanvas = new Bitmap(_baseCanvasBMD);
			_baseCanvas.x = _canvasBound.x;
			_baseCanvas.y = _canvasBound.y;
			
			_tempCanvasBMD = new BitmapData(_canvasBound.width, _canvasBound.height, true, 0x00ff0000);
			_tempCanvas = new Bitmap(_tempCanvasBMD);
			_tempCanvas.x = _canvasBound.x;
			_tempCanvas.y = _canvasBound.y;
			
			_activeCanvasBMD = new BitmapData(_canvasBound.width, _canvasBound.height, true, 0x00ff0000);
			_activeCanvas = new Bitmap(_activeCanvasBMD);
			_activeCanvas.x = _canvasBound.x;
			_activeCanvas.y = _canvasBound.y;
			
			var rect:Rectangle = new Rectangle(_source_x_in_canvas, _source_y_in_canvas, sourceStartBound.width, sourceStartBound.height);
			var pt:Point = new Point(sourceStartBound.x - _canvasBound.x, sourceStartBound.y - _canvasBound.y);
			//_activeCanvasBMD.copyPixels(_sourceBMD, rect, pt);
			_baseCanvasBMD.copyPixels(_sourceBMD, rect, pt);
		}
		
		
		/****************************
		 *		Playing phase
		 * *************************/
		public function start(tickDelay:Number = 30, duration:Number = 1, activeDuration:Number = 0.5, onCompleteFunc:Function = null, onCompleteParams:Array = null):void
		{
			if (_isPlaying) return;
			
			_dProgress =  tickDelay / (duration * 1000);
			
			_activeUnitsPerTick = Math.ceil(tickDelay / (activeDuration * 1000) * _unitAmount);
			//_activeUnitsPerTick = _unitAmount;
			
			trace('_dProgress = ' + _dProgress);
			trace('predict num tick = ' + Math.ceil(1 / _dProgress));
			trace('_activeUnitsPerTick = ' + _activeUnitsPerTick);
			
			_isPlaying = true;
			
			_onCompleteFunc = onCompleteFunc;
			_onCompleteParams = onCompleteParams;
			
			_parent.addChildAt(_baseCanvas, _parent.getChildIndex(_source));
			_parent.addChildAt(_tempCanvas, _parent.getChildIndex(_source));
			_parent.addChildAt(_activeCanvas, _parent.getChildIndex(_source));
			_parent.removeChild(_source);
			
			_startTimer = getTimer();
			
			_timer = new Timer(tickDelay);
			_timer.addEventListener(TimerEvent.TIMER, timerTick);
			
			_timer.start();
		}
		
		private function timerTick(evt:TimerEvent):void
		{
			
			render();
			//applyBlur();
			
			_numTick ++;
			
			if (_numUnitComplete == _unitAmount)
			{
				_timer.stop();			
				_timer.removeEventListener(TimerEvent.TIMER, timerTick);
				_timer = null;
				
				_renderTimeTotal += (getTimer() - _startTimer);
				
				_isPlaying = false;
				
				var totalTime:Number = getTimer() - _startTimer;
				trace('all complete, num ticks = ' + _numTick + ', total time = ' + totalTime + ', average render time = ' + int(_renderTimeTotal / _numTick * 100)/100 + ' ms.');
				
				if (_onCompleteFunc != null)
				{
					_onCompleteFunc.apply(null, _onCompleteParams);
					_onCompleteFunc = null;
					_onCompleteParams = null;
				}
				
				//destroy();
			}
		}
		
		private function applyBlur():void
		{
			var scale:Number = _activedList.length / _unitAmount * 10;
			//_activeCanvas.filters = [new BlurFilter(scale,scale)];
			_activeCanvas.filters = [new BlurFilter(scale,scale)];
			//_activeCanvas.filters = _baseCanvas.filters = [new BlurFilter(scale,scale)];
		}
		
		private function render():void
		{
			/** active some **/			
			var i:uint, l:uint, unit:SwarmUnit;
			
			
			if (_startList.length > 0)
			{
				l = (_activeUnitsPerTick > _startList.length) ? _startList.length : _activeUnitsPerTick;
				_baseCanvasBMD.lock();
				
				for (i = 0; i < l; i++)
				{	
					unit = _startList.shift();
					_activedList.push(unit);
					
					_baseCanvasBMD.fillRect(unit.rect, 0x00000000);
				}
				
				_baseCanvasBMD.unlock();
			}
			
			
			/** render **/
			
			var rect:Rectangle = new Rectangle(0, 0, _activeCanvasBMD.width, _activeCanvasBMD.height);
			
			_activeCanvasBMD.lock();
			
			_activeCanvasBMD.fillRect(rect, 0x00000000);
			
			l = _activedList.length;
			var unitRect:Rectangle = new Rectangle(0, 0, _unitWidth, _unitHeight);
			
			for (i = 0; i < l;i++)
			{
				unit = _activedList[i];
				
				if (unit.progress >= 1)
				{
					_activedList.splice(i, 1);
					i--;
					l--;
					_numUnitComplete ++;
					continue;
				}
				
				unit.progress += _dProgress;
				
				unitRect.x = unit.dx;
				unitRect.y = unit.dy;
				_activeCanvasBMD.fillRect(unitRect, unit.color);
			}
			
			_activeCanvasBMD.unlock();
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
			
			if (_activeCanvas)
			{
				if (_activeCanvas.parent)_activeCanvas.parent.removeChild(_activeCanvas);
				_activeCanvas = null;
				_activeCanvasBMD.dispose();
				_activeCanvasBMD = null;
			}
			
			if (_baseCanvas)
			{
				if (_baseCanvas.parent)_baseCanvas.parent.removeChild(_baseCanvas);
				_baseCanvas = null;
				_baseCanvasBMD.dispose();
				_baseCanvasBMD = null;
			}
			
			if (_tempCanvas)
			{
				if (_tempCanvas.parent)_tempCanvas.parent.removeChild(_tempCanvas);
				_tempCanvas = null;
				_tempCanvasBMD.dispose();
				_tempCanvasBMD = null;
			}
			
			_parent = null;
			_source = null;
			
			if (_sourceBMD)
			{
				_sourceBMD.dispose();
				_sourceBMD = null;
			}
			
			_unitList = null;
			_startList = null;
			_activedList = null;
			
			_onCompleteFunc = null;
			_onCompleteParams = null;
		}
		 
		
		/***********************
		 * 		Params
		 * ********************/
		private var _parent:DisplayObjectContainer;
		
		private var _source:DisplayObject;
		private var _sourceBMD:BitmapData;
		
		private var _activeCanvas:Bitmap;
		private var _activeCanvasBMD:BitmapData;
		
		private var _baseCanvas:Bitmap;
		private var _baseCanvasBMD:BitmapData;
		
		private var _tempCanvas:Bitmap;
		private var _tempCanvasBMD:BitmapData;
		
		private var _canvasBound:Rectangle;
		
		private var _timer:Timer;		
		
		private var _randomRangeX:Number = 50;
		private var _randomRangeY:Number = 50;
		
		private var _unitWidth:uint = 2;
		private var _unitHeight:uint = 2;
		
		private var _source_x_in_canvas:Number;
		private var _source_y_in_canvas:Number;
		
		private var _source_center_in_canvas:Point;
		
		private var _unitList:Vector.<SwarmUnit>;
		private var _startList:Vector.<SwarmUnit>;
		private var _activedList:Vector.<SwarmUnit>;
		
		private var _unitAmount:uint;
		
		private var _tx:Number;
		private var _ty:Number;
		
		private var _dx:Number;
		private var _dy:Number;
		
		private var _numTick:uint = 0;
		private var _renderTimeTotal:Number = 0;
		
		private var _isPlaying:Boolean = false;
		public function get isPlaying():Boolean { return _isPlaying; }
		
		private var _onCompleteFunc:Function;
		private var _onCompleteParams:Array;
		
		private var _dProgress:Number;
		
		private var _startTimer:Number;
		
		private var _activeUnitsPerTick:uint = 100;
		
		private var _numUnitComplete:uint = 0;
	}
}