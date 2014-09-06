package sav.gp.simple_canvas
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import sav.gp.simple_canvas.events.SimpleCanvasEvent;
	import sav.gp.simple_canvas.methods.IDrawMethod;
	import sav.gp.simple_canvas.methods.Line;
	
	
	/**
	 * Dispatch when new drawing recoard added
	 * 
     * @eventType sav.gp.simple_canvas.events.SimpleCanvasEvent.HISTORY_ADDED
	 */
	[Event(name = 'historyAdded', type = 'sav.gp.simple_canvas.events.SimpleCanvasEvent')]
	
	/**
	 * Dispatch when replay completed
	 * 
     * @eventType sav.gp.simple_canvas.events.SimpleCanvasEvent.REPLAY_COMPLETE
	 */
	[Event(name = 'replayComplete', type = 'sav.gp.simple_canvas.events.SimpleCanvasEvent')]
	
	/**
	 * Dispatch when undo/redo progress changed, there is several situaion will fire this event
	 * 
     * @eventType sav.gp.simple_canvas.events.SimpleCanvasEvent.UNDO_CHANGED
	 */
	[Event(name = 'undoChanged', type = 'sav.gp.simple_canvas.events.SimpleCanvasEvent')]
	
	/**
	 * A drawing event is start (mouse down on canvas or assigned interactive object)
	 * 
     * @eventType sav.gp.simple_canvas.events.SimpleCanvasEvent.DRAW_START
	 */
	[Event(name = 'drawStart', type = 'sav.gp.simple_canvas.events.SimpleCanvasEvent')]
	
	/**
	 * A drawing event is end (mosue up on canvas or assigned interactive object). 
	 * <b>Notice</b> : drawEnd != historyAdded, because sometime a drawing event cycle doesn't provide enough data for drawing method to recoard.
	 * 
     * @eventType sav.gp.simple_canvas.events.SimpleCanvasEvent.DRAW_END
	 */
	[Event(name = 'drawEnd', type = 'sav.gp.simple_canvas.events.SimpleCanvasEvent')]
	
	/**
	 * <p>Core of simple_canvas package.</p>
	 * <p></p>
	 * <p>This class provide simple undo/redo behave, also all drawing result (by both Graphics or BitmapData) will be combined into single BitmapData for displaying render performance</p>
	 * <p></p>
	 * <p>This class catch standard drawing mouse interactive behave , mouseDown, mouseMove and mouseUp.</p>
	 * <p>When these all 3 events happens on this canvas, if user provided enough interactive data for current drawing method, it will add a recoard to drawing history</p>
	 * <p></p>
	 * <p>You can design your own drawing methods by create classes which implements interface IDrawMethod</p>
	 * 
	 * @see sav.gp.simple_canvas.methods.IDrawMethod
	 * @see sav.gp.simple_canvas.methods.Line
	 * 
	 * @example
	 * <listing version="3.0" >
	 * 
	 * import sav.gp.simple_canvas.SimpleCanvas;
	 * 
	 * var simpleCanvas:SimpleCanvas = new SimpleCanvas(stage, 400, 300)
	 * addChild(simpleCanvas);
	 * simpleCanvas.active();
	 * </listing>
	 * 
	 * @example
	 * <listing version="3.0" >
	 * 
	 * import sav.gp.simple_canvas.SimpleCanvas;
	 * import sav.gp.simple_canvas.methods.Rect;
	 * 
	 * var simpleCanvas:SimpleCanvas = new SimpleCanvas(stage, 400, 300)
	 * simpleCanvas.method = new Rect(0x000000, 0.5); 
	 * addChild(simpleCanvas);
	 * simpleCanvas.active();
	 * </listing>
	 */
	public class SimpleCanvas extends Sprite
	{
		/**
		 * <p>Constructor, by default, SimpleCanvas will use Line for drawing method</p>
		 * you can change drawing method by create different IDrawMethod instance and assign to "method" property here
		 * 
		 * @param	stg				Stage reference
		 * @param	canvasWidth		Canvas width
		 * @param	canvasHeight	Canvas height
		 * @param	hitArea			Set to null for use SimpleCanvas instance itself for mouse interactive
		 * @param	numHistorySteps	Num max undo step will be allowed, allowing more steps will use more memony in runtime.
		 * @param	canvasColor		Base color of canvas, this is a ARGB value
		 */
		public function SimpleCanvas(stg:Stage, canvasWidth:uint, canvasHeight:uint, hitArea:InteractiveObject = null, numHistorySteps:uint = 5, canvasColor:uint = 0xffffffff)
		{
			_stage = stg;
			_hitArea = (hitArea) ? hitArea : this;
			_numHistorySteps = numHistorySteps;
			_canvasColor = canvasColor;
			
			
			_canvasData = new BitmapData(canvasWidth, canvasHeight, true, _canvasColor);
			_canvas = new Bitmap(_canvasData);
			addChild(_canvas);
			
			_history = new Vector.<IDrawMethod>();
			_undoCache = new Dictionary(true);
			
			_tempLayer_Shape = new Shape();
			
			_tempBitmapData = new BitmapData(canvasWidth, canvasHeight, true, 0x00000000);
			_tempLayer_Bitmap = new Bitmap(_tempBitmapData);
			
			var line:Line = new Line();
			method = line;
		}
		
		
		/*****************************************
		 * 			active and disactive
		 * ***************************************/		
		
		/**
		 * Active interactive
		 */
		public function active():void
		{
			_hitArea.addEventListener(MouseEvent.MOUSE_DOWN, hitArea_mouseDown);
			_isActive = true;
		}
		
		/**
		 * Disactive interactive
		 */
		public function disactive():void
		{
			_hitArea.removeEventListener(MouseEvent.MOUSE_DOWN, hitArea_mouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			_isActive = false;
		}
		
		
		/*****************************************
		 * 			mouse handlers
		 * ***************************************/
		private function hitArea_mouseDown(evt:MouseEvent):void
		{
			if (!stage) return;
			
			_state = 'drawing';
			
			_stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			
			_drawingMethod = _method.semiClone();
			_drawingMethod.mouseDownHandler(getMethodCanvas(_drawingMethod), mouseX, mouseY);
			
			dispatchEvent(new SimpleCanvasEvent(SimpleCanvasEvent.DRAW_START));
		}
		
		private function stage_mouseMove(evt:MouseEvent):void
		{
			_drawingMethod.mouseMoveHandler(mouseX, mouseY);
		}
		
		private function stage_mouseUp(evt:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			
			var shouldRecoardIt:Boolean = _drawingMethod.mouseUpHandler(mouseX, mouseY);
			
			if (shouldRecoardIt)
			{
				var dCache:uint = _history.length - (_currentUndoCacheIndex + 1);
				for (var i:uint = 0; i < dCache; i++)
				{
					var removingMethod:IDrawMethod = _history.pop();
					var removingBitmapData:BitmapData = _undoCache[removingMethod];
					removingBitmapData.dispose();
					delete _undoCache[removingMethod];
					removingMethod.destroy();
				}
				
				_history.push(_drawingMethod);				
				_currentUndoCacheIndex = _history.length - 1;
				
				tempToCanvas(_drawingMethod);
				
				_undoCache[_drawingMethod] = _canvasData.clone();					
				
				if (_firstUndoCacheIndex < (_history.length - _numHistorySteps-1))
				{
					removeHistoryBitmapData(_firstUndoCacheIndex);
					_firstUndoCacheIndex = (_history.length - _numHistorySteps-1);
				}
				
				dispatchEvent(new SimpleCanvasEvent(SimpleCanvasEvent.HISTORY_ADDED));
				dispatchEvent(new SimpleCanvasEvent(SimpleCanvasEvent.UNDO_CHANGED));
			}
			else
			{
				_drawingMethod.destroy();
			}
			
			_drawingMethod = null;
			
			_state = 'idle';
			
			dispatchEvent(new SimpleCanvasEvent(SimpleCanvasEvent.DRAW_END));
		}
		
		
		/*****************************************
		 * 				replay
		 * ***************************************/
		
		/**
		 * <p>Clear canvas(but not history), and replay drawing history.</p>
		 * <b>Notice</b> : Canvas state will set to drawing and diactive interactive while replaying.
		 * 
		 * @param	timeGap	Time gap between each drawing step.
		 */
		public function replay(timeGap:Number = 0.2):void
		{
			if (_state == 'drawing') return;
			if (_history.length == 0) return;
			
			clearCanvas();
			
			_state = 'drawing';
			
			_wasActive = _isActive;
			disactive();
			
			var timer:Timer = new Timer(timeGap * 1000, _history.length);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
			timer.start();
		}
		
		private function onTimer(evt:TimerEvent):void
		{
			var timer:Timer = Timer(evt.currentTarget);
			var i:uint = timer.currentCount - 1;
			
			var _method:IDrawMethod = _history[i];
			
			_method.redraw(getMethodCanvas(_method));
			tempToCanvas(_method);
		}
		
		private function timerComplete(evt:TimerEvent):void
		{
			var timer:Timer = Timer(evt.currentTarget);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
			if (_wasActive) active();
			_state = 'idle';
			
			dispatchEvent(new SimpleCanvasEvent(SimpleCanvasEvent.REPLAY_COMPLETE));
		}
		
		
		/*****************************************
		 * 			undo, redo, clear
		 * ***************************************/				
		private function clearCanvas(bitmapData:BitmapData = null, toColor:uint = 0x00000000):void
		{
			if (bitmapData == null) 
			{
				bitmapData = _canvasData;
				toColor = _canvasColor;
			}
			bitmapData.fillRect(new Rectangle(0, 0, bitmapData.width, bitmapData.height), toColor);
		}
		
		/**
		 * Clear canvas and drawing history.
		 */
		public function clear():void
		{
			if (_state == 'drawing') return;
			clearCanvas();
			
			for each(var bitmapData:BitmapData in _undoCache)
				bitmapData.dispose();
			_undoCache = new Dictionary(true);
			
			for each(var method:IDrawMethod in _history)
				method.destroy();
			_history = new Vector.<IDrawMethod>();			
			
			_currentUndoCacheIndex = -1;
			_firstUndoCacheIndex = -1;
			
			dispatchEvent(new SimpleCanvasEvent(SimpleCanvasEvent.UNDO_CHANGED));
		}
		
		/**
		 * Undo one step.
		 */
		public function undo():void
		{
			if (_state == 'drawing') return;
			if (_currentUndoCacheIndex > _firstUndoCacheIndex)
			{	
				_currentUndoCacheIndex --;
				toUndoStep();
				dispatchEvent(new SimpleCanvasEvent(SimpleCanvasEvent.UNDO_CHANGED));
			}
		}
		
		/**
		 * Redo one step.
		 */
		public function redo():void
		{
			if (_state == 'drawing') return;
			if (_currentUndoCacheIndex < (_history.length - 1))
			{
				_currentUndoCacheIndex ++;
				toUndoStep();
				dispatchEvent(new SimpleCanvasEvent(SimpleCanvasEvent.UNDO_CHANGED));
			}
		}
		
		private function toUndoStep():void
		{				
			clearCanvas();			
			
			var targetIndex:int = _currentUndoCacheIndex;
			
			if (targetIndex < 0) return;
			var method:IDrawMethod = _history[targetIndex];
			var bitmapData:BitmapData = _undoCache[method];
			
			_canvasData.copyPixels(bitmapData, new Rectangle(0, 0, _canvasData.width, _canvasData.height), new Point());			
		}
		
		
		/*****************************************
		 * 			misc private methods
		 * ***************************************/
		private function removeHistoryBitmapData(targetIndex:int):void
		{
			if (targetIndex < -1) throw new Error('Unexpected Error');
			if (targetIndex == -1) return;
			
			var method:IDrawMethod = _history[targetIndex];
			var bitmapData:BitmapData = _undoCache[method];
			if (bitmapData)
			{
				bitmapData.dispose();
				delete _undoCache[method];
			}
		}
		
		private function tempToCanvas(drawingMethod:IDrawMethod):void
		{
			var canvasType:Class = drawingMethod.canvasType;	
			
			if (canvasType == Graphics)
			{
				_canvasData.draw(_tempLayer_Shape);
				_tempLayer_Shape.graphics.clear();
			}
			else if(canvasType == BitmapData)
			{
				_canvasData.draw(_tempLayer_Bitmap);
				clearCanvas(_tempBitmapData);
			}
			else
			{
				throw new Error("SimpleCanvas only support Graphics or BitmapData canvasType for applying draw methods");
			}
		}
		
		private function getMethodCanvas(drawingMethod:IDrawMethod):*
		{
			var canvasType:Class = drawingMethod.canvasType;			
			
			if (canvasType == Graphics)
			{
				if (_tempLayer_Bitmap.parent) removeChild(_tempLayer_Bitmap);
				addChild(_tempLayer_Shape);
				
				return _tempLayer_Shape.graphics;
			}
			else if(canvasType == BitmapData)
			{
				if (_tempLayer_Shape.parent) removeChild(_tempLayer_Shape);
				addChild(_tempLayer_Bitmap);
				
				return _tempBitmapData;
			}
			else
			{
				throw new Error("SimpleCanvas only support Graphics or BitmapData canvasType for applying draw methods");
			}
		}
		
		
		/**
		 * Destroy for release memony used by this instance (memony will release in next sweap).
		 * If you had added listeners or have others reference point to this instance, 
		 * you should remove them for completely destroy this instance
		 */
		public function destroy():void
		{
			disactive();
			
			clear();
			_history = null;
			_undoCache = null;
			
			if(_tempLayer_Shape.parent) removeChild(_tempLayer_Shape);
			_tempLayer_Shape = null;
			
			if (_tempLayer_Bitmap.parent) removeChild(_tempLayer_Bitmap);
			_tempLayer_Bitmap = null;
			_tempBitmapData.dispose();
			_tempBitmapData = null;
			
			_canvasData.dispose();
			_canvasData = null;
			
			removeChild(_canvas);
			_canvas = null;
			
			_method = null;
			_drawingMethod = null;
			
			_hitArea = null;
			
			_stage = null;
			
			if (parent) parent.removeChild(this);
		}
		
		private var _canvasColor:uint;
		
		private var _canvasData:BitmapData;
		private var _canvas:Bitmap;
		private var _tempLayer_Shape:Shape;
		private var _tempLayer_Bitmap:Bitmap;
		private var _tempBitmapData:BitmapData;
		
		private var _method:IDrawMethod;
		/**
		 * Assign a IDrawMethod for SimpleCanvas, when next time mouse down, it will use this drawing method.
		 * While state is drawing(between mouse down and up, or replaying), you should't change method.
		 * @see #state
		 */
		public function get method():IDrawMethod { return _method; }
		public function set method(m:IDrawMethod):void
		{
			if (_state == 'drawing') throw new Error("Can't change drawing method while drawing");
			_method = m;
		}
		
		private var _isActive:Boolean = false;
		private var _wasActive:Boolean = false;
		
		private var _state:String = 'idle';
		/**
		 * <p>Current state, values are :</p>
		 * <ul>	<li>idle : canvas idle</li>
		 * 		<li>drawing	: canvas drawing, you can't change drawing method while drawing.</li></ul>
		 */
		public function get state():String { return _state; }
		
		private var _stage:Stage;
		private var _hitArea:InteractiveObject;
		
		private var _drawingMethod:IDrawMethod;
		
		private var _history:Vector.<IDrawMethod>;
		private var _undoCache:Dictionary;
		
		private var _firstUndoCacheIndex:int = -1;
		private var _currentUndoCacheIndex:int = -1;
		
		/**
		 * Num redo able steps.
		 */
		public function get numRedoAble():uint 
		{
			return (_history.length - 1) - _currentUndoCacheIndex;
		}
		
		/**
		 * Num undo able steps.
		 */
		public function get numUndoAble():uint 
		{
			return _currentUndoCacheIndex - _firstUndoCacheIndex; 
		}

		private var _numHistorySteps:uint = 5;
	}
}