package sav.utils
{
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class FunctionScroll 
	{
		public var minBar, maxBar, scrollBase, dragBar, scrollContent, scrollMask, wheelHitArea;
		public var dragAbleArea, moveAbleArea;
		public var clickMoveValue = 10;
		public var slideEffect:Boolean = true;
		
		private var oldMouseY		:Number;
		private var targetY			:Number;
		
		public function FunctionScroll(min, max, base, bar, cont, msk, wha) 
		{
			minBar = min;
			maxBar = max;
			scrollBase = base;
			dragBar = bar;
			scrollContent = cont;
			scrollMask = msk;
			wheelHitArea = wha;
			
			dragAbleArea = new Rectangle(scrollBase.x, scrollBase.y,0, scrollBase.height-dragBar.height);
			
			var moveAbleHeight = -(-scrollContent.height+scrollMask.height-(scrollContent.y-scrollMask.y)*2);
			moveAbleArea = new Rectangle(scrollContent.x, scrollContent.y-moveAbleHeight, scrollContent.x, moveAbleHeight);			
			
			minBar.addEventListener(MouseEvent.MOUSE_DOWN,minBarMouseDown);
			maxBar.addEventListener(MouseEvent.MOUSE_DOWN,maxBarMouseDown);
			dragBar.addEventListener(MouseEvent.MOUSE_DOWN,dragBarMouseDown);
			wheelHitArea.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheel);
		}
		
		private function minBarMouseDown(evt:MouseEvent)
		{
			dragBar.addEventListener(Event.ENTER_FRAME,scrollUp);
			dragBar.stage.addEventListener(MouseEvent.MOUSE_UP,minBarMouseUp);
		}
		
		private function minBarMouseUp(evt:MouseEvent)
		{
			
			dragBar.stage.removeEventListener(MouseEvent.MOUSE_UP,minBarMouseUp);
			dragBar.removeEventListener(Event.ENTER_FRAME,scrollUp);
		}
		
		private function scrollUp(evt:Event):void
		{			
			dragBar.y -= clickMoveValue;
			if (dragBar.y<dragAbleArea.y) 
			{
				dragBar.y = dragAbleArea.y;
				dragBarMoved();
				dragBar.removeEventListener(Event.ENTER_FRAME,scrollUp);
			}
			else 
			{
				dragBarMoved();
			}
		}
		
		private function maxBarMouseDown(evt:MouseEvent)
		{
			dragBar.addEventListener(Event.ENTER_FRAME,scrollDown);
			dragBar.stage.addEventListener(MouseEvent.MOUSE_UP,maxBarMouseUp);
		}
		
		private function maxBarMouseUp(evt:MouseEvent)
		{
			
			dragBar.stage.removeEventListener(MouseEvent.MOUSE_UP,maxBarMouseUp);
			dragBar.removeEventListener(Event.ENTER_FRAME,scrollDown);
		}
		
		private function scrollDown(evt:Event):void
		{			
			dragBar.y += clickMoveValue;
			if (dragBar.y>dragAbleArea.bottom) 
			{
				dragBar.y = dragAbleArea.bottom;
				dragBarMoved();
				dragBar.removeEventListener(Event.ENTER_FRAME,scrollDown);
			}
			else 
			{
				dragBarMoved();
			}
		}
		
		private function dragBarMouseDown(evt:MouseEvent):void
		{
			//oldMouseX = dragBar.stage.mouseX;
			oldMouseY = dragBar.stage.mouseY;
			dragBar.stage.addEventListener(MouseEvent.MOUSE_MOVE,dragBarMouseMove);
			dragBar.stage.addEventListener(MouseEvent.MOUSE_UP,dragBarMouseUp);
		}
		
		private function dragBarMouseUp(evt:MouseEvent):void
		{
			dragBar.stage.removeEventListener(MouseEvent.MOUSE_MOVE,dragBarMouseMove);
			dragBar.stage.removeEventListener(MouseEvent.MOUSE_UP,dragBarMouseUp);
		}
		
		private function dragBarMouseMove(evt:MouseEvent):void
		{
			var newMouseY = dragBar.stage.mouseY;
			var dy = newMouseY - oldMouseY;
			oldMouseY = newMouseY;			
			dragBar.y += dy;
			
			if (dragBar.y < dragAbleArea.y)dragBar.y = dragAbleArea.y;			
			if (dragBar.y > dragAbleArea.bottom)dragBar.y = dragAbleArea.bottom;

			dragBarMoved();
		}
		
		private function mouseWheel(evt:MouseEvent):void 
		{
			//if (scrollBase.hitTest(_root._xmouse, _root._ymouse) || this.functionScroll.scrollMask.hitTest(_root._xmouse, _root._ymouse)) {
				if (evt.delta>0) {
					dragBar.y -= clickMoveValue;
					if (dragBar.y < dragAbleArea.y) 
					{
						dragBar.y = dragAbleArea.y;
						dragBarMoved();
					}
					else 
					{
						dragBarMoved();
					}
				} else {
					dragBar.y += clickMoveValue;
					if (dragBar.y > dragAbleArea.bottom) 
					{
						dragBar.y = dragAbleArea.bottom;
						dragBarMoved();
					}
					else 
					{
						dragBarMoved();
					}

				}

			//}

		}
		
		private function dragBarMoved():void
		{
			var dy = dragBar.y-scrollBase.y;
			var scrollRate = dy/dragAbleArea.height;
			targetY = moveAbleArea.bottom-scrollRate*moveAbleArea.height;
			
			if (slideEffect) 
			{
				scrollContent.addEventListener(Event.ENTER_FRAME,scrollContentSlide);
			}
			else 
			{
				
				scrollContent.y = targetY;
			}
		}
		
		private function scrollContentSlide(evt:Event):void
		{
			var dy = (targetY-scrollContent.y)/3;
			
			if (Math.abs(dy)<=.5)
			{
				scrollContent.y = targetY;
				scrollContent.addEventListener(Event.ENTER_FRAME,scrollContentSlide);
			}
			else 
			{
				scrollContent.y += dy;
			}
		}
		
		
	}


}