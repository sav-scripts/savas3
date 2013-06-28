package sav.effects.utils
{
	import caurina.transitions.properties.ColorShortcuts;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import fl.motion.Color;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	
	import caurina.transitions.Tweener;
	
	public class Flasher
	{
		/**************************************************  for addFlash  **************************************************
			閃光的效果
			apply flash effect on targetMc , make it transform between old colorTransform and new color
		*********************************************************************************************************************/		
		private static var _flashDic:Dictionary = new Dictionary(true);
		
		public static function add(
			targetMc:Sprite, 
			targetColor:uint = 0xffffff, 
			targetPercent:Number = 1,
			timeGap:Number = 0.5, 
			targetCount:int = -1,
			removeAfter:Boolean = true,
			backToOldFrom:Boolean = true):void
		{
			var color:Color			= new Color();
			var object:Object		= new Object();
			
			removeFlash(targetMc);
			
			color.color				= targetColor;
			object.time				= timeGap;
			object.targetCount		= targetCount;
			object.percent			= targetPercent;
			object.removeAfter		= removeAfter;
			object.backToOldForm	= backToOldFrom;
			
			object.targetMc			= targetMc;
			object.oldColorTransform= targetMc.transform.colorTransform;
			object.v				= 1;
			object.p				= 0;
			object.red				= color.redOffset;
			object.green			= color.greenOffset;
			object.blue				= color.blueOffset;
			object.count			= 0;
			//ColorShortcuts.
			Tweener.addTween(object , {time:object.time , p:object.percent , onUpdate:flashUpdate , transition:'linear' , onUpdateParams:[object], onComplete:flashComplete , onCompleteParams:[object]});			
			
			_flashDic[targetMc] = object;
		}
		
		private static function flashUpdate(object:Object):void
		{
			var colorTransform:ColorTransform	= object.targetMc.transform.colorTransform;
			colorTransform.redMultiplier		= 1- object.p;
			colorTransform.greenMultiplier		= 1- object.p;
			colorTransform.blueMultiplier		= 1- object.p;
			colorTransform.redOffset			= object.red * object.p;
			colorTransform.greenOffset			= object.green * object.p;
			colorTransform.blueOffset			= object.blue * object.p;
			object.targetMc.transform.colorTransform = colorTransform;
		}
		
		private static function flashComplete(object:Object):void
		{
			if (object.targetCount != -1) object.count ++;

			if (object.targetCount != object.count) 
			{	
				object.v *= -1;
				var progress:Number = (object.v == 1) ? object.percent : 0;
				Tweener.addTween(object , {time:object.time , p:progress , onUpdate:flashUpdate , transition:'linear' , onUpdateParams:[object], onComplete:flashComplete , onCompleteParams:[object]});		
			}
			else
			{
				if (object.removeAfter) removeFlash(object.targetMc , object.backToOldForm);
			}
		}		
		
		public static function removeFlash(targetMc:Sprite , backToOldForm:Boolean = true):void
		{
			var object:Object = _flashDic[targetMc];
			if (!object) return;
			
			if (object.targetMc == targetMc)
			{
				Tweener.removeTweens(object);
				if (backToOldForm) object.targetMc.transform.colorTransform = object.oldColorTransform;
				delete _flashDic[targetMc];
			}
		}
	}
}