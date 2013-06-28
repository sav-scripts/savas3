package sav.game
{
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;
	
	public class Board extends Shape
	{
		public function Board():void
		{			
		}
		
		public function coverAt(displayObjectContainer:DisplayObjectContainer , w:uint , h:uint , bw:uint = 1 , color:Number = 0x000000 , theAlpha:Number = 1):void
		{			
			this.graphics.clear();
			this.graphics.beginFill(color , theAlpha);
			this.graphics.drawRect(0,0,w-bw,bw);			
			this.graphics.drawRect(w-bw,0,bw,h);			
			this.graphics.drawRect(0,bw,bw,h-bw*2);
			this.graphics.drawRect(0,h-bw,w-bw,bw);
			
			this.graphics.endFill();
			
			displayObjectContainer.addChild(this);
		}
		
		public function raise():void
		{
			if(this.parent) this.parent.addChild(this);
		}
		
		public function resize():void
		{
			coverAt(this.parent , this.stage.stageWidth , this.stage.stageHeight);
		}
	}
}