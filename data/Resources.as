package sav.data
{  
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.display.LoaderInfo;

	public class Resources extends EventDispatcher
	{
		public static const COMPLETE:String					= "completed";
		public static const START_NEW_MISSION:String		= "startNewMission";
		public static const SINGLE_MISSION_COMPLETED:String	= "singleMissionCompleted";
		public static const MISSION_PROGRESS:String			= 'missionProgress';
		public static const CLASS:String					= 'class';
		public static const PICTURE:String					= 'picture';
		public static const _XML:String						= 'xml';
		public static const SOUND:String					= 'sound';
		
		public var currentMissionName:String;
		public var currentMissionString:String;
		public var currentMissionPercent:Number			= 0;
		public var currentMissionBytesLoaded:Number		= 0;
		public var currentMissionBytesTotal:Number		= 0;

		private var missionArray:Array;
		private var currentMission:int;
		private var loadedData:Array;
		
		public function get numMissions():uint { return missionArray.length; }				
		public function get numMissionsFinished():uint { return currentMission; }

		public function Resources()
		{
			loadedData		= [];
			missionArray	= [];
		}

		//增加一個載入任務
		//missionType決定資料要怎麼下載和下載後要怎麼處裡
		//loadedDataName是處裡完的資料，儲存在loadedData陣列中的字串索引
		public function addMission(missionType:String,requestURL:String,dataName:String):void
		{
			missionArray.push(new Mission(missionType, requestURL, dataName));
		}

		//清除目前所有的下載任務
		public function clearMission():void
		{
			missionArray = [];
		}
		
		//開始載入
		public function startLoading():void
		{
			currentMission = -1;
			continueMission();
		}
		
		//若任務都執行完了，dispatch完成事件，否則繼續下個任務
		private function continueMission():void
		{						
			currentMission++;
			if (currentMission == missionArray.length)
			{
				dispatchEvent(new Event(Resources.COMPLETE));
			}
			else
			{
				load();
			}
		}

		//執行一個載入任務
		public function load():void
		{			
			var mission:Mission			= missionArray[currentMission];
			var request:URLRequest		= new URLRequest(mission.requestURL);			
			var context:LoaderContext	= new LoaderContext();
			context.applicationDomain	= ApplicationDomain.currentDomain;
			context.checkPolicyFile		= true;
					
			switch (mission.missionType)
			{
				case CLASS :
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeAsClass);
					loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progressHandler);
					loader.load(request,context);
					break;
					
				case PICTURE :
					var picLoader:Loader = new Loader();
					picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeAsPicture);
					picLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progressHandler);
					picLoader.load(request,context);
					break;
					
				case _XML :
					var XMLLoader:URLLoader = new URLLoader();
					XMLLoader.addEventListener(Event.COMPLETE,completeAsXML);
					XMLLoader.addEventListener(ProgressEvent.PROGRESS,progressHandler);
					XMLLoader.load(request);
					break;
					
				case SOUND :
					var soundLoaderContext:SoundLoaderContext = new SoundLoaderContext(0);
					var sound:Sound = new Sound(request , soundLoaderContext);
					sound.addEventListener(ProgressEvent.PROGRESS, progressHandler); 
					sound.addEventListener(Event.COMPLETE, completeAsSound); 
					//sound.load(request);
					break;
			}
			
			if(mission.missionType == SOUND)
			{
				currentMissionString = 'Sound File';
			}
			else if(mission.missionType == _XML)
			{
				currentMissionString = 'XML';
			}
			else
			{
				currentMissionString = mission.dataName;
			}
			currentMissionName = mission.dataName;
			
						
			dispatchEvent(new Event(START_NEW_MISSION));

		}
		
		//取得某個類別
		public function getClass(className:String,targetPackName:String):Class
		{
			var thePack:*		= loadedData[targetPackName];
			var theClass:Class	= thePack.applicationDomain.getDefinition(className) as Class;
			return theClass;
		}
		
		//取得某個載入的資源
		public function getPack(targetPackName:String):*
		{
			var thePack:* = loadedData[targetPackName];
			return thePack;
		}

		//將載入的資料以類別的格式儲存起來
		private function completeAsClass(evt:Event):void
		{
			evt.target.removeEventListener(Event.COMPLETE,completeAsClass);
			evt.target.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
			loadedData[missionArray[currentMission].dataName] = evt.target;

			dispatchEvent(new Event(SINGLE_MISSION_COMPLETED));
			continueMission();
		}

		//將載入的資料以類別的格式儲存起來
		private function completeAsPicture(evt:Event):void
		{			
			evt.target.removeEventListener(Event.COMPLETE,completeAsPicture);
			evt.target.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
					
			loadedData[missionArray[currentMission].dataName] = evt.target;

			dispatchEvent(new Event(SINGLE_MISSION_COMPLETED));
			continueMission();
		}
		
		//將載入的資料以XML的格式儲存起來
		private function completeAsXML(evt:Event):void
		{
			evt.target.removeEventListener(Event.COMPLETE,completeAsXML);
			evt.target.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
			
			var xml = new XML(evt.target.data);
			
			loadedData[missionArray[currentMission].dataName] = xml;

			dispatchEvent(new Event(SINGLE_MISSION_COMPLETED));
			continueMission();
		}
		
		//將載入的聲音資料儲存到'Sound'中
		private function completeAsSound(evt:Event):void
		{
			evt.target.removeEventListener(Event.COMPLETE,completeAsSound);
			evt.target.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
			
			var sound = Sound(evt.target);
			sound.close();
			var soundArray:Array = loadedData['SoundPack'];
			if (soundArray == null) soundArray = [];
			soundArray[missionArray[currentMission].dataName] = sound;
			loadedData['SoundPack'] = soundArray;

			dispatchEvent(new Event(SINGLE_MISSION_COMPLETED));
			continueMission();
		}
		
		private function progressHandler(evt:ProgressEvent):void
		{
			currentMissionBytesLoaded		= evt.bytesLoaded;
			currentMissionBytesTotal		= evt.bytesTotal;
			currentMissionPercent			= int(currentMissionBytesLoaded/currentMissionBytesTotal*100);
			dispatchEvent(new Event(MISSION_PROGRESS));
		}
		
		public function destroy():void
		{
			for each(var data in loadedData)
			{
				if(data is LoaderInfo)
				{
					if (data.content is Bitmap) data.content.bitmapData.dispose();
				}
			}
			missionArray = null;
			loadedData = null;
		}
	}
}

class Mission
{
	public var missionType:String;
	public var requestURL:String;
	public var dataName:String;
	
	function Mission(missionType:String, requestURL:String, dataName:String)	
	{
		this.missionType = missionType;
		this.requestURL = requestURL;
		this.dataName = dataName;
	}
}