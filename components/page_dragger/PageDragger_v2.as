package sav.components.page_dragger
{
	import caurina.transitions.Tweener;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import sav.utils.Dragger;
	
	[Event(name = 'change', type = 'flash.events.Event')]
	public class PageDragger_v2 extends Sprite
	{
		public function PageDragger_v2(uiClip:MovieClip):void
		{
			_uiClip = uiClip;
			
			_btnPrevPage = _uiClip.btn_prevPage;
			_btnNextPage = _uiClip.btn_nextPage;
			_dragbar = _uiClip.dragbar;
			_leftPart = _uiClip.leftPart;
			_rightPart = _uiClip.rightPart;
			_limitSprite = _uiClip.limitSprite;
			
			addChild(_uiClip);
		}
		
		public function init(positionMode:String = PageDraggerPositionMode.PAGE):void
		{
			_positionMode = positionMode;
			
			//_tf_currentPage = _dragbar._tf_currentPage;
			//_tf_currentPage.mouseEnabled = false;
			
			//_tf_totalPage = _dragbar._tf_totalPage;
			//_tf_totalPage.mouseEnabled = false;
			
			_dragbar.buttonMode = _dragbar.useHandCursor = true;
			
			_btnPrevPage.addEventListener(MouseEvent.CLICK, btnPrevPageClick);
			_btnNextPage.addEventListener(MouseEvent.CLICK, btnNextPageClick);
			
			commitGeomSetting();
			
			//_dragbar.addEventListener(MouseEvent.MOUSE_DOWN, dragerMouseDown);
		}
		
		private function commitGeomSetting():void
		{
			_centerX = _dragbar.x;
			
			MIN_X = _limitSprite.x;
			MAX_X = _limitSprite.x + _limitSprite.width;
			DRAG_RANGE = _limitSprite.width;
			
			Dragger.remove(_dragbar);
			Dragger.add(_dragbar, null, -1, dragerMouseMove, true, new Rectangle( MIN_X, _dragbar.y, DRAG_RANGE, 0), dragerMouseDown, dragerMouseUp);
		}
		
		
		/********************
		 * 		Btn part
		 * *****************/
		private function btnPrevPageClick(evt:MouseEvent):void
		{
			var newIndex:int = _currentPage - 1;
			if (newIndex < 0) return;
			
			currentPage = newIndex;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function btnNextPageClick(evt:MouseEvent):void
		{
			var newIndex:int = _currentPage + 1;
			if (newIndex >= _totalPage) return;
			
			currentPage = newIndex;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/************************
		 * 		Dragger part
		 * *********************/
		private function dragerMouseDown():void
		{
			Tweener.removeTweens(_dragbar);
			_mouseDownIndex = _currentPage;
		}
		
		private function dragerMouseUp():void
		{	
			var percent:Number = (_dragbar.x - MIN_X) / DRAG_RANGE;
			var index:Number = Math.round(percent * (_totalPage-1));
				
			if (index != _mouseDownIndex)
			{
				currentPage = index;			
				dispatchEvent(new Event(Event.CHANGE));
			}
			else
			{
				recoverDragger();
			}
		}
		
		private function recoverDragger():void
		{
			if (_positionMode == PageDraggerPositionMode.PAGE)
			{
				if (_totalPage <= 1)
				{
					Tweener.addTween(_dragbar, { time:0.5, x:_centerX } );
				}
				else
				{
					var tx:Number = MIN_X + ((_currentPage) / (_totalPage-1) * DRAG_RANGE);
					Tweener.addTween(_dragbar, { time:0.5, x:tx } );
				}
			}
			else
			{
				Tweener.addTween(_dragbar, { time:0.5, x:_centerX } );
			}
		}
		
		private function dragerMouseMove():void
		{
			//trace('MIN_X = ' + MIN_X + ', DRAG_RANGE = ' + DRAG_RANGE);
			var percent:Number = (_dragbar.x - MIN_X) / DRAG_RANGE;
			var index:Number = Math.round(percent * (_totalPage-1));
			
			//trace('percent = ' + percent + ', index = ' + index);
			
			//_tf_currentPage.text = String(index);
		}
		
		/*********************
		 * 		 params
		 * ******************/
		private var _uiClip:MovieClip;
		 
		private var _dragbar:MovieClip;
		private var _btnPrevPage:SimpleButton;
		private var _btnNextPage:SimpleButton;
		
		private var _limitSprite:Sprite;
		
		//private var _tf_currentPage:TextField;
		//public var _tf_totalPage:TextField;
		
		private var MIN_X:Number = -60;
		private var MAX_X:Number = 60;
		private var DRAG_RANGE:Number = MAX_X - MIN_X;
		
		private var _totalPage:uint = 99999999;
		public function get totalPage():uint { return _totalPage; }
		public function set totalPage(n:uint):void
		{
			//if (n == _totalPage) return;
			
			_totalPage = n;
			//_tf_totalPage.text = String(_totalPage);
			mouseChildren = (_totalPage > 1);
		}
		
		private var _currentPage:uint = 99999999;
		public function get currentPage():uint { return _currentPage; }
		public function set currentPage(n:uint):void
		{
			if (n > _totalPage) throw new Error("Illegal currentPage value");
			//if (n == _currentPage) return;
			_currentPage = n;
			//_tf_currentPage.text = String(_currentPage);
			
			_btnPrevPage.mouseEnabled = _btnNextPage.mouseEnabled = true;
			_btnPrevPage.alpha = _btnNextPage.alpha = 1;
			
			if (_currentPage <= 0) 
			{
				_btnPrevPage.mouseEnabled = false;
				//_btnPrevPage.alpha = .5;
			}
			
			if (_currentPage >= (_totalPage-1) || _totalPage <= 0)
			{
				_btnNextPage.mouseEnabled = false;
				//_btnNextPage.alpha = .5;
			}
			
			recoverDragger();
		}
		
		private var _mouseDownIndex:uint;	
		
		private var _centerX:Number;
		private static var REQUIRE_WIDTH:uint = 200;
		
		private var _leftPart:Sprite;
		private var _rightPart:Sprite;
		
		private var _positionMode:String;
		
	}
}