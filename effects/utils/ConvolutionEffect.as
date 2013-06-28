package sav.effects.utils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class ConvolutionEffect
	{
		private static var stored:Dictionary = new Dictionary();
		
		/**
		 * give a clip, make it tween to a target position with effect / blur effect
		 * @param	clip			DisplayObject	target clip
		 * @param	tx				Number			traget x
		 * @param	ty				Number			target y
		 * @param	step			Number			total steps for whole effect
		 * @param	blurIt			Boolean			should apply a blur filter or not
		 * @param	onCompleteFunc	Function		callback function executed when effect complete
		 * @param	onUpdateFunc	Function		callback function excuted for each step
		 */
		public static function add(clip:DisplayObject, tx:Number, ty:Number, steps:uint = 24, blurIt:Boolean = true, onCompleteFunc:Function = null, onUpdateFunc:Function = null):void
		{
			if (stored[clip]) remove(clip);
			
			var effect:Effect = new Effect(clip, tx, ty, step, blurIt, onCompleteFunc, onUpdateFunc);
			clip.addEventListener(Event.ENTER_FRAME, running);
			stored[clip] = effect;
		}
		
		/**
		 * remove effect effect from a clip
		 * @param	clip				DisplayObject	target clip
		 * @param	effectComplete		Boolean			make it ture for execute onComplete function (if there is onCompleteFunc
		 */
		public static function remove(clip:DisplayObject, effectComplete:Boolean = false):void
		{
			var effect:Effect = stored[clip];
			if (effect && effect.blurIt)
			{
				clip.filters = effect.oldFilters.concat([]);
			}
			
			if (effect && effectComplete && effect.onCompleteFunc != null)
			{
				effect.onCompleteFunc();
			}
			
			clip.removeEventListener(Event.ENTER_FRAME, running);
			delete stored[clip];
		}
		
		private static function running(evt:Event):void
		{	
			var clip:DisplayObject = DisplayObject(evt.target);
			var effect:Effect = stored[clip];
			
			var cp:Point = new Point(clip.x, clip.y);
			var dp:Point = effect.tp.subtract(cp);
			effect.speed += dp.length * effect.spring;
			effect.speed *= effect.friction;
			
			if (Math.abs(effect.speed) < 1)
			{
				clip.x = effect.tx;
				clip.y = effect.ty;
				if (effect.onUpdateFunc != null) effect.onUpdateFunc();
				remove(clip, true);
				return;
			}
			
			dp.normalize(effect.speed);
			clip.x += dp.x;
			clip.y += dp.y;
			
			if (effect.blurIt)
			{
				effect.blurFilter.blurX = Math.abs(dp.x);
				effect.blurFilter.blurY = Math.abs(dp.y);
				clip.filters = effect.oldFilters.concat([effect.blurFilter]);
			}
			
			if (effect.onUpdateFunc != null) effect.onUpdateFunc();
		}
	}	
}

import flash.display.DisplayObject;
import flash.filters.BlurFilter;
import flash.geom.Point;

class Effect
{
	public var clip:DisplayObject;
	public var tx:Number;
	public var ty:Number;
	public var tp:Point;
	public var totalStep:int;
	public var currentStep:int;
	public var blurIt:Boolean;	
	public var blurFilter:BlurFilter;
	public var oldFilters:Array;
	public var onCompleteFunc:Function;
	public var onUpdateFunc:Function;
	
	public function Effect(clip:DisplayObject, tx:Number, ty:Number, step:uint = 24, blurIt:Boolean = true,	onCompleteFunc:Function = null, onUpdateFunc:Function = null)
	{
		this.clip = clip;
		this.tx = tx;
		this.ty = ty;
		this.totalStep = step;
		this.currentStep = 0;
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