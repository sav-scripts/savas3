package sav.data
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	public class EncryptLoader
	{
		public static function start(validByteArray:ByteArray, contentURL:String, onCompleteFunc:Function, onProgressFunc:Function = null, onIOErrorFunc:Function = null):void
		{
			if (_isRunning) throw new Error("Can only run one load");
			
			_validBa = validByteArray;
			_contentURL = contentURL;			
			_onCompleteFunc = onCompleteFunc
			_onProgressFunc = onProgressFunc;
			_onIOErrorFunc = onIOErrorFunc;
			
			_isRunning = true;
			
			var request:URLRequest = new URLRequest(_contentURL);
			
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;	
			addListeners(_urlLoader);
			_urlLoader.load(request);
		}
		
		private static function addListeners(dispatcher:EventDispatcher):void
		{
			dispatcher.addEventListener(ProgressEvent.PROGRESS, urlLoaderProgress);
			dispatcher.addEventListener(Event.COMPLETE, urlLoaderComplete);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, urlLoaderIOError);
		}
		
		private static function removeListeners(dispatcher:EventDispatcher):void
		{
			dispatcher.removeEventListener(ProgressEvent.PROGRESS, urlLoaderProgress);
			dispatcher.removeEventListener(Event.COMPLETE, urlLoaderComplete);
			dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, urlLoaderIOError);
		}
		
		private static function urlLoaderProgress(evt:ProgressEvent):void
		{
			if (_onProgressFunc != null) _onProgressFunc.apply(null, [evt]);
		}
		
		private static function urlLoaderIOError(evt:IOErrorEvent):void
		{
			trace("warning : IOError when loading url [" + _contentURL + "]");
			removeListeners(_urlLoader);
			if (_onIOErrorFunc != null) _onIOErrorFunc.apply(null, [evt]);
		}
		
		private static function urlLoaderComplete(evt:Event):void
		{
			removeListeners(_urlLoader);
			
			var targetBa:ByteArray = new ByteArray();
			var ba:ByteArray = ByteArray(_urlLoader.data);
			
			var i:uint, l:uint = ba.length;
			var loaderLength:uint = _validBa.length;
			
			for (i = 0; i < l; i++)
			{
				var seed:uint = (_validBa[i % loaderLength] > 128) ? 3 : 7;
				targetBa.writeByte(ba.readByte() - seed);
			}
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, contentLoaded);
			_loader.loadBytes(targetBa);
		}
		
		private static function contentLoaded(evt:Event):void
		{			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, contentLoaded);
			
			var content:MovieClip = MovieClip(_loader.content);
			_loader = null;
			_urlLoader = null;
			_validBa = null;
			_contentURL = null;
			_onProgressFunc = null;
			_onIOErrorFunc = null;
			
			_onCompleteFunc.apply(null, [content]);
			
			_onCompleteFunc = null;
			_isRunning = false;
		}
		
		/**********************
		 *       params
		 * *******************/
		private static var _urlLoader:URLLoader;
		private static var _loader:Loader;
	
		
		private static var _isRunning:Boolean = false;
		private static var _validBa:ByteArray;
		private static var _contentURL:String;
		
		private static var _onCompleteFunc:Function;
		private static var _onProgressFunc:Function;
		private static var _onIOErrorFunc:Function;
	}
}