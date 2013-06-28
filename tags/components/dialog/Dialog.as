package sav.components.dialog
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import sav.events.DEvent;
	
	public class Dialog extends Sprite
	{
		public function Dialog(setting:DialogSetting = null)
		{
			_buttonData = [];
			
			_setting = (setting) ? setting : Dialog.defaultSetting;
			if (_setting == null) _setting = new DialogSetting();
			
			_bound = new Rectangle(0, 0, 100, 300);
			
			_basement = new Basement(_setting);
			addChild(_basement);
			
			_content = new Content(_setting, this);
			addChild(_content);
			
			_buttonGroup = new ButtonGroup(_setting);
			_buttonGroup.addEventListener(ButtonGroup.BUTTON_CLICK, buttonGroup_buttonClick);
			addChild(_buttonGroup);
			
			//update();
		}
		
		public function setSize(autoSize:Boolean = true, maxWidth:Number = 100, maxHeight:Number = 100):void
		{
			_setting.autoSize = autoSize;
			_setting.maxWidth = maxWidth;
			_setting.maxHeight = maxHeight;
		}
		
		
		/*************************
		 * 		Quick methods
		 * **********************/
		public static function quickAlert(contentObj:Object, buttons:Array = null, arrangeContent:Boolean = false):Dialog
		{
			var dialog:Dialog = new Dialog();
			dialog.toAlert(contentObj, buttons, arrangeContent);
			dialog.popAt();
			
			return dialog;
		}	
		
		public function toAlert(contentObj:Object, buttons:Array = null, arrangeContent:Boolean = false):void
		{	
			if (contentObj is String)
			{
				_content.toText(String(contentObj));
			}
			else if (contentObj is DisplayObject)
			{
				_content.clear();
				_content.addContent(DisplayObject(contentObj), arrangeContent);
			}
			
			if (!buttons) buttons = [ { text:_setting.closeButtonText, func:null } ];
			
			for each(var obj:Object in buttons)
			{
				if (obj.closeDialog == undefined) obj.closeDialog = true;
				
				var text:String = obj.text;
				var func:Function = obj.func;
				var funcParams:Array = obj.funcParams;
				var closeDialog:Boolean = (obj.closeDialog) ? true : false;
				
				addButton(text, func, funcParams, closeDialog);
			}
			
			update();
		}
		
		
		/***************************
		 *		create flow
		 * ************************/
		public function addButton(text:String, func:Function, funcParams:Array = null, closeDialog:Boolean = true):void
		{
			_buttonData.push( { text:text, func:func, funcParams:funcParams, closeDialog:closeDialog } );
		}
		
		public function addContent(displayObject:DisplayObject, arrangeIt:Boolean = true):void
		{
			_content.addContent(displayObject, arrangeIt);
		}
		
		public function popAt(container:DisplayObjectContainer = null):void
		{
			if (container == null) container = Dialog.defaultContainer;
			if (container == null) throw new Error("Didn't assign container for Dialog, also can't find defaultContainer");
			
			
			x = int((container.stage.stageWidth - _bound.width) / 2);
			y = int((container.stage.stageHeight - _bound.height) / 2);
			
			if (_setting.blockBackground)
			{
				if (_cover && _cover.parent) _cover.parent.removeChild(_cover);
				_cover = new Sprite();
				var g:Graphics = _cover.graphics;
				g.beginFill(_setting.coverColor, _setting.coverAlpha);
				g.drawRect(0, 0, container.stage.stageWidth, container.stage.stageHeight);
				container.addChild(_cover);
			}
			container.addChild(this);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			container.addEventListener(Event.RESIZE, stageResize);
		}
		
		public function update():void
		{
			var btnBound:Rectangle;
			var scrollerHeight:Number = Number.NaN;
			var basementBound:Rectangle;
			
			if (_setting.autoSize)
			{				
				_content.enableMask = false;
				_content.x = _setting.contentInflateWidth;
				_content.y = _setting.contentInflateHeight;
				_bound = _content.getBounds(this);
				
				if (_buttonData.length)
				{
					_buttonGroup.build(_buttonData);
					if (_buttonGroup.width > _bound.width) 
					{
						var oldContentWidth:Number = _bound.width;
						_bound.width = _buttonGroup.width;
						_content.x = (_bound.width + _setting.contentInflateWidth * 2 - oldContentWidth) / 2;
					}
					
					_buttonGroup.x = _bound.x + (_bound.width - _buttonGroup.width)/ 2;
					_buttonGroup.y = _bound.bottom + _setting.buttonGapToContent + _setting.contentInflateHeight - _setting.boardSize;				
					
					_bound.height += (_setting.buttonHeight + _setting.buttonGapToContent);
					
					_buttonGroup.drawBasement();
				}
				
				_bound.inflate(_setting.contentInflateWidth + _setting.boardSize, _setting.contentInflateHeight);
				basementBound = _bound.clone();
			}
			else
			{
				_content.enableMask = true;
				
				_content.x = _setting.contentInflateWidth;
				_content.y = _setting.contentInflateHeight;
				
				_bound = new Rectangle(0, 0, _setting.maxWidth, _setting.maxHeight);	
				basementBound = _bound.clone();
				
				if (_buttonData.length)
				{
					_buttonGroup.build(_buttonData);					
					_buttonGroup.x = _bound.x + (_bound.width - _buttonGroup.width)/ 2;
					_buttonGroup.y = _bound.bottom - _setting.buttonHeight - _setting.boardSize;					
					_bound.height -= (_setting.buttonHeight + _setting.buttonGapToContent);			
					_buttonGroup.drawBasement();
				}
				
				_bound.inflate( -_setting.contentInflateWidth - _setting.boardSize, -_setting.contentInflateHeight - setting.boardSize);
				_content.maskBound = _bound;
				
				scrollerHeight = _content.checkForScroll();
			}
			
			var btnRc:Number = _buttonGroup.rc;
			btnBound = _buttonGroup.bound;
			btnBound.x += _buttonGroup.x;
			btnBound.y += _buttonGroup.y;
			
			_basement.resize(basementBound, btnBound, btnRc, scrollerHeight);
		}
		
		private function buttonGroup_buttonClick(evt:DEvent):void
		{
			var button:DialogButton = DialogButton(evt.data.button);
			if(button._closeDialog)	destroy();
		}
		
		private function stageResize(evt:Event):void
		{
			if (stage)
			{
				if (_cover)
				{
					_cover.width = stage.stageWidth;
					_cover.height = stage.stageHeight;
				}
				
				this.x = (stage.stageWidth - this.width) / 2;
				this.y = (stage.stageHeight - this.height) / 2;
			}
		}
		
		private function onRemoveFromStage(evt:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			stage.removeEventListener(Event.RESIZE, stageResize);
		}
		
		
		/***************************
		 * 			Misc
		 * ************************/
		public function destroy():void
		{
			if (_isDestroy) return;
			
			_isDestroy = true;
			
			if (_cover)
			{
				if (_cover.parent) _cover.parent.removeChild(_cover);
				_cover = null;
			}
			
			_buttonGroup.removeEventListener(ButtonGroup.BUTTON_CLICK, buttonGroup_buttonClick);
			_buttonGroup.destroy();
			_buttonGroup = null;
			
			_basement.destroy();
			_basement = null;
			
			_content.destroy();
			_content = null;
			
			_buttonData = null;
			_setting = null;
			_bound = null;			
			
			if (parent) parent.removeChild(this);
		}
		
		/*********************
		 * 		Params
		 * ******************/
		private var _basement:Basement;
		private var _bound:Rectangle;
		public function get bound():Rectangle { return _bound; }
		
		private var _content:Content;
		private var _buttonData:Array;
		private var _buttonGroup:ButtonGroup;
		
		private var _cover:Sprite;
		
		private var _setting:DialogSetting;
		public function get setting():DialogSetting { return _setting; }
		
		public static var defaultSetting:DialogSetting;
		public static var defaultContainer:DisplayObjectContainer;
		
		private var _isDestroy:Boolean = false;
		public function get isDestroy():Boolean { return _isDestroy; }
	}
}