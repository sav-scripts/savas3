package sav.effects.utils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class BounceEffect
	{
		private static var stored:Dictionary = new Dictionary();
		
		/**
		 * give a clip, make it tween to a target position with bounce / blur effect
		 * @param	clip			DisplayObject	target clip
		 * @param	tx				Number			traget x
		 * @param	ty				Number			target y
		 * @param	speed			Number			give a init speed
		 * @param	spring			Number			spring rate (0~1) for bounce effect
		 * @param	friction		Number			friction rate (0~1) for bounce effect
		 * @param	blurIt			Boolean			should apply a blur filter or not
		 * @param	onCompleteFunc	Functione		callback function executed when bounce complete
		 */
		public static function add(clip:DisplayObject, tx:Number, ty:Number, speed:Number = 0, spring:Number = 0.13, friction:Number = 0.65, blurIt:Boolean = true, onCompleteFunc:Function = null, onUpdateFunc:Function = null):void
		{
			if (stored[clip]) remove(clip);
			
			var bounce:Bounce = new Bounce(clip, tx, ty, speed, spring, friction, blurIt, onCompleteFunc, onUpdateFunc);
			clip.addEventListener(Event.ENTER_FRAME, bouncing);
			stored[clip] = bounce;
		}
		
		/**
		 * remove bounce effect from a clip
		 * @param	clip				DisplayObject	target clip
		 * @param	bounceComplete		Boolean			make it ture for execute onComplete function (if there is onCompleteFunc
		 */
		public static function remove(clip:DisplayObject, bounceComplete:Boolean = false):void
		{
			var bounce:Bounce = stored[clip];
			if (bounce && bounce.blurIt)
			{
				clip.filters = bounce.oldFilters.concat([]);
			}
			
			if (bounce && bounceComplete && bounce.onCompleteFunc != null)
			{
				bounce.onCompleteFunc();
			}
			
			clip.removeEventListener(Event.ENTER_FRAME, bouncing);
			delete stored[clip];
		}		
		
		private static function bouncing(evt:Event):void
		{	
			var clip:DisplayObject = DisplayObject(evt.target);
			var bounce:Bounce = stored[clip];
			
			var cp:Point = new Point(clip.x, clip.y);
			var dp:Point = bounce.tp.subtract(cp);
			bounce.speed += dp.length * bounce.spring;
			bounce.speed *= bounce.friction;
			
			if (Math.abs(bounce.speed) < 1)
			{
				clip.x = bounce.tx;
				clip.y = bounce.ty;
				if (bounce.onUpdateFunc != null) bounce.onUpdateFunc();
				remove(clip, true);
				return;
			}
			
			dp.normalize(bounce.speed);
			clip.x += dp.x;
			clip.y += dp.y;
			
			if (bounce.blurIt)
			{
				bounce.blurFilter.blurX = Math.abs(dp.x);
				bounce.blurFilter.blurY = Math.abs(dp.y);
				clip.filters = bounce.oldFilters.concat([bounce.blurFilter]);
			}
			
			if (bounce.onUpdateFunc != null) bounce.onUpdateFunc();
		}
	}	
}

import flash.display.DisplayObject;
import flash.filters.BlurFilter;
import flash.geom.Point;

class Bounce
{
	public var clip:DisplayObject;
	public var tx:Number;
	public var ty:Number;
	public var tp:Point;
	public var speed:Number;
	public var spring:Number;
	public var friction:Number;
	public var blurIt:Boolean;	
	public var blurFilter:BlurFilter;
	public var oldFilters:Array;
	public var onCompleteFunc:Function;
	public var onUpdateFunc:Function;
	
	public function Bounce(clip:DisplayObject, tx:Number, ty:Number, speed:Number = 10, spring:Number = 0.4, friction:Number = 0.55, blurIt:Boolean = true,	onCompleteFunc:Function = null, onUpdateFunc:Function = null)
	{
		this.clip = clip;
		this.tx = tx;
		this.ty = ty;
		this.speed = speed;
		this.spring = spring;
		this.friction = friction;
		this.blurIt = blurIt;
		this.onCompleteFunc = onCompleteFunc;		
		this.onUpdateFunc = onUpdateFunc;
		
		if (blurIt)
		{
			blurFilter = new BlurFilter(0, 0, 3);
			oldFilters = clip.filters.concat([]);
		}
		
		tp = new Point(tx, ty);
	}
}