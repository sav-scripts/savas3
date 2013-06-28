package sav.net
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	
	public class PhpConnecter extends EventDispatcher
	{
		public function PhpConnecter(gatewayPath:String)
		{
			if (_instance) throw new Error("PhpConnecter is a singleton Class and shouldn't be construct again");
			_instance = this;
			
			_nc = new NetConnection();
			_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_nc.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			_nc.addEventListener(NetStatusEvent.NET_STATUS, ncNetStatus);
			
			_nc.connect(gatewayPath);
			//_nc.connect('http://www.savorks.com/puzzle/gateway.php');
		}
		
		/***********************
		 * 		  methods
		 * ********************/
		public function call(service:String, method:String, resultHandler:Function = null, ...rest):void
		{
			var responder:Responder = new Responder(resultHandler, onFault);
			rest.unshift(responder);
			rest.unshift(service + '.' + method);
			_nc.call.apply(null, rest);
		}
		
		private function ncNetStatus(evt:NetStatusEvent):void
		{
			trace(evt);
		}
	
		/**************************
		 * 		error handlers
		 * ***********************/
		private function onFault(f:Object ):void 
		{
			trace("There was a problem: " + f.description);
			//Dialog.quickAlert("There was a problem: " + f.description);
			//ADMC.loadingScene.hide();
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			trace("IOErrorHandler: " + event);
		}
		
		private function netStatusHandler(event:NetStatusEvent):void 
		{
			trace("netStatusError, info code : " + event.info.code);
			
			//Dialog.quickAlert("netStatusError, info code : " + event.info.code);
		}
	
		/*******************
		 * 		params
		 * ****************/
		private var _nc:NetConnection;
		public function get connection():NetConnection { return _nc; }
		
		private var _instance:PhpConnecter;
		public function get instance():PhpConnecter { return _instance; }
	}
}