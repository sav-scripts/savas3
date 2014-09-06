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
	public class PageDragger extends Sprite
	{
		public function init(positionMode:String = PageDraggerPositionMode.PAGE):void
		{
			_positionMode = positionMode;
			
			_tf_currentPage = _drager._tf_currentPage;
			_tf_currentPage.mouseEnabled = false;
			
			_tf_totalPage = _drager._tf_totalPage;
			_tf_totalPage.mouseEnabled = false;
			
			_drager.buttonMode = _drager.useHandCursor = true;
			
			_btnPrevPage.addEventListener(MouseEvent.CLICK, btnPrevPageClick);
			_btnNextPage.addEventListener(MouseEvent.CLICK, btnNextPageClick);
			
			commitGeomSetting();
			
			_drager.addEventListener(MouseEvent.MOUSE_DOWN, dragerMouseDown);
		}
		
		public function setWidth(w:uint):void
		{
			if (w < REQUIRE_WIDTH) throw new Error("Width need > " + REQUIRE_WIDTH);
			if (w % 2 != 0) trace('Warning : value of width is better at 2 x n');
			_btnNextPage.x = w - _btnNextPage.width;
			_limitSprite.width = w - (75 * 2);
			_rightPart.x = _limitSprite.x + _limitSprite.width;
			
			_drager.x = w / 2;
			
			commitGeomSetting();
		}
		
		private function commitGeomSetting():void
		{
			_centerX = _drager.x;
			
			MIN_X = _limitSprite.x;
			MAX_X = _limitSprite.x + _limitSprite.width;
			DRAG_RANGE = _limitSprite.width;
			
			Dragger.remove(_drager);
			Dragger.add(_drager, null, -1, dragerMouseMove, true, new Rectangle( MIN_X, _drager.y, DRAG_RANGE, 0));
		}
		
		
		/********************
		 * 		Btn part
		 * *****************/
		private function btnPrevPageClick(evt:MouseEvent):void
		{
			var newIndex:int = _currentPage - 1;
			if (newIndex < 1) return;
			
			currentPage = newIndex;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function btnNextPageClick(evt:MouseEvent):void
		{
			var newIndex:int = _currentPage + 1;
			if (newIndex > _totalPage) return;
			
			currentPage = newIndex;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/************************
		 * 		Dragger part
		 * *********************/
		private function dragerMouseDown(evt:MouseEvent):void
		{
			Tweener.removeTweens(_drager);
			_mouseDownIndex = _currentPage;
			stage.addEventListener(MouseEvent.MOUSE_UP, dragerMouseUp);
		}
		
		private function dragerMouseUp(evt:MouseEvent):void
		{
			evt.currentTarget.removeEventListener(MouseEvent.MOUSE_UP, dragerMouseUp);
			
			//Tweener.addTween(_drager, { time:0.5, x:_centerX } );
			
			var percent:Number = (_drager.x - MIN_X) / DRAG_RANGE;
			var index:Number = Math.round(percent * (_totalPage-1)) + 1;
				
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
					Tweener.addTween(_drager, { time:0.5, x:_centerX } );
				}
				else
				{
					var tx:Number = MIN_X + ((_currentPage-1) / (_totalPage-1) * DRAG_RANGE);
					Tweener.addTween(_drager, { time:0.5, x:tx } );
				}
			}
			else
			{
				Tweener.addTween(_drager, { time:0.5, x:_centerX } );
			}
		}
		
		private function dragerMouseMove():void
		{
			//trace('MIN_X = ' + MIN_X + ', DRAG_RANGE = ' + DRAG_RANGE);
			var percent:Number = (_drager.x - MIN_X) / DRAG_RANGE;
			var index:Number = Math.round(percent * (_totalPage-1)) + 1;
			
			//trace('percent = ' + percent + ', index = ' + index);
			
			_tf_currentPage.text = String(index);
		}
		
		/*********************
		 * 		 params
		 * ******************/
		public var _drager:MovieClip;
		public var _btnPrevPage:SimpleButton;
		public var _btnNextPage:SimpleButton;
		
		public var _limitSprite:Sprite;
		
		private var _tf_currentPage:TextField;
		public var _tf_totalPage:TextField;
		
		private var MIN_X:Number = -60;
		private var MAX_X:Number = 60;
		private var DRAG_RANGE:Number = MAX_X - MIN_X;
		
		private var _totalPage:uint = 99999999;
		public function get totalPage():uint { return _totalPage; }
		public function set totalPage(n:uint):void
		{
			//if (n == _totalPage) return;
			
			_totalPage = n;
			_tf_totalPage.text = String(_totalPage);
			mouseChildren = (_totalPage > 1);
		}
		
		private var _currentPage:uint = 99999999;
		public function get currentPage():uint { return _currentPage; }
		public function set currentPage(n:uint):void
		{
			if (n > _totalPage) throw new Error("Illegal currentPage value");
			//if (n == _currentPage) return;
			_currentPage = n;
			_tf_currentPage.text = String(_currentPage);
			
			_btnPrevPage.mouseEnabled = _btnNextPage.mouseEnabled = true;
			_btnPrevPage.alpha = _btnNextPage.alpha = 1;
			
			if (_currentPage <= 1) 
			{
				_btnPrevPage.mouseEnabled = false;
				_btnPrevPage.alpha = .5;
			}
			
			if (_currentPage == _totalPage || _totalPage <= 1)
			{
				_btnNextPage.mouseEnabled = false;
				_btnNextPage.alpha = .5;
			}
			
			recoverDragger();
		}
		
		private var _mouseDownIndex:uint;	
		
		private var _centerX:Number;
		private static var REQUIRE_WIDTH:uint = 200;
		
		public var _leftPart:Sprite;
		public var _rightPart:Sprite;
		
		private var _positionMode:String;
		
	}
}