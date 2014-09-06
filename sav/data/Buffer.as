package sav.data 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author sav
	 */
	public class Buffer 
	{	
		public function addData(id:String, data:*, type:*, ignoreConflict:Boolean = false):void
		{
			if (!(data is type)) throw new Error("data type isn't fit");
			
			if (_dataDic[type] == undefined) _dataDic[type] = new Object();
			var objDic:Object = _dataDic[type];
			
			var obj:DataObj = objDic[id];
			
			if (obj)
			{
				if (ignoreConflict == false )
					throw new Error('Data with same id founded, id:[' + id + '], type:[' + type + ']');
				else
					removeData(id, type, true);
			}
			
			objDic[id] = new DataObj(id, data, type);
		}
		
		public function getData(id:String, type:*):*
		{
			var objDic:Object = _dataDic[type];
			if (!objDic) throw new Error("data type [" + type + "] wasn't created");
			var obj:DataObj = objDic[id];
			if (!obj) throw new Error("data id:[" + id + "], type:[" + type + "] not found");
			return obj.data;
		}
		
		public function removeData(id:String, type:*, disposeIt:Boolean = true):void
		{
			var objDic:Object = _dataDic[type];
			if (!objDic) throw new Error("data type [" + type + "] wasn't created");
			var obj:DataObj = objDic[id];
			if (disposeIt) disposeData(obj.data);
			delete objDic[id];
		}
		
		/// override this method for dispose spec data type
		protected function disposeData(data:*):void
		{
		}
		
		protected var _dataDic:Dictionary = new Dictionary();
	}
}

class DataObj
{
	public function DataObj(id:String, data:*, type:Class)
	{
		this.id = id;
		this.data = data;
		this.type = type;
	}
	
	public var id:String;
	public var data:*;
	public var type:*;
}