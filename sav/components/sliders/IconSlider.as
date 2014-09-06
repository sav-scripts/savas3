package sav.components.sliders
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import sav.events.IconSliderEvent;
	import sav.game.MouseRecorder;
	
	[Event(name = 'mouseOverSlider', type = 'sav.events.IconSliderEvent')]
	[Event(name = 'mouseOutSlider', type = 'sav.events.IconSliderEvent')]
	
	public class IconSlider extends Sprite
	{
		//public static const MOUSE_OVER_SLIDER	:String = 'mouseOverSlider';
		//public static const MOUSE_OUT_SLIDER	:String = 'mouseOutSlider';
		
		public var divIcons				:Number = 100;
		public var iconHeight			:Number = 100;
		public var yOffset				:Number = 20;
		public var iconGap				:Number = 5;
		public var centerX				:Number = 0;
		
		public function get numIcons():uint { return iconArray.length; }
		
		private var bound				:Rectangle;
		private var viewBound			:Rectangle;
		private var triggerBound		:Rectangle;
		private var iconArray			:Array;
		private var iconDistanceArray	:Array;
		private var isActive			:Boolean = false;		
		private var theStage			:Stage;		
		private var mousePosition		:Point;
		private var focusIcon			:Icon;
		private var mouseOverSlider		:Boolean = false;
		private var dragging			:Boolean = false;
		private var initRecoverCount	:uint = 20;
		private var recoverCount		:uint;
		private var totalWidth			:Number = 0;
		
		public function IconSlider()
		{
			iconArray = [];
			iconDistanceArray = [];
		}
		
		public function active():void
		{
			if (isActive) return;
				
			if (stage)
			{
				theStage = stage;
				theStage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				isActive = true;
			}
		}
		
		public function disactive():void
		{
			theStage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			isActive = false;
		}
		
		public function addIcon(icon:Icon):void
		{
			addChild(icon);
			iconArray.push(icon);
			iconDistanceArray.push(icon);
			icon.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownIcon);
		}
		
		public function removeIcon(icon:Icon):void
		{
			removeChild(icon);
			iconArray.splice(iconArray.indexOf(icon), 1);
			iconDistanceArray.splice(iconDistanceArray.indexOf(icon), 1);
			icon.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownIcon);
		}
		
		private function mouseDownIcon(evt:MouseEvent):void
		{
			dragging = true;
			MouseRecorder.updatePosition(this);
			stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
		}
		
		private function stageMouseUp(evt:MouseEvent):void
		{
			dragging = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMove);
		}
		
		private function stageMouseMove(evt:MouseEvent):void
		{
			var dPoint:Point = MouseRecorder.updatePosition(this);
			var icon:Icon;
			
			if (totalWidth > bound.width)
			{
				var dx:Number = dPoint.x;
				var cx:Number = centerX + dx;
				var rightLimitX:Number = cx + totalWidth / 2;
				var drx:Number = rightLimitX - bound.right;				
				if (drx < 0) dx -= drx;
				
				var leftLimitX:Number = cx - totalWidth / 2;
				var dlx:Number = leftLimitX - bound.left;				
				if (dlx > 0) dx -= dlx;
				
				centerX += dx;
				
				for each(icon in iconArray)
				{
					icon.x += dx;
					icon.recoverX += dx;
				}
				
				iconDistanceArray.sortOn('absX', Array.NUMERIC);				
				for each(icon in iconDistanceArray)
				{			
					if (!handleAlphaAndDisplayList(icon)) break;
				}
			}
			else
			{
				/*
				centerX += dPoint.x;
				for each(icon in iconArray)
				{
					icon.x += dPoint.x;
					icon.recoverX += dPoint.x;
				}
				*/
			}
			
			
		}
		
		public function reset(divIcons:Number = 100, hRange:Number = 200, triggerHeight:Number = 50, setPositionInstantly:Boolean = true):void		
		{
			this.divIcons = divIcons;
			
			bound = new Rectangle( -hRange / 2, 0, hRange, yOffset);
			viewBound = bound.clone();
			triggerBound = bound.clone();
			triggerBound.y = -triggerHeight;
			triggerBound.height = triggerHeight;
			triggerBound.inflate(iconHeight, 0);
			//viewBound.inflate( -100, 0);
			
			var icon:Icon;
			var i:uint, l:uint = numIcons, startX:Number;	
			totalWidth = 0;
			
			for (i = 0; i < l;i++)
			{
				icon = iconArray[i];
				icon.reset();
				
				if (i == 0)
				{
					totalWidth += icon.clipBound.right;
				}
				else if (i == l - 1)
				{
					totalWidth -= icon.clipBound.left;
					totalWidth += iconGap;
				}
				else
				{					
					totalWidth += icon.clipBound.width;
					totalWidth += iconGap;
				}
			}
			startX = -totalWidth / 2;			
			
			for (i = 0; i < l;i++)
			{
				icon = iconArray[i];
				if (i == 0)
				{
					icon.recoverX = startX;
					icon.recoverY = 0;
				}
				else
				{
					var lastIcon:Icon = iconArray[i-1];
					icon.recoverX = lastIcon.x + lastIcon.clipBound.right + iconGap - icon.clipBound.left;
					icon.recoverY = 0;
				}
				
				if (setPositionInstantly)
				{
					icon.x = icon.recoverX;
					icon.y = icon.recoverY;
				}
				else
				{
					icon.x = 0;
					icon.y = 0;
				}
				
				handleAlphaAndDisplayList(icon);
			}
		}
		
		private function mouseMoveHandler(evt:MouseEvent):void
		{
			if (!parent) return;
			//if (dragging) return;
			
			var icon:Icon, i:int, l:int;
			if (triggerBound.contains(mouseX, mouseY))
			{
				mousePosition = new Point(mouseX, mouseY);
				
				var array:Array = iconArray.concat([]);
				for each(icon in iconArray) icon.dToMouse = Math.abs(mousePosition.x - icon.x);
				
				array.sortOn('dToMouse', Array.NUMERIC);
				if (array[0] != focusIcon) focusIcon = array[0];				
				
				if (!mouseOverSlider) 
				{
					mouseOverSlider = true;
					addEventListener(Event.ENTER_FRAME, mouseOverSliderHandler);
					stopRecover();
					dispatchEvent(new IconSliderEvent(IconSliderEvent.MOUSE_OVER_SLIDER));
				}	
			}
			else
			{
				if (mouseOverSlider == true)
				{
					mouseOverSlider = false;
					removeEventListener(Event.ENTER_FRAME, mouseOverSliderHandler);
					startRecover();
					
					dispatchEvent(new IconSliderEvent(IconSliderEvent.MOUSE_OUT_SLIDER));
				}
			}
		}
		
		public function startRecover():void
		{
			for each(var icon:Icon in iconArray) icon.stopScaling();
			recoverCount = initRecoverCount;
			addEventListener(Event.ENTER_FRAME, recoverHandler);
		}
		
		public function stopRecover():void
		{
			removeEventListener(Event.ENTER_FRAME, recoverHandler);			
		}
		
		private function mouseOverSliderHandler(evt:Event):void
		{
			if (dragging || iconArray.length == 0) return;
			var i:int, icon:Icon, tx:Number;
			
			for each(icon in iconArray) icon.upadteScale(mousePosition.x);
			
			var index:int = iconArray.indexOf(focusIcon);
			
			var dx:Number = (focusIcon.recoverX - focusIcon.x) / 3;
			focusIcon.x = (Math.abs(dx) < 0.3) ? focusIcon.recoverX : focusIcon.x + dx;		
			handleAlphaAndDisplayList(focusIcon);	
			
			var lastIcon:Icon = focusIcon;
			for (i = (index - 1); i >= 0; i--)
			{
				icon = iconArray[i];
				tx = lastIcon.x + lastIcon.clipBound.left - iconGap - icon.clipBound.right;
				if (Math.abs(tx - icon.x) > 0.2) icon.x = tx;
				lastIcon = icon;
			}		
			
			lastIcon = focusIcon;
			for (i = (index + 1); i < iconArray.length; i++)
			{
				icon = iconArray[i];
				tx = lastIcon.x + lastIcon.clipBound.right + iconGap - icon.clipBound.left;
				if (Math.abs(tx - icon.x) > 0.2) icon.x = tx;
				lastIcon = icon;
			}
				
			iconDistanceArray.sortOn('absX', Array.NUMERIC);				
			for each(icon in iconDistanceArray)
			{			
				if (!handleAlphaAndDisplayList(icon)) break;
			}
		}
		
		// handle this icon's alpha and reset it on display list depand on it's x position, return false when this icon isn't in display list anymore
		private function handleAlphaAndDisplayList(icon:Icon):Boolean
		{
			if (icon.x >= viewBound.left && icon.x <= viewBound.right)
			{
				icon.alpha = 1;
				addChildAt(icon, 0);
			}
			else if(icon.x < viewBound.left)
			{
				icon.alpha = (100 - (viewBound.left - icon.x)) / 100;
				if (icon.alpha <= 0)
				{
					if (icon.parent) icon.parent.removeChild(icon);
					return false;
				}
				else
				{
					addChildAt(icon, 0);
				}
			}
			else if(icon.x > viewBound.right)
			{
				icon.alpha = (100 - (icon.x - viewBound.right)) / 100;
				if (icon.alpha <= 0)
				{
					if (icon.parent) icon.parent.removeChild(icon);
					return false;
				}
				else
				{
					addChildAt(icon, 0);
				}
			}
			
			return true;
		}
		
		private function recoverHandler(evt:Event):void
		{
			if (dragging) return;
			recoverCount --;
			var icon:Icon;
			var rate:Number = 0.3;			
			iconDistanceArray.sortOn('absX', Array.NUMERIC);
				
			if (recoverCount <= 0) 
			{
				for each(icon in iconArray)
				{
					icon.x = icon.recoverX;
					icon.y = icon.recoverY;
				}
				
				iconDistanceArray.sortOn('absX', Array.NUMERIC);				
				for each(icon in iconDistanceArray)
				{			
					if (!handleAlphaAndDisplayList(icon)) break;
				}
				
				removeEventListener(Event.ENTER_FRAME, recoverHandler);
			}
			else
			{
				for each(icon in iconArray)
				{				
					var dx:Number = (icon.recoverX - icon.x) * rate;
					var dy:Number = (icon.recoverY - icon.y) * rate;
					var dScale:Number = (icon.recoverScale - icon.scale) * rate;
					
					icon.x = (Math.abs(dx) < 0.2) ? icon.recoverX : icon.x + dx;
					icon.y = (Math.abs(dy) < 0.2) ? icon.recoverY : icon.y + dy;
					icon.scale = (Math.abs(dScale) < 0.001) ? icon.recoverScale : icon.scale + dScale;	
				}
				
				iconDistanceArray.sortOn('absX', Array.NUMERIC);
				for each(icon in iconDistanceArray)
				{			
					if (!handleAlphaAndDisplayList(icon)) break;
				}
			}
		}
	}
}