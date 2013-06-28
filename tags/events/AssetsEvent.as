package sav.events
{
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import flash.events.Event;
	
	public class AssetsEvent extends Event
	{
		public static const ASSETS_ITEM_FAIL	:String = 'assetsItemFail';
		public static const FILE_LIST_LOADED	:String = 'fileListLoaded';		// dispatch this event when file list loaded
		
		public var item:LoadingItem;
		
		public function AssetsEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			if (type == null) type = '';
			super(type, bubbles, cancelable);
		}
	}
}