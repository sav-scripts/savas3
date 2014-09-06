package sav.components
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class LoadingListener extends MovieClip
	{
		public var loadingIcon:MovieClip;
		public var _targetFrame:uint = 1;
		
		public function LoadingListener()
		{
			this.loadingIcon.stop();
			this.addEventListener(Event.ENTER_FRAME , updateFrame);
		}
		
		public function update(frameIndex:uint):void
		{
			_targetFrame = (frameIndex == 0) ? 1 : frameIndex;
		}
		
		private function updateFrame(evt:Event):void
		{
			if (loadingIcon.currentFrame < _targetFrame)
			{
				loadingIcon.nextFrame();
			}
		}
		
				
		public function destroy():void
		{
			this.removeEventListener(Event.ENTER_FRAME , updateFrame);
			loadingIcon = null;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}