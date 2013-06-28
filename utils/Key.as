// Key.as
package sav.utils
{
   
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
    public class Key 
	{
        public static function initialize(stage:Stage):void 
		{
            if (!_initialized) 
			{
                stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
                stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
                stage.addEventListener(Event.DEACTIVATE, clearKeys);
				
				_keydownFuncList = { };
				_keyupFuncList = { };
				_keypressFuncList = { };
				
                _initialized = true;
            }
        }
		
		public static function registKeyDownFunc(register:Object, keyCode:int, func:Function):void
		{
			Key.registFunc(0, register, keyCode, func);
		}
		
		public static function registKeyUpFunc(register:Object, keyCode:int, func:Function):void
		{
			Key.registFunc(1, register, keyCode, func);
		}
		
		public static function registKeyPressFunc(register:Object, keyCode:int, delay:int, func:Function):void
		{
			var dic:Dictionary = _keypressFuncList[keyCode];
			if (dic == null) dic = _keypressFuncList[keyCode] = new Dictionary();
			dic[register] = new KeyPressObj(delay, func);
		}
		
		private static function registFunc(stats:int, register:Object, keyCode:int, func:Function):void
		{
			if (stats != 1 && stats != 0) throw new Error("illegal key stats (only 0:keyDown and 1:keyUp supported)");
			
			var list:Object = (stats == 0) ? _keydownFuncList : _keyupFuncList;
			
			var dic:Dictionary = list[keyCode];
			if (dic == null) dic = list[keyCode] = new Dictionary();
			dic[register] = func;
		}
		
		public static function unregistKeyDownFunc(register:Object, keyCode:int):void
		{
			Key.unregistFunc(0, register, keyCode);
		}
		
		public static function unregistKeyUpFunc(register:Object, keyCode:int):void
		{
			Key.unregistFunc(1, register, keyCode);
		}
		
		public static function unregistKeyPressFunc(register:Object, keyCode:int):void
		{
			var dic:Dictionary = _keypressFuncList[keyCode];
			if (dic != null) 
			{
				var keyPressObj:KeyPressObj = dic[register];
				if (keyPressObj != null)
				{
					keyPressObj.destroy();
					delete dic[register];
				}
			}
		}
		
		private static function unregistFunc(stats:int, register:Object, keyCode:int):void
		{
			var dic:Dictionary = (stats == 0) ? _keydownFuncList[keyCode] : _keyupFuncList[keyCode];
			if (dic != null) delete dic[register];
		}
		
		public static function unregistAllFunc(register:Object):void
		{
			var dic:Dictionary;
			for each(dic in _keydownFuncList)
			{
				delete dic[register];
			}
			
			for each(dic in _keyupFuncList)
			{
				delete dic[register];
			}
			
			for each(dic in _keypressFuncList)
			{
				var keyPressObj:KeyPressObj = dic[register];
				if (keyPressObj != null)
				{
					keyPressObj.destroy();
					delete dic[register];
				}
			}
		}
		
        public static function isDown(keyCode:uint):Boolean {
            if (!_initialized) throw new Error("Key class has yet been _initialized.");
            return Boolean(keyCode in _keysDown);
        }
		
        private static function keyPressed(event:KeyboardEvent):void 
		{
			if (event.keyCode in _keysDown) return;
			
            _keysDown[event.keyCode] = true;
			
			var dic:Dictionary = _keydownFuncList[event.keyCode];
			if (dic != null)
			{
				for each(var func:Function in dic)
				{
					func.apply(null);
				}
			}
			
			dic = _keypressFuncList[event.keyCode];
			if (dic != null)
			{
				for each(var keyPressObj:KeyPressObj in dic)
				{
					keyPressObj.start();
				}
			}
        }
		
        private static function keyReleased(event:KeyboardEvent):void {
            if (event.keyCode in _keysDown)
			{
                delete _keysDown[event.keyCode];
			
				var dic:Dictionary = _keyupFuncList[event.keyCode];
				if (dic != null)
				{
					for each(var func:Function in dic)
					{
						func.apply(null);
					}
				}
			
				dic = _keypressFuncList[event.keyCode];
				if (dic != null)
				{
					for each(var keyPressObj:KeyPressObj in dic)
					{
						keyPressObj.stop();
					}
				}
            }
        }
		
        private static function clearKeys(event:Event):void 
		{
            _keysDown = new Object();
        }
		
		/************************
		*         params
		************************/
		private static var _keydownFuncList:Object;
		private static var _keyupFuncList:Object;
		private static var _keypressFuncList:Object;
       
        private static var _initialized:Boolean = false;  // marks whether or not the class has been _initialized
        private static var _keysDown:Object = new Object();  // stores key codes of all keys pressed
    }
}
import flash.events.TimerEvent;
import flash.utils.Timer;

class KeyPressObj
{
	public function KeyPressObj(delay:int, func:Function)
	{
		this.delay = delay;
		this.func = func;
	}
	
	public function start():void
	{
		if (_timer) throw new Error("unexpected error");
		_timer = new Timer(delay);
		_timer.addEventListener(TimerEvent.TIMER, onTimer);
		_timer.start();
	}
	
	private function onTimer(evt:TimerEvent):void
	{
		func.apply(null);
	}
	
	public function stop():void
	{
		if (_timer) 
		{
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_timer = null;
		}
	}
	
	public function destroy():void
	{
		stop();
		func = null;
	}
	
	public var delay:int;
	public var func:Function;
	private var _timer:Timer;
}