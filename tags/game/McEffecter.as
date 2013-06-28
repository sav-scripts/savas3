package sav.game
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import fl.motion.Color;
	import flash.geom.ColorTransform;
	
	import caurina.transitions.Tweener;
	
	public class McEffecter
	{
		/**************************************************  for addEffect  **************************************************
			給予一個效果類別
			give a MovieClipClass , apply it on targetMc as a effect , and remove it when when it on its final frame
		*********************************************************************************************************************/		
		public static function addEffect(targetMc:DisplayObjectContainer,EffectClass:Class,params:Object=null):MovieClip
		{
			var x			= (params == null || params.x == undefined) ? 0 : params.x;
			var y			= (params == null || params.y == undefined) ? 0 : params.y;
			var scaleX		= (params == null || params.scaleX == undefined) ? 1 : params.scaleX;
			var scaleY		= (params == null || params.scaleY == undefined) ? 1 : params.scaleY;
			var rotation	= (params == null || params.rotation == undefined) ? 0 : params.rotation;
			
			var effect		= new EffectClass();
			effect.x		= x;
			effect.y		= y;
			effect.scaleX	= scaleX;
			effect.scaleY	= scaleY;
			effect.rotation	= rotation;
			effect.addEventListener(Event.ENTER_FRAME,effectEnterframeHandler);
			targetMc.addChild(effect);
			
			return effect;
		}
		
		private static function effectEnterframeHandler(evt:Event):void
		{
			if (evt.target.totalFrames == evt.target.currentFrame)
			{
				var p = evt.target.parent;
				p.removeChild(evt.target);
				evt.target.removeEventListener(Event.ENTER_FRAME,effectEnterframeHandler);
				evt.target.dispatchEvent(new Event('effectComplete'));
			}
		}		
		
		
		/**************************************************  for addShake  **************************************************
			晃動一個物件
			give a Shake effect on targetMC
		*********************************************************************************************************************/		
		private static var shakeArray:Array = [];
		
		public static function addShake(targetMc:* , range:Number = 1 , targetCount:int = -1):void
		{
			var object			= {};
			var center			= new Point(targetMc.x,targetMc.y);
			object.targetMc		= targetMc;
			object.range		= range;
			object.center		= center;
			object.currentAngle	= 0;
			object.count		= 0;
			object.targetCount	= targetCount;
			shakeArray.push(object);
			
			targetMc.addEventListener(Event.ENTER_FRAME , shaking);
		}
		
		public static function removeShake(targetMc:*):void
		{
			var object:Object;
			for (var i:uint = 0; i < shakeArray.length; i++)
			{
				object = shakeArray[i];
				if (object.targetMc == targetMc)
				{
					targetMc.x = object.center.x;
					targetMc.y = object.center.y;
				}
				shakeArray.splice(i,1);
				targetMc.removeEventListener(Event.ENTER_FRAME , shaking);
				i --;
			}
		}
		
		private static function shaking(evt:Event):void
		{
			var object;
			for (var i=0;i<shakeArray.length;i++)
			{
				object = shakeArray[i];
				if (object.targetMc == evt.target)
				{
					break;
				}
			}
			
			object.currentAngle = (object.currentAngle + int(Math.random()*180) + 90) % 360;
			var x = Math.sin(Math.PI * object.currentAngle/360) * object.range + object.center.x;
			var y = Math.cos(Math.PI * object.currentAngle/360) * object.range + object.center.y;
			object.targetMc.x = x;
			object.targetMc.y = y;
			
			object.count ++ ;
			if(object.count == (object.targetCount+1)) removeShake(object.targetMc);
		}
		
		
		/**************************************************  for addFlash  **************************************************
			閃光的效果
			apply flash effect on targetMc , make it transform between old colorTransform and new color
		*********************************************************************************************************************/		
		private static var flashArray:Array = [];
		
		public static function addFlash(targetMc:* , params:Object = undefined):void
		{
			var color:Color			= new Color();
			var object:Object		= new Object();
			
			removeFlash(targetMc);
			
			color.color				= (params == null || params.color == undefined) ? 0xffffff : params.color;
			object.time				= (params == null || params.time == undefined) ? 0.5 : params.time;
			object.targetCount		= (params == null || params.count == undefined) ? -1 : params.count;
			object.percent			= (params == null || params.percent == undefined) ? 1 : params.percent;
			object.removeAfter		= (params == null || params.removeAfter == undefined) ? true : params.removeAfter;
			object.backToOldForm	= (params == null || params.backToOldForm == undefined) ? true : params.backToOldForm;
			
			object.targetMc			= targetMc;
			object.oldColorTransform= targetMc.transform.colorTransform;
			object.v				= 1;
			object.p				= 0;
			object.red				= color.redOffset;
			object.green			= color.greenOffset;
			object.blue				= color.blueOffset;
			object.count			= 0;
			Tweener.addTween(object , {time:object.time , p:object.percent , onUpdate:flashUpdate , transition:'linear' , onUpdateParams:[object], onComplete:flashComplete , onCompleteParams:[object]});			
			
			flashArray.push(object);
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
		
		public static function removeFlash(targetMc:* , backToOldForm:Boolean = true):void
		{
			var object:Object;
			for (var i:uint = 0; i < flashArray.length; i++)
			{
				object = flashArray[i];
				if (object.targetMc == targetMc)
				{
					Tweener.removeTweens(object);
					if (backToOldForm) object.targetMc.transform.colorTransform = object.oldColorTransform;
					flashArray.splice(i,1);
					i--
				}
			}			
		}
		
		
		/**************************************************  for applyMotion  **************************************************
			應用動畫在targetMc上
			replace MotionClass object with sourceMc on display object list , and put sourceMc as children as motionClass ,
			so sourceMc will play the motion MotionClass does in sourceMc's old position .
			
			undo this when motionClass dispatch Event.COMPLETE event.
		*********************************************************************************************************************/				
		private static var motionArray:Array = [];
		
		public static function applyMotion(sourceMc:DisplayObjectContainer , MotionClass:Class , params:Object = null):void
		{
			var onCompleteFunction:Function		= (params == null || params.onComplete == undefined)		? null : params.onComplete;
			var removeOnComplete				= (params == null || params.removeOnComplete == undefined)	? true : params.removeOnComplete;
			
			var p:DisplayObjectContainer = sourceMc.parent;			
			var motion:* = new MotionClass();
			while(motion.motionSprite.numChildren > 0) motion.motionSprite.removeChildAt(0);
			motion.removeOnComplete = removeOnComplete;
			motion.onCompleteFunction		= onCompleteFunction;
			motion.addEventListener(Event.COMPLETE , motionComplete);
			motion.x = sourceMc.x;
			motion.y = sourceMc.y;
			sourceMc.x = 0;
			sourceMc.y = 0;
			var index = p.getChildIndex(sourceMc);
			motion.motionSprite.addChild(sourceMc);
			p.addChildAt(motion , index);
			
			motionArray.push({sourceMc:sourceMc , motion:motion , onCompleteFunction:onCompleteFunction});			
		}
		
		private static function motionComplete(evt:Event):void
		{
			var motion = evt.target;
			if (motion.removeOnComplete)
			{
				var sourceMc = motion.motionSprite.getChildAt(0);
				removeMotion(sourceMc);				
			}
			if (motion.onCompleteFunction != null) motion.onCompleteFunction();
		}
		
		public static function removeMotion(sourceMc:*):void
		{
			for (var i:uint = 0; i < motionArray.length; i++)
			{
				var object:Object = motionArray[i];
				if (object.sourceMc == sourceMc)
				{
					var motion		= object.motion;
					var p			= motion.parent;
					sourceMc.x		= motion.x;
					sourceMc.y		= motion.y;
					var index		= p.getChildIndex(motion);
					p.removeChild(motion);
					p.addChildAt(sourceMc , index);						
					motion.removeEventListener(Event.COMPLETE , motionComplete);
					motionArray.splice(i , 1);
					i--;
				}
			}
		}		
	}
}