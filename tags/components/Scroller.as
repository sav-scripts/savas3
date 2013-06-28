/******************************************************************************************************************
	This is a parent Class for Scrollers , by extend this Class , the child class can scroll targetContent which bind with it.
	
*******************************************************************************************************************/
package sav.components
{
	import flash.display.InteractiveObject;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	
	/// This class is for extend only, and will apply scroll function after binded with
	public class Scroller extends Sprite 
	{
		public function Scroller(invisibleWhenNoNeeded:Boolean = true ) 
		{
			_invisibleWhenNoNeeded = invisibleWhenNoNeeded;
			
			if (dragBar && dragBar is Sprite)
			{
				Sprite(dragBar).buttonMode = true;
				Sprite(dragBar).useHandCursor = true;
			}
		}
		
		/**
		 * Bind Scroller with some content, target content must have a mask applyed
		 * 
		 * @param	tc				Sprite	Target content sprite
		 * @param	_wheelHitArea	Sprite	Hit area for mouse wheel function
		 */
		public function bindWith(tc:Sprite, wheelHitArea:InteractiveObject = null, contentMaskBound:Rectangle = null):void
		{
			targetContent			= tc;
			_wheelHitArea			= wheelHitArea;
			
			if (contentMaskBound)
			{
				_maskBound = contentMaskBound;
			}
			else if (targetContent.mask)
			{
				_maskBound = new Rectangle(targetContent.mask.x, targetContent.mask.y, targetContent.mask.width, targetContent.mask.height);
			}
			else
			{
				throw new Error("Didn't assign mask bound nor target content not have mask neither");
			}
			
			init();
		}
		
		public function init():void
		{
			if (minBar)			minBar.addEventListener(MouseEvent.MOUSE_DOWN,minBarMouseDown, false, 0, true);
			if (maxBar)			maxBar.addEventListener(MouseEvent.MOUSE_DOWN,maxBarMouseDown, false, 0, true);
			if (_wheelHitArea)	_wheelHitArea.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel, false, 0, true);
			
			dragBar.addEventListener(MouseEvent.MOUSE_DOWN,dragBarMouseDown, false, 0, true);
			updateDragArea();
		}
		
		/**
		 * Resize this scroller
		 * 
		 * @param	bound					Rectangle	Use this bound to reset position of parts in this scroller
		 * @param	updateContentPosition	Boolean		Set to true make scroll update content position after scroller resized
		 */
		public function resize(bound:Rectangle, updateContentPosition:Boolean = true):void
		{
			maxPart.y						= bound.height;
			var minPartBound:Rectangle		= minPart.getBounds(minPart.parent);
			var maxPartBound:Rectangle		= maxPart.getBounds(maxPart.parent);
			middlePart.y					= minPartBound.bottom;
			middlePart.height				= maxPartBound.top - minPartBound.bottom;
			
			updateDragArea(updateContentPosition);
		}
		
		/// Reset position of dragBar to bottom of drag able area
		public function resetToMin():void
		{
			targetContent.y = _moveAbleArea.y;
			dragBar.y = minPart.y;
		}
		
		/**
		 * Reset to min scroll range
		 * @param	updateContent	Boolean		Set to true make content position be changed as well
		 */
		public function setToMin(updateContent:Boolean = true):void
		{
			dragBar.y = _dragAbleArea.top;
			if(updateContent) update();
		}		
		
		/**
		 * Reset to max scroll range
		 * @param	updateContent	Boolean		Set to true make content position be changed as well
		 */
		public function setToMax(updateContent:Boolean = true):void
		{
			dragBar.y = _dragAbleArea.bottom;
			if(updateContent) update();
		}
		
		/**
		 * Scroll to target progress
		 * @param	progress	Number	Target progress, value 0 ~ 1
		 */
		public function scrollTo(progress:Number, updateContent:Boolean = true):void
		{
			dragBar.y = _dragAbleArea.top + (_dragAbleArea.height * progress);
			if (updateContent) update();
		}
		
		/**
		 * Update bounds for scroller, usually call this function when content is resized
		 * 
		 * @param	updateContentPosition	Boolean		Set to true make scroller update content position after get drag bounds
		 */
		public function updateDragArea(updateContentPosition:Boolean = true):void
		{
			_dragAbleArea				= new Rectangle(minPart.x , minPart.y , minPart.x , maxPart.y - minPart.y - dragBar.height);
			
			var moveAbleHeight:Number	= targetContent.height - _maskBound.height;
			if (moveAbleHeight < 0) moveAbleHeight = 0;
			
			_moveAbleArea				= new Rectangle(_maskBound.x , _maskBound.y - moveAbleHeight, _maskBound.x , moveAbleHeight);
			
			if (moveAbleHeight == 0) dragBar.y = _dragAbleArea.bottom;			
			if (dragBar.y < _dragAbleArea.top) dragBar.y = _dragAbleArea.top;
			if (dragBar.y > _dragAbleArea.bottom) dragBar.y = _dragAbleArea.bottom;
			
			checkIfScrollAble();
			
			if (updateContentPosition) update();
		}
		
		/// Update dragBar position, usually call this function while content position was changed by others scripts
		public function updateDragBarPosition():void
		{	
			var dy:Number			= _maskBound.y - targetContent.y;
			var scrollRate:Number	= dy / _moveAbleArea.height;
			dragBar.y				= scrollRate * _dragAbleArea.height;
		}
		
		/// Update content position, make it fit with dragBar position
		public function updateContentPosition():void
		{
			update();
		}
		
		protected function checkIfScrollAble():void
		{
			var newScrollAble:Boolean = false;
			if (_moveAbleArea.height <= 0)
			{
				this.visible = (_invisibleWhenNoNeeded) ? false : true;
				newScrollAble = false;
			}
			else
			{
				this.visible = true;
				newScrollAble = true;
			}
			
			var needDispatch:Boolean = (_scrollAble != newScrollAble);
			_scrollAble = newScrollAble;
			if (needDispatch) dispatchEvent(new Event(SCROLL_ABLE_CHANGED));
		}
		
		protected function minBarMouseDown(evt:MouseEvent)
		{
			_scrolling = true;
			dragBar.addEventListener(Event.ENTER_FRAME,scrollUp, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP,minBarMouseUp, false, 0, true);
		}
		
		protected function minBarMouseUp(evt:MouseEvent)
		{		
			_scrolling = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP,minBarMouseUp);
			dragBar.removeEventListener(Event.ENTER_FRAME,scrollUp);
		}
		
		protected function scrollUp(evt:Event):void
		{			
			dragBar.y -= clickMoveValue;
			if (dragBar.y<_dragAbleArea.y) 
			{
				dragBar.y = _dragAbleArea.y;
				update();
				dragBar.removeEventListener(Event.ENTER_FRAME,scrollUp);
			}
			else 
			{
				update();
			}
		}
		
		protected function maxBarMouseDown(evt:MouseEvent)
		{
			_scrolling = true;
			dragBar.addEventListener(Event.ENTER_FRAME,scrollDown, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP,maxBarMouseUp, false, 0, true);
		}
		
		protected function maxBarMouseUp(evt:MouseEvent)
		{
			_scrolling = false;
			dragBar.stage.removeEventListener(MouseEvent.MOUSE_UP,maxBarMouseUp);
			dragBar.removeEventListener(Event.ENTER_FRAME,scrollDown);
		}
		
		protected function scrollDown(evt:Event):void
		{
			dragBar.y += clickMoveValue;
			if (dragBar.y>_dragAbleArea.bottom) 
			{
				dragBar.y = _dragAbleArea.bottom;
				update();
				dragBar.removeEventListener(Event.ENTER_FRAME,scrollDown);
			}
			else 
			{
				update();
			}
		}
		
		protected function dragBarMouseDown(evt:MouseEvent):void
		{
			_scrolling = true;
			_oldMouseY = dragBar.stage.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE,dragBarMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP,dragBarMouseUp, false, 0, true);
		}
		
		protected function dragBarMouseUp(evt:MouseEvent):void
		{
			_scrolling = false;
			dragBar.stage.removeEventListener(MouseEvent.MOUSE_MOVE,dragBarMouseMove);
			dragBar.stage.removeEventListener(MouseEvent.MOUSE_UP,dragBarMouseUp);
		}
		
		protected function dragBarMouseMove(evt:MouseEvent):void
		{
			var newMouseY:Number	= dragBar.stage.mouseY;
			var dy:Number			= newMouseY - _oldMouseY;
			_oldMouseY = newMouseY;			
			dragBar.y += dy;
			if (dragBar.y < _dragAbleArea.y)dragBar.y = _dragAbleArea.y;			
			if (dragBar.y > _dragAbleArea.bottom)dragBar.y = _dragAbleArea.bottom;

			update();
		}
		
		protected function mouseWheel(evt:MouseEvent):void 
		{			
			if (!enableMouseWheel) return;
			
			if (evt.delta>0) 
			{
				dragBar.y -= clickMoveValue;
				if (dragBar.y < _dragAbleArea.y) 
				{
					dragBar.y = _dragAbleArea.y;
					update();
				}
				else 
				{
					update();
				}
			} else {
				dragBar.y += clickMoveValue;
				if (dragBar.y > _dragAbleArea.bottom) 
				{
					dragBar.y = _dragAbleArea.bottom;
					update();
				}
				else 
				{
					update();
				}
			}
		}
		
		protected function update():void
		{
			if (_moveAbleArea.height > 0)
			{
				var dy:Number			= dragBar.y-minPart.y;
				var scrollRate:Number	= dy/_dragAbleArea.height;
				_targetY				= _moveAbleArea.bottom-scrollRate*_moveAbleArea.height;
			}
			else
			{
				_targetY = _moveAbleArea.bottom;
			}
			
			
			if (slideEffect) 
			{
				addEventListener(Event.ENTER_FRAME,targetContentSlide, false, 0, true);
			}
			else 
			{				
				targetContent.y = _targetY;
				dispatchEvent(new Event(SCROLLED));
			}
		}
		
		protected function targetContentSlide(evt:Event):void
		{
			var dy:Number = (_targetY-targetContent.y)/3;
			
			if (Math.abs(dy)<=.5)
			{
				targetContent.y = _targetY;
				removeEventListener(Event.ENTER_FRAME,targetContentSlide);
			}
			else 
			{
				targetContent.y += dy;
			}
			
			dispatchEvent(new Event(SCROLLED));
		}
		
		public function destroy():void
		{
			if (minBar)			minBar.removeEventListener(MouseEvent.MOUSE_DOWN,minBarMouseDown);
			if (maxBar)			maxBar.removeEventListener(MouseEvent.MOUSE_DOWN,maxBarMouseDown);
			if (_wheelHitArea)	_wheelHitArea.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			
			dragBar.removeEventListener(MouseEvent.MOUSE_DOWN, dragBarMouseDown);			
			dragBar.removeEventListener(Event.ENTER_FRAME,scrollUp);			
			dragBar.removeEventListener(Event.ENTER_FRAME, scrollDown);
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, minBarMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_UP, maxBarMouseUp);			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,dragBarMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, dragBarMouseUp);
				
			minBar = null;
			maxBar = null;
			dragBar = null;
			minPart = null;
			middlePart = null;
			maxPart = null;
			targetContent = null;
			_maskBound = null;
			_wheelHitArea = null;
			
			_dragAbleArea = null;
			_moveAbleArea = null;
			
			removeEventListener(Event.ENTER_FRAME,targetContentSlide);
			
			if (parent) parent.removeChild(this);
		}
		
		private var _scrolling :Boolean = false;
		public function get scrolling():Boolean { return _scrolling; }
		
		public var minBar				:Sprite;
		public var maxBar				:Sprite;
		public var dragBar				:Sprite;
		public var minPart				:Sprite;
		public var middlePart			:Sprite;
		public var maxPart				:Sprite;
		public var targetContent		:Sprite;
		
		protected var _wheelHitArea		:InteractiveObject;
		public function get wheelHitArea():InteractiveObject { return _wheelHitArea; }
		public function set wheelHitArea(area:InteractiveObject):void
		{
			if (_wheelHitArea) _wheelHitArea.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			
			_wheelHitArea = area;
			
			if (_wheelHitArea) _wheelHitArea.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel, false, 0, true);
		}
		
		protected var _dragAbleArea			:Rectangle;
		public function get dragAbleArea():Rectangle { return _dragAbleArea; }
		
		protected var _moveAbleArea			:Rectangle;
		
		public var clickMoveValue 		:uint = 10;		
		public var slideEffect			:Boolean = true;
		public var enableMouseWheel		:Boolean = true;			
		
		protected var _oldMouseY				:Number;
		protected var _targetY					:Number;
		
		protected var _invisibleWhenNoNeeded 	:Boolean;
		public function get invisibleWhenNoNeeded():Boolean { return _invisibleWhenNoNeeded; }
		public function set invisibleWhenNoNeeded(b:Boolean):void
		{
			_invisibleWhenNoNeeded = b;
		}
		
		protected var _scrollAble				:Boolean = false;		
		public function get scrollAble():Boolean { return _scrollAble; }
		
		
		protected var _maskBound:Rectangle;
		//public function get maskBound():Rectangle { return _maskBound; )
		//public function set maskBound(rect:Rectangle):void
		//{
			//_maskBound = maskBound;
			//updateDragArea();
		//}
		
		
		public static const SCROLLED:String = 'scrolled';
		public static const SCROLL_ABLE_CHANGED:String = 'scrollAbleChanged';
	}
}