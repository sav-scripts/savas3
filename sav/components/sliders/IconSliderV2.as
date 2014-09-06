package sav.components.sliders
{
	import caurina.transitions.Tweener;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import sav.events.UIEvent;
	
	[Event(name = "showStart", type = "sav.events.UIEvent")]
	[Event(name = "hideStart", type = "sav.events.UIEvent")]
	[Event(name = "showComplete", type = "sav.events.UIEvent")]
	[Event(name = "hideComplete", type = "sav.events.UIEvent")]
	
	public class IconSliderV2 extends Sprite
	{
		/**
		 * This class is only for be extended from flash IDE library.
		 * 
		 * @param	arrangeMode		auto arrange mode make it use all icons and their positions for default setting		
		 * @param	permGapX		assign gap value for each icons, this only take effect when arrangeMode != 'auto'
		 */
		public function IconSliderV2(arrangeMode:String = 'auto', permGapX:Number = 30)
		{	
			_arrangeMode = arrangeMode;
			_permGapX = permGapX;
			
			mouseEnabled = false;
			
			_iconArray = [];
			_iconDic = new Dictionary(true);
			catchIcons();
			
			if (arrangeMode == 'auto') assignAllIcons();
			
			_state = 'show';
		}
		
		public function toMode(targetMode:String, doHide:Boolean = false, doShow:Boolean = false ):void
		{
			if (!_modeArray[targetMode]) throw new Error("Illegal target mode");
			
			if (doHide)
			{
				hide(function() { toMode(targetMode, false, doShow); } );
			}
			else
			{
				removeIcons();
				assignIcons(_modeArray[targetMode]);
				if (doShow) show();
			}
		}
		
		protected function assignAllIcons():void
		{
			for each(var obj:IconObject in _iconDic) 
			{
				addChild(obj.icon);
				_iconArray.push(obj);
			}
			arrange();
		}
		
		public function assignIcons(array:Array):void
		{
			for each(var icon:Sprite in array)
			{
				if (!_iconDic[icon]) throw new Error("Assigning icon " + icon + " wasn't caught in constuct phase");
				_iconArray.push(_iconDic[icon]);
				addChild(icon);
			}
			arrange();
		}
		
		public function removeIcons():void
		{
			for each(var obj:IconObject in _iconArray)
			{
				if (obj.icon.parent) removeChild(obj.icon);
			}
			_iconArray = [];
		}
		
		public function hide(callBackFunc:Function = null):void
		{
			if (_state != 'show') return;
			
			mouseChildren = false;
			
			_hideCallBack = callBackFunc;
			
			var delay:Number = 0;
			
			for each(var obj:IconObject in _iconArray)
			{
				var icon:Sprite = obj.icon;
				Tweener.removeTweens(icon);
				Tweener.addTween(icon, { time:0.3, delay:delay, scaleX:0, scaleY:0, x:obj.recoverX, y:obj.recoverY, transition:'easeInBack' } );
				//delay += 0.05;
			}
			
			Tweener.addTween(this, { time:0.3 + delay, onComplete:hideComplete } );
			
			_state = 'tweening';
		}
		
		private function hideComplete():void
		{
			_state = 'hide';
			for each(var obj:IconObject in _iconArray) { removeChild(obj.icon); }	
			
			if (_hideCallBack != null) { _hideCallBack(); _hideCallBack = null; }			
			dispatchEvent(new UIEvent(UIEvent.HIDE_COMPLETE));
		}
		
		public function show(callBackFunc:Function = null):void
		{
			if (_state != 'hide') return;		
			
			_showCallBack = callBackFunc;
			
			var delay:Number = 0;
			
			for each(var obj:IconObject in _iconArray)
			{
				var icon:Sprite = obj.icon;
				addChild(icon);
				icon.scaleX = icon.scaleY = 0;
				Tweener.removeTweens(icon);
				Tweener.addTween(icon, { time:0.3, delay:delay, scaleX:1, scaleY:1, x:obj.recoverX, y:obj.recoverY, transition:'easeOutBack' } );
				//delay += 0.005;
			}
			Tweener.addTween(this, { time:0.3 + delay + 0.1, onComplete:showComplete } );
			
			_state = 'tweening';
		}
		
		private function showComplete():void
		{
			_state = 'show';		
			mouseChildren = true;			
			if (_showCallBack != null) { _showCallBack(); _showCallBack = null; }
			dispatchEvent(new UIEvent(UIEvent.SHOW_COMPLETE));
		}
		
		/**
		 * catch icons if this class is extended and the extended class have display objects already.
		 */
		protected function catchIcons():void
		{
			//if (this.numChildren == 0) throw new Error('Need at least one Sprite inside for catchIcons method.');
			
			var i:uint, l:uint = this.numChildren, g:Graphics, rect:Rectangle;
			for (i = 0; i < l; i++)
			{
				var icon:Sprite = Sprite(this.getChildAt(0));
				icon.mouseChildren = false;
				icon.useHandCursor = true;
				icon.buttonMode = true;
				icon.addEventListener(MouseEvent.CLICK, iconClick);
				icon.addEventListener(MouseEvent.MOUSE_OVER, iconMouseOver);
				icon.addEventListener(MouseEvent.MOUSE_OUT, iconMouseOut);
				if (isNaN(_xMin)) _xMin = icon.x;
				if (isNaN(_xMan)) _xMan = icon.x;
				_xMin = Math.min(_xMin, icon.x);
				_xMan = Math.max(_xMan, icon.x);
				
				var iconObject:IconObject = new IconObject(icon, icon.x);				
				//_iconArray.push(iconObject);
				_iconDic[icon] = iconObject;
				
				rect = icon.getBounds(icon);
				g = icon.graphics;
				g.beginFill(0, 0);				
				g.drawRect(rect.x, rect.y, rect.width, rect.height);
				g.endFill();
				
				removeChild(icon);
			}
			
			//_bound = this.getBounds(this);			
			//
			//g = this.graphics;
			//g.beginFill(0, 0);
			//g.drawRect(_bound.x, _bound.y, _bound.width, _bound.height);
			//g.endFill();
		}
		
		protected function arrange():void
		{
			var startX:Number;
			if (_arrangeMode == 'auto')
			{
				_iconArray.sortOn('originalX', Array.NUMERIC);				
				_gapX = (_xMan - _xMin) / (_iconArray.length - 1);
				startX = _xMin;
			}
			else if (_arrangeMode == 'center')
			{
				_gapX = _permGapX;
				startX = -(_iconArray.length - 1) * _gapX * 0.5;
			}
			else if (_arrangeMode == 'left')
			{
				_gapX = _permGapX;
				startX = 0;
			}
			
			var i:uint, l:uint = _iconArray.length;
			for (i = 0; i < l;i++ )
			{
				var iconObject:IconObject = _iconArray[i];
				var icon:Sprite = iconObject.icon;
				icon.x = iconObject.recoverX = startX + i * _gapX;
			}
			
			_bound = this.getBounds(this);
		}
		
		public function getRecoverPosition(icon:Sprite):Point
		{
			for each(var iconObject:IconObject in _iconArray)
			{
				if (iconObject.icon == icon)
				{
					return new Point(iconObject.recoverX, iconObject.recoverY);
				}
			}
			
			throw new Error("Can't find icon in this slider.");
		}
		
		private function iconClick(evt:MouseEvent):void
		{
			recover();
			
			var uiEvent:UIEvent = new UIEvent(UIEvent.BLOCK_CLICK);
			uiEvent.data.block = evt.currentTarget;
			dispatchEvent(uiEvent);
		}
		
		private function iconMouseOver(evt:MouseEvent):void
		{
			
			if (_mouseEventIcon != evt.currentTarget)
			{
				_mouseEventIcon = Sprite(evt.currentTarget);
				
				var iconObject:IconObject = _iconDic[_mouseEventIcon];
				focusObject(iconObject);
				
				var uiEvent:UIEvent = new UIEvent(UIEvent.BLOCK_MOUSE_OVER);
				uiEvent.data.block = _mouseEventIcon;
				dispatchEvent(uiEvent);
			}
		}
		
		private function iconMouseOut(evt:MouseEvent):void
		{
			var iconObject:IconObject = _iconDic[evt.currentTarget];
			
			if (!iconObject.icon.hitTestPoint(evt.stageX, evt.stageY, true))
			{
				recover();
				
				_mouseEventIcon = null;
				var uiEvent:UIEvent = new UIEvent(UIEvent.BLOCK_MOUSE_OUT);
				uiEvent.data.block = evt.currentTarget;
				dispatchEvent(uiEvent);
				
			}
		}
		
		private function focusObject(iconObject:IconObject):void
		{
			var index:int = _iconArray.indexOf(iconObject);
			var icon:Sprite = iconObject.icon;
			
			Tweener.removeTweens(icon);
			Tweener.addTween(icon, { time:0.3, x:iconObject.recoverX, y:targetY, scaleX:iconScaleMax, scaleY:iconScaleMax } );
			
			var i:int, l:int = _iconArray.length, rate:Number, targetX:Number;
			var pushRange:Number = _gapX / 3;
			var dToMinX:Number = icon.x - _xMin;
			var dToMaxX:Number = _xMan - icon.x;					
			
			for (i = (index-1); i >= 0; i--)
			{
				rate = (i+1) / (index);
				iconObject = _iconArray[i];
				icon = iconObject.icon;
				
				targetX = iconObject.recoverX - (pushRange) * rate;				
				
				Tweener.removeTweens(icon);
				Tweener.addTween(icon, { time:0.3, x:targetX, y:iconObject.recoverY ,scaleX:1, scaleY:1} );
			}
			
			for (i = (index+1); i < l; i++)
			{
				rate = (l - i) / (l - (index + 1));
				
				iconObject = _iconArray[i];
				icon = iconObject.icon;
				
				targetX = iconObject.recoverX + (pushRange) * rate;				
				
				Tweener.removeTweens(icon);
				Tweener.addTween(icon, { time:0.3, x:targetX, y:iconObject.recoverY ,scaleX:1, scaleY:1} );
			}
		}
		
		private function recover():void
		{
			for each(var iconObject:IconObject in _iconArray)
			{
				var icon:Sprite = iconObject.icon;
				Tweener.removeTweens(icon);
				Tweener.addTween(icon, { time:0.3, x:iconObject.recoverX, y:iconObject.recoverY, scaleX:1, scaleY:1 } );
			}
		}
		
		public function destroy():void
		{			
			for each(var obj:IconObject in _iconArray)
			{
				obj.icon.removeEventListener(MouseEvent.CLICK, iconClick);
				obj.icon.removeEventListener(MouseEvent.MOUSE_OVER, iconMouseOver);
				obj.icon.removeEventListener(MouseEvent.MOUSE_OUT, iconMouseOut);
			}			
			_iconArray = null;
			_iconDic = null;
			_mouseEventIcon = null;
			
			_hideCallBack = null;
			_showCallBack = null;
			_modeArray = null;
			
			if (parent) parent.removeChild(this);
		}
		
		protected var _hideCallBack		:Function;
		protected var _showCallBack		:Function;
		
		protected var _iconArray		:Array;
		protected var _iconDic			:Dictionary;
		protected var _gapX				:Number;
		protected var _xMin				:Number;
		protected var _xMan				:Number;
		protected var _mouseEventIcon	:Sprite;
		
		protected var _modeArray:Array = [];
		
		protected var _arrangeMode		:String;
		protected var _permGapX			:Number;
		
		protected var _state:String = 'hide';
		public function get state():String { return _state; }
		
		protected var _bound			:Rectangle;
		
		public var iconScaleMax			:Number = 2;
		public var targetY				:Number = -10;
	}
}

import flash.display.Sprite;

class IconObject
{
	public var icon:Sprite;
	public var recoverX:Number;
	public var recoverY:Number;
	public var originalX:Number;
	
	public function IconObject(icon:Sprite, originalX:Number, recoverX:Number = Number.NaN, recoverY:Number = 0)
	{
		this.icon = icon;
		this.recoverX = recoverX;
		this.recoverY = recoverY;
		this.originalX = originalX;
	}
}