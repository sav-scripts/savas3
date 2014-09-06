package sav.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class Console
	{		
		public static function registPhases(...classArray):void
		{
			for each(var phaseClass:Class in classArray)
			{
				registPhase(phaseClass);
			}
		}
		
		public static function registPhase(phaseClass:Class, phaseName:String = null):void
		{
			if (phaseName == null)
			{
				var string:String = String(phaseClass);
				phaseName = string.substr(7, string.length - 8);
			}
			_registedPhase[phaseName] = phaseClass;
		}
		
		public static function triggerPhase(phaseName:String, startParams:Array = null, onCompleteFunc:Function = null, returnData:Boolean = false):*
		{
			var PhaseClass:Class;
			if ((PhaseClass = _registedPhase[phaseName]))
			{
				var phase:* = new PhaseClass();
				
				var obj:Object = { };
				obj.onCompleteFunc = onCompleteFunc;
				obj.returnData = returnData;
				obj.phase = phase;
				_numPhases ++;
				
				_phaseDic[phase] = obj;
				
				phase.addEventListener(Event.COMPLETE, phaseComplete);
				phase.addEventListener(Event.CANCEL, phaseCancel);
				phase.start.apply(phase, startParams);
				return phase;
			}
			else
			{
				trace('Console: phase [' + phaseName + '] is not registed');
				return null;
			}
		}
		
		private static function phaseComplete(evt:Event):void
		{
			var phase:EventDispatcher = EventDispatcher(evt.currentTarget);	
			var obj:Object = removePhase(phase);
			
			var returnData:Boolean = obj.returnData;
			var onCompleteFunc:Function = obj.onCompleteFunc;
			
			if (onCompleteFunc != null) 
			{
				if (returnData)
				{
					var data:Object = Object(phase).data;
					Object(phase).data = null;
					onCompleteFunc(data);
				}
				else
				{
					onCompleteFunc();
				}
			}
			
			//trace('phase [' + _numPhases + '] completed, now num phases = ' + _numPhases);
		}
		
		public static function cancelPhase(phase:*):void
		{	
			try{
				var func:Function = phase['cancel'];
			}
			catch (e:Error)
			{
				throw new Error('phase : ' + phase + ' do not have cancel method prepared');
			}
			
			phase.cancel();
		}
		
		private static function phaseCancel(evt:Event):void
		{
			var phase:EventDispatcher = EventDispatcher(evt.currentTarget);	
			var obj:Object = removePhase(phase);
		}
		
		public static function removePhase(phase:EventDispatcher, traceNumPhases:Boolean = false):Object
		{
			phase.removeEventListener(Event.COMPLETE, phaseComplete);	
			phase.removeEventListener(Event.CANCEL, phaseCancel);
			
			var obj:Object = _phaseDic[phase];
			if (!obj) throw new Error("Phase reference is removed already");
			
			delete _phaseDic[phase];
			_numPhases --;
			
			if (traceNumPhases) 
			{
				trace('phase [' + phase + '] removed, now num phases = ' + _numPhases);
				//for each(var tphase:* in _phaseDic)
				//{
					//trace(tphase.phase);
				//}
			}
			
			return obj;
		}
		
		/**
		 * Regist API into schedule for initialize
		 * 
		 * @param	APIClass		Class	Class reference
		 * @param	delay			uint	API installing time, need be more than 30
		 * @param	...initParams	
		 */
		public static function registAPI(APIClass:Class, delay:uint = 500, ...initParams):void
		{
			var obj:Object = { };
			obj.APIClass = APIClass;
			obj.initParams = initParams;
			if (delay > 30) obj.delay = delay;
			_registedAPI.push( {APIClass:APIClass, initParams:initParams } );
		}
		
		/**
		 * Initialize registed API
		 * 
		 * @param	onCompleteFunc	Function	Execute this when all API initialized
		 * @param	delay			uint		Time gap between each API init
		 */
		public static function initRegistedAPI(onCompleteFunc:Function, delay:uint = 500, onUpdateFunc:Function = null, onUpdateParams:Array = null):void
		{
			if (_registedAPI.length == 0)
			{
				trace("Warning : no API registed for init phase");
				onCompleteFunc();
			}
			else
			{
				var obj:Object = _registedAPI.shift();
				var APIClass:Class = obj.APIClass;
				var initParams:Array = obj.initParams;
				var api:* = new APIClass();
				
				if (obj.delay != undefined) delay = obj.delay;
				
				var timer:Timer = new Timer(delay, 1);
				
				var startNext:Function = function(evt:TimerEvent):void
				{
					timer.removeEventListener(TimerEvent.TIMER, startNext);		
					if (_registedAPI.length > 0)
					{
						if (onUpdateFunc != null) onUpdateFunc.apply(null, onUpdateParams);
						initRegistedAPI(onCompleteFunc, delay, onUpdateFunc, onUpdateParams);
					}
					else
					{
						onCompleteFunc();
					}				
				}
				
				api.init.apply(null, initParams);
				
				timer.addEventListener(TimerEvent.TIMER, startNext);
				timer.start();
			}
		}
		
		public static function hasPhase(phaseName:String):Boolean
		{
			return (_registedPhase[phaseName] != undefined);
		}
		
		/*********************************
		 * 			 Dic params
		 * ******************************/
		private static var _registedAPI:Array = [];
		
		public static function get numUninitiazedAPI():uint { return _registedAPI.length; }
		
		private static var _registedPhase:Object = { };
		
		
		private static var _numPhases:int = 0;
		public static function get numPhases():int { return _numPhases; }
		private static var _phaseDic:Dictionary = new Dictionary();
	}
}