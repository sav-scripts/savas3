package sav.game.effects
{  
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	import flash.events.Event;
	
	public class FallingLeaf extends MovieClip
	{		
		private var interval			:Number;				//製造花瓣的間隔時間(毫秒)
		private var continueProduce		:Boolean = false;
		private var LeafClass			:Class;
		
		public var dispearHeight		:uint = 50;
		public var initVx				:Number = 2;			//花瓣起始速率 X
		public var initVy				:Number = 2;			//花瓣起始速率 Y
		public var spring				:Number = 0.001;		//彈射比率
		public var rotationFriction		:Number = 24/25;		//讓花瓣角度漸漸歸零的摩擦率
		public var windVx				:Number = 0;
		public var limitVx				:Number = 10;
		public var loop					:Boolean = true;
		
		public function FallingLeaf(lfc:Class,flowerPerSec:uint = 10)
		{
			LeafClass	= lfc;
			interval	= 1000 / flowerPerSec;
		}
		
		public function start():void
		{			
			if (continueProduce == false)
			{
				continueProduce = true;
				makeLeaf();
			}
		}
		
		private function stopProduce():void
		{
			continueProduce = false;
		}
		
		private function makeLeaf():void
		{
			var leaf			= new LeafClass();			
			var scale			= (Math.random()*5+5)/10;						//用來表現遠近效果的值
			leaf.originalX		= int(Math.random()*stage.stageWidth);			//設定彈射的目標 X 座標
			leaf.x				= leaf.originalX + Math.random()*20-10;
			leaf.y				= -dispearHeight;
			leaf.scaleX			= scale;
			leaf.scaleY			= scale;
			leaf.vx				= initVx*scale;
			leaf.vy				= initVy*scale;
			leaf.alpha			= (scale-0.5)*2;
			
						
			leaf.addEventListener(Event.ENTER_FRAME,leafFalling);
			addChild(leaf);
			
			if (continueProduce) setTimeout(makeLeaf,interval);
		}
		
		private function leafFalling(evt:Event):void
		{			
			var leaf = evt.target;
			var dx:Number	= leaf.originalX - leaf.x;
			var ax:Number	= dx*spring;
			leaf.vx			+= ax;
			leaf.x			+= leaf.vx  + windVx;
			leaf.y 			+= leaf.vy - Math.abs(leaf.vx)/10;
			leaf.rotation	-= leaf.vx;
			leaf.rotation	*= rotationFriction;
			leaf.originalX	+= windVx;
			
			//循環效果
			if(loop)
			{
				var dx2:Number	= leaf.x - stage.stageWidth;
				var dOriginalX:Number;
				if (dx2>0)
				{
					dOriginalX		= leaf.x - leaf.originalX;
					leaf.x			= dx2;
					leaf.originalX	= leaf.x - dOriginalX;
				}
				
				dx2 = leaf.x - 0;
				if (dx2<0) 
				{
					dOriginalX		= leaf.x - leaf.originalX;
					leaf.x			= stage.stageWidth + dx2;
					leaf.originalX	= leaf.x - dOriginalX;
				}
			}
			
			if (leaf.y > stage.stageHeight + dispearHeight)
			{
				leaf.removeEventListener(Event.ENTER_FRAME,leafFalling);
				removeChild(leaf);
			}
			

		}
	}
	
}