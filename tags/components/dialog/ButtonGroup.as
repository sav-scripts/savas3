package sav.components.dialog
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import sav.events.DEvent;
	public class ButtonGroup extends Sprite 
	
	{
		public function ButtonGroup(setting:DialogSetting)
		{
			_setting = setting;
		}
		
		public function build(dataArray:Array):void
		{
			while (numChildren) removeChildAt(0);
			
			var maxButtonWidth:Number = 0;
			var obj:Object , text:String, func:Function, funcParams:Array, closeDialog:Boolean, tf:TextField, align:String;
			
			for each(obj in dataArray)
			{
				text = obj.text;
				tf = DialogButton.getTextField(text, _setting.buttonTextSize, _setting.buttonLetterSpacing);
				maxButtonWidth = Math.max(maxButtonWidth, tf.width);
			}
			
			maxButtonWidth += _setting.buttonInflateWidth * 2;
			var i:uint, l:uint = dataArray.length, tx:Number = 0;
			for (i = 0; i < l;i++ )
			{	
				obj = dataArray[i];
				text = obj.text;
				func = obj.func;
				funcParams = obj.funcParams;
				closeDialog = obj.closeDialog;
				
				align = 'middle';
				if (l == 1)
					align = 'single';
				else if (i==0)
					align = 'left';
				else if (i==l-1)
					align = 'right';
				
				var button:DialogButton = new DialogButton(text, func, funcParams, closeDialog, maxButtonWidth, _setting, align);
				button.x = tx;
				tx += maxButtonWidth + 2;		
				addChild(button);
				
				button.addEventListener(MouseEvent.CLICK, buttonClick);
			}
		}
		
		private function buttonClick(evt:MouseEvent):void
		{
			var button:DialogButton = DialogButton(evt.currentTarget);
			if(button._execFunc != null) button._execFunc.apply(null, button._execFuncParams);
			
			var dEvent:DEvent = new DEvent(BUTTON_CLICK);
			dEvent.data.button = button;
			dispatchEvent(dEvent);
		}
		
		internal function drawBasement():void
		{
			var boardSize:Number = _setting.boardSize;
			var rect:Rectangle = this.getBounds(this);
			rect.y = 0;
			rect.height = _setting.buttonHeight;
			rect.inflate(boardSize, 0);
			rect.height += boardSize;
			rect.y -= boardSize;
			_bound = rect.clone();
			
			var rc:Number = _setting.buttonHeight / 2 + boardSize;
			_rc = rc;
		
			var g:Graphics = graphics;
			g.beginFill(_setting.boardColor);
			//g.beginFill(0xff0000);
			g.drawRoundRectComplex(rect.x, rect.y, rect.width, rect.height, rc, rc, 0, 0);
			
			
			//rect.inflate( -1, -1);
			//rc -= 1;
			//g.beginFill(0x888888);
			//g.drawRoundRectComplex(rect.x, rect.y, rect.width, rect.height, rc, rc, 0, 0);
			
			
			
			g.endFill();	
			
		}
		
		internal function destroy():void
		{
			while (numChildren)
			{
				var button:DialogButton = DialogButton(getChildAt(0));
				button.removeEventListener(MouseEvent.CLICK, buttonClick);
				button.destroy();				
			}
			
			_setting = null;
			
			if (parent) parent.removeChild(this);
		}
		
		private var _setting:DialogSetting;
		internal static var BUTTON_CLICK:String = 'buttonClick';		
		
		private var _bound:Rectangle;
		public function get bound():Rectangle { return _bound; }
		
		private var _rc:Number;
		public function get rc():Number { return _rc; }
	}
}