package sav.components.sliders
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class Icon extends Sprite
	{
		private var maxScaleDistance	:Number = 200;
		private var scaling				:Boolean = false;
		
		private var normalScale			:Number = 0.5;
		private var targetScale			:Number;
		private var maxScale			:Number;

		private var yOffset				:Number;
		
		public function get scale():Number { return this.scaleX; }
		public function set scale(ts:Number):void 
		{
			this.scaleX = this.scaleY = ts; 
			clipBound = new Rectangle( -this.width / 2, -this.height, this.width, this.height);
		}
		
		public var dToMouse				:Number;
		public var iconClip				:MovieClip;
		public var clipBound			:Rectangle;
		
		public var recoverX				:Number;
		public var recoverY				:Number;		
		public function get recoverScale():Number { return normalScale; }
		
		public function get absX():Number { return Math.abs(x); }
		
		public function Icon()
		{
			reset();
		}
		
		public function reset(normalScale:Number = Number.NaN, maxScale:Number = 1, yOffset:Number = -15):void
		{
			if(!isNaN(normalScale)) this.normalScale = this.targetScale = normalScale;
			this.maxScale = maxScale;
			this.yOffset = yOffset;
			
			scale = this.normalScale;
			clipBound = new Rectangle( -this.width / 2, -this.height, this.width, this.height);
		}
		
		public function upadteScale(mx:Number):void
		{
			var dx:Number = Math.abs(mx - this.x);
			if (dx >= maxScaleDistance)
			{
				changeScale(normalScale);
				y = 0;
				return;
			}
			
			var scaleRate:Number = ((maxScaleDistance - dx) / maxScaleDistance);
			var tScale:Number = scaleRate * (maxScale-normalScale) + normalScale;
			changeScale(tScale);
			y = yOffset * scaleRate;
		}
		
		public function changeScale(tScale:Number):void
		{
			if (targetScale != tScale)
			{
				targetScale = tScale;
				
				if (!scaling)
				{
					addEventListener(Event.ENTER_FRAME , changeScaleHandler);
					scaling = true;
				}
			}
		}
		
		public function stopScaling():void
		{
			removeEventListener(Event.ENTER_FRAME , changeScaleHandler);
			scaling = false;
		}
		
		private function changeScaleHandler(evt:Event):void
		{
			var dScale:Number = (targetScale - scale) / 3;
			if (Math.abs(dScale) <= 0.003)
			{
				scale = targetScale;
				stopScaling();
			}
			else
			{
				var tScale:Number = scale + dScale;
				scale = tScale;
			}		
		}
	}
}