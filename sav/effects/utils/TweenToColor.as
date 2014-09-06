package sav.effects.utils
{
	import caurina.transitions.properties.ColorShortcuts;
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	public class TweenToColor
	{
		public static function add(clip:DisplayObject, time:Number, color:uint, targetProgress:Number = 1, onCompleteFunc:Function = null):void
		{
			if (stored[clip]) remove(clip);
			
			var record:Record = new Record(clip, time, color, targetProgress, onCompleteFunc);
			stored[clip] = record;
			/*
			clip.transform.colorTransform = new ColorTransform();
			trace('target progress = ' + targetProgress);
			Tweener.addTween(record, { time:time, progress:targetProgress, transition:'linear', 
				onUpdate:tweenUpdate, onUpdateParams:[record], 
				onComplete:tweenComplete , onCompleteParams:[record] } );			
				*/
				
			ColorShortcuts.init();
			
			clip.transform.colorTransform = new ColorTransform();
			
			Tweener.addTween(clip, { time:3, _brightness:1 } );			
		}
		
		public static function remove(clip:DisplayObject):void
		{
			
		}		
		
		private static function tweenUpdate(record:Record):void
		{
			var progress:Number = record.progress;
			var p:Number = 1 - progress;
			
			trace('progress = ' + progress);			
			
			var colorTransform:ColorTransform = new ColorTransform(p, p, p);
			colorTransform.redOffset = record.tR;
			colorTransform.greenOffset = record.tG;
			colorTransform.blueOffset = record.tB;			
			record.clip.transform.colorTransform = colorTransform;
		}
		
		private static function tweenComplete(record:Record):void		
		{
		}
		
		private static var stored:Dictionary = new Dictionary();
	}	
}

import flash.display.DisplayObject;
import flash.utils.Dictionary;
class Record
{
	public var clip:DisplayObject;
	public var time:Number;
	public var color:uint;
	public var targetProgress:Number;
	public var onCompleteFunc:Function;
	
	public var tR:uint;
	public var tG:uint;
	public var tB:uint;
	
	public var progress:uint = 0;
	
	public function Record(clip:DisplayObject, time:Number, color:uint, targetProgress:Number = 1, onCompleteFunc:Function = null)
	{
		this.clip = clip;
		this.time = time;
		this.color = color;
		this.targetProgress = targetProgress;
		this.onCompleteFunc = onCompleteFunc;
		
		
		tR = color >> 16;
		tG = color >> 8 & 0xff;
		tB = color & 0xff;
		
		/*
			colorTransform.redMultiplier		= 1- object.p;
			colorTransform.greenMultiplier		= 1- object.p;
			colorTransform.blueMultiplier		= 1- object.p;
			colorTransform.redOffset			= object.red * object.p;
			colorTransform.greenOffset			= object.green * object.p;
			colorTransform.blueOffset			= object.blue * object.p;
		*/
	}
}