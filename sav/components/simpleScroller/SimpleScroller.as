package sav.components.simpleScroller
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import sav.components.Scroller;
	import flash.display.Sprite;
	import sav.gp.GraphicDrawer;
	public class SimpleScroller extends Scroller
	{		
		/**
		 * 
		 * @param	dragBarHeight			drag bar height
		 * @param	enableMinAndMax			active min and max buttons
		 * @param	invisibleWhenNoNeeded	set visible to false when content no need be scrolled
		 * @param	color					base color
		 * @param	alpha					base color alpha
		 * @param	dragBarColor			dragBar color
		 */
		public function SimpleScroller(	dragBarHeight:Number = 0,
										enableMinAndMax:Boolean = false,
										invisibleWhenNoNeeded:Boolean = true,
										color:uint = 0xffffff,
										alpha:Number = 1, 
										dragBarColor:uint= 0xcccccc)
		{
			_dragBarHeight = dragBarHeight;
			_enableMinAndMax = enableMinAndMax;
			_color = color;
			_alpha = alpha;
			_dragBarColor = dragBarColor;
			
			_dragBarHeight = dragBarHeight;
			
			build();
			resize(new Rectangle(0, 0, 10, 300));
			super(invisibleWhenNoNeeded);
		}
		
		override public function resize(bound:Rectangle, updateContentPosition:Boolean = true):void
		{
			var dragMinAndMaxPartToo:Boolean = (!_bound || _bound.width != bound.width) ? true : false;
			
			_bound = bound.clone();
			
			if (_enableMinAndMax)
			{
				var ih:Number = _bound.width + _dBars;
				_bound.inflate(0, -ih);
			}
			
			minPart.y = middlePart.y = _bound.top;
			_dragBarMask.y = middlePart.y;
			maxPart.y = _bound.bottom;
			redraw();
			
			if(targetContent) updateDragArea(updateContentPosition);
		}
		
		private function build():void
		{
			minPart = new Sprite();
			maxPart = new Sprite();
			middlePart = new Sprite();
			dragBar = new Sprite();
			_dragBarShape = new Shape();
			dragBar.addChild(_dragBarShape);
			

			_dragBarMask = new Shape();
			dragBar.mask = _dragBarMask;
			_dragBarShape.filters = [new DropShadowFilter(1, 90, 0, 0.5, 0, 16)];			
			middlePart.filters = [new DropShadowFilter(2, 0, 0, 0.1, 2, 0, 1, 1, true)];
			
			minBar = minPart;
			maxBar = maxPart;
			
			minPart.buttonMode = maxPart.buttonMode = true;
			
			addChild(minPart);
			addChild(maxPart);
			addChild(middlePart);
			addChild(dragBar);
			addChild(_dragBarMask);
			
			glowFilter = new GlowFilter(_dragBarColor, 0.5, 7, 7, 0);
			dragBar.addEventListener(MouseEvent.MOUSE_OVER, mouseOverDragBar);
			dragBar.addEventListener(MouseEvent.MOUSE_OUT, mouseOutDragBar);
		}
		
		private function mouseOverDragBar(evt:MouseEvent):void
		{
			_targetGlowStrength = 3;
			addEventListener(Event.ENTER_FRAME, resetGlow);
		}
		
		private function mouseOutDragBar(evt:MouseEvent):void
		{			
			_targetGlowStrength = 0;
			addEventListener(Event.ENTER_FRAME, resetGlow);
		}
		
		private function resetGlow(evt:Event):void
		{
			var ds:Number = (_targetGlowStrength - glowFilter.strength) * 0.2;
			
			glowFilter.strength += ds;
			
			if (Math.abs(ds) <= 0.1) removeEventListener(Event.ENTER_FRAME, resetGlow);
			
			dragBar.alpha = 0.85 + glowFilter.strength * .1;
			
			dragBar.filters = [glowFilter];
		}
		
		private function redraw():void
		{
			if (!_rc) _rc = [_bound.width / 2, _bound.width / 2, _bound.width / 2, _bound.width / 2];
			
			var g:Graphics = middlePart.graphics;
			g.clear();
			g.beginFill(_color, _alpha);
			GraphicDrawer.drawRoundRectComplex(g, _bound, _rc[0], _rc[1], _rc[2], _rc[3]);
			
			g = _dragBarMask.graphics;
			g.clear();
			g.beginFill(0xff0000);
			GraphicDrawer.drawRoundRectComplex(g, _bound, _rc[0], _rc[1], _rc[2], _rc[3]);
			
			var dragBarHeight:Number = (_dragBarHeight || !targetContent) 	? _dragBarHeight
																			: _bound.height * _maskBound.height / targetContent.height;
																			
			if (dragBarHeight > _bound.height) dragBarHeight = _bound.height;
			
			g = _dragBarShape.graphics;
			g.clear();
			g.beginFill(_dragBarColor);
			
			//var rc:Number = _bound.width/2;
			var bound2:Rectangle = _bound.clone();
			bound2.height = dragBarHeight;
			GraphicDrawer.drawRoundRectComplex(g, bound2, _rc[0], _rc[1], _rc[2], _rc[3]);
			
			if (_enableMinAndMax) drawMinAndMaxPart();
		}
		
		public function setRoundConer(leftTop:Number, rightTop:Number, leftBottom:Number, rightBottom:Number):void
		{
			_rc = [leftTop,rightTop,leftBottom,rightBottom];
		}
		
		private function drawMinAndMaxPart():void
		{
			var r:Number = _bound.width;
			var c:Number = r / 2;
			
			var g:Graphics = minPart.graphics;
			g.clear();			
			g.beginFill(_color, _alpha);
			g.drawCircle(c, -_dBars - c, c);
			g.endFill();
			
			g = maxPart.graphics;
			g.clear();					
			g.beginFill(_color, _alpha);
			g.drawCircle(c, _dBars + c, c);
			g.endFill();
		}
		
		override public function destroy():void 
		{
			dragBar.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverDragBar);
			dragBar.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutDragBar);
			removeEventListener(Event.ENTER_FRAME, resetGlow);
			glowFilter = null;
			
			_rc = null;
			_bound = null;
			
			if (_dragBarMask)
			{
				if (_dragBarMask.parent) removeChild(_dragBarMask);
				_dragBarMask = null;
			}
			
			if (_dragBarShape) _dragBarShape.parent.removeChild(_dragBarShape);
			_dragBarShape = null;
			
			super.destroy();
		}
		
		private var _rc:Array;
		private var _dragBarMask:Shape;
		private var _dragBarShape:Shape;
		private var _bound:Rectangle;
		private var _dragBarHeight:Number;
		private var _color:uint;
		private var _alpha:Number;
		private var _enableMinAndMax:Boolean;
		private var _dBars:Number = 4;
		private var _dragBarColor:uint;
		
		private var glowFilter:GlowFilter;
		private var _targetGlowStrength:Number = 0;
	}
}