/*	this is a assest , use BulkLoader to load files 
 * 	there is method allow this class load file list from a xml , and analyze the list then load files in the list
 * 	also there is a method help user get Class from swf files loaded
 * 
 *	all sound type files are stored in sounds array , for pass to SoundPlayer in future
 */
package sav.data
{
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import flash.utils.Dictionary;
	import sav.events.AssetsEvent;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import flash.events.Event;
	import sav.interfaces.IAssets;
	
	[Event(name = 'complete', type = 'flash.events.Event')]
	[Event(name = 'assetsItemFail', type = 'sav.events.AssetsEvent')]
	
	public class Assets	extends EventDispatcher implements IAssets
	{		
		public function Assets(logStatues:int = 10, masterPath:String = null)
		{
			_masterPath = masterPath;
			_sounds = [];
			_states = AssetStates.READY;
			
			_singleLoadingDic = new Dictionary(true);
			
			_loader = new BulkLoader(null, BulkLoader.DEFAULT_NUM_CONNECTIONS, logStatues);
			_loader.addEventListener(BulkLoader.ERROR , loaderError);
		}
		
		// give a file list (xml) and start loading until this list and it's files are all loaded
		public function addFiles(xmlAdress:String):void
		{
			if (states != AssetStates.READY) throw new Error('Assets ' + this + ' not ready yet');
			
			_loader.add(xmlAdress , {id:'fileList'});
			_loader.addEventListener(BulkProgressEvent.COMPLETE , fileListLoaded);
			_loader.start();			
			_states = AssetStates.LOADING;
		}
		
		// file list is loaded , continue with loading files
		private function fileListLoaded(evt:BulkProgressEvent):void
		{
			_loader.removeEventListener(BulkProgressEvent.COMPLETE , fileListLoaded);
			
			dispatchEvent(new AssetsEvent(AssetsEvent.FILE_LIST_LOADED));
			
			var xml:XML = _loader.getXML('fileList' , true);
			var useFileNameAsId:Boolean = (xml.config.@useFileNameAsId == 'false') ? false : true;
			var masterPath:String = (_masterPath) ? _masterPath : String(xml.config.@masterPath);
			fileList = xml.file;			
			
			if (fileList.length() == 0)
			{
				dispatchEvent(new Event(Event.COMPLETE));	
				return;
			}
			
			var loadingItem:LoadingItem;			
			for each(var file:XML in fileList)
			{
				var url:String = String(file.@url);
				var fileUseMasterPath:Boolean = (file.@userMasterPath == 'false') ? false : true;
				if (fileUseMasterPath) url = masterPath + url;
				
				var id:String = String(file.@id);
				
				if (id == '' && useFileNameAsId) id = url.split('/').pop().split('.').shift();
				if (id == '')
				{
					loadingItem = _loader.add(url);
				}
				else
				{
					loadingItem = _loader.add(url , {id:id});					
				}
				
				if (loadingItem.type == 'sound')
				{
					loadingItem.addEventListener(Event.COMPLETE , aSoundLoaded);
				}
			}			
			loaderStart();
		}
		
		// start _loader loading
		public function loaderStart():void
		{
			_loader.addEventListener(BulkProgressEvent.COMPLETE , allAssetsLoaded);
			_loader.start();			
		}
		
		// when a sound loaded , store it in sounds array
		private function aSoundLoaded(evt:Event):void
		{
			var loadingItem:LoadingItem = LoadingItem(evt.target);
			loadingItem.removeEventListener(Event.COMPLETE , aSoundLoaded);
			_sounds[loadingItem.id] = loadingItem.content;
		}
		
		// error listener
		private function loaderError(evt:Event):void
		{			
			var errorArray:Array = _loader.getFailedItems();			
			var assetsEvent:AssetsEvent = new AssetsEvent(AssetsEvent.ASSETS_ITEM_FAIL);
			assetsEvent.item = errorArray[0];
			_loader.removeFailedItems();
			dispatchEvent(assetsEvent);
		}
		
		// when all file loaded , set states to ready , and dispatch READYevent
		private function allAssetsLoaded(evt:BulkProgressEvent):void
		{
			_loader.removeEventListener(BulkProgressEvent.COMPLETE , allAssetsLoaded);
			_states = AssetStates.READY;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * get content from _loader 
		 * @param	id	String	Id of the file
		 * @return		*		return any type of the file stored in assets
		 */
		public function getPack(id:String):*
		{
			//_loader.ha
			return _loader.getContent(id);
		}		
		
		/**
		 * get a class from a swf file
		 * @param	className	String	Class name
		 * @param	id			String	Id of the swf file in assets
		 * @return				Class	Return a class from a swf file
		 */
		public function getClass(className:String , id:String):Class
		{
			var movieClip:MovieClip = _loader.getMovieClip(id);
			
			if (movieClip == null)
			{
				throw new Error('Can not find ' + id + ' as movieclip in asset');
				return null;
			}
			
			try
			{
				var c:Class = Class(movieClip.loaderInfo.applicationDomain.getDefinition(className));
			}
			catch (er:Error)
			{
				throw new Error('Can not find definition ' + className + ' from asset (id = ' + id + ' ).');
				return null;
			}
			return c;
		}
		
		/*************************************
		 *		Load URL(callback version
		 * **********************************/
		public function loadURL(url:String, loaderParams:Object = null, 
			successFunc:Function = null, successFuncParams:Array = null, 
			failFunc:Function = null, failFuncParams:Array = null, 
			progressFunc:Function = null, progressFuncParams:Array = null):void
		{
			var obj:Object = { };
			obj.successFunc = successFunc;
			obj.successFuncParams = successFuncParams;
			obj.failFunc = failFunc;
			obj.failFuncParams = failFuncParams;
			obj.progressFunc = progressFunc;
			obj.progressFuncParams = progressFuncParams;
			
			var loadingItem:LoadingItem = loader.add(url, loaderParams );
			loadingItem.addEventListener(Event.COMPLETE, singleFileLoaded);
			loadingItem.addEventListener(BulkLoader.ERROR, singleFileError);
			loadingItem.addEventListener(BulkProgressEvent.PROGRESS, singleFileProgress);
			
			_singleLoadingDic[loadingItem] = obj;
			
			_loader.start();
		}
		
		private function singleFileLoaded(evt:Event):void
		{
			var loadingItem:LoadingItem = LoadingItem(evt.currentTarget);
			var obj:Object = _singleLoadingDic[loadingItem];
			if (obj && obj.successFunc) obj.successFunc.apply(null, obj.successParams);
			
			clearSingleFileLoading(loadingItem);
		}
		
		private function singleFileError(evt:Event):void
		{
			var loadingItem:LoadingItem = LoadingItem(evt.currentTarget);
			var obj:Object = _singleLoadingDic[loadingItem];
			if (obj && obj.failFunc) obj.failFunc.apply(null, obj.failFuncParams);
			
			clearSingleFileLoading(loadingItem);
		}
		
		private function singleFileProgress(evt:BulkProgressEvent):void
		{
			var loadingItem:LoadingItem = LoadingItem(evt.currentTarget);
			var obj:Object = _singleLoadingDic[loadingItem];
			if (obj && obj.progressFunc) obj.progressFunc.apply(null, obj.progressFuncParams);
		}
		
		private function clearSingleFileLoading(loadingItem:LoadingItem):void
		{
			loadingItem.removeEventListener(Event.COMPLETE, singleFileLoaded);
			loadingItem.removeEventListener(BulkLoader.ERROR, singleFileError);
			loadingItem.removeEventListener(BulkProgressEvent.PROGRESS, singleFileProgress);
			
			delete _singleLoadingDic[loadingItem];
		}
		
		private var _loader						:BulkLoader;					// the _loader
		public function get loader():Object { return Object(_loader); }
		
		private var fileList					:XMLList;						// loaded file list
		
		private var _states						:String;						// current states		
		public function get states():String { return _states;}
		
		private var _sounds:Array;
		public function get sounds():Array { return _sounds; }
		
		private var _masterPath:String;
		
		private var _singleLoadingDic:Dictionary;
	}
}