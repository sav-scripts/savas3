package sav.ui.utils
{
	import caurina.transitions.Tweener;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class UIAutoHider
	{	
		/**
		 * 
		 * @param	sprite					Sprite		target sprite
		 * @param	showX					Number		x position when showing
		 * @param	showY					Number		y position when showing
		 * @param	hideX					Number		x position when hiding
		 * @param	hideY					Number		y position when hiding
		 * @param	tweenTime				Number		time for tweening
		 * @param	targetHitArea			Object		set to null if don't want enable mouseOver auto hide feature, set to 'autoBuild' for auto draw rectangle shape as hitArea, give a InteractionObject for use it as hitArea
		 * @param	activeAfter				Boolean		active auto hide feature after added
		 * @param	setToHide				Boolean		set to hiding after added
		 * @param	removeTargetWhenHiden	Boolean		remove target from display list when it is hiden
		 * @param	container	DisplayObjectContainer	target sprite container for adding to display list
		 * @param	fadeWhenHiding			Boolean		tween target alpha to 0 if set this to true
		 */
		public static function add(
			sprite:Sprite, 
			showX:Number, showY:Number, hideX:Number, hideY:Number,
			tweenTime:Number = 0.3, 
			targetHitArea:Object = 'autoBuild', activeAfter:Boolean = true, setToHide:Boolean = true, removeTargetWhenHiden:Boolean = true,
			container:DisplayObjectContainer = null,
			fadeWhenHiding:Boolean = false):void
		{
			if (!container)
			{
				if (!sprite.parent) throw new Error("Didn't assign container and target sprite doesn't have parent neigher");
				container = sprite.parent;
			}
			
			var recoard:Recoard = new Recoard();
			recoard.showX = showX;
			recoard.showY = showY;
			recoard.hideX = hideX;
			recoard.hideY = hideY;
			recoard.sprite = sprite;
			recoard.tweenTime = tweenTime;
			recoard.container = container;
			recoard.fadeWhenHiding = fadeWhenHiding;
			
			recoard.removeTargetWhenHiden = removeTargetWhenHiden;
			
			if (_registedDic[sprite]) remove(sprite);
			_registedDic[sprite] = recoard;
			
			var hitArea:Sprite;
			if (targetHitArea == 'autoBuild')
			{
				recoard.needDestroyHitArea = true;
				hitArea = new Sprite();
				
				var bound:Rectangle = sprite.getBounds(sprite);
				hitArea.graphics.beginFill(0x000000);
				hitArea.graphics.drawRect(bound.x, bound.y, bound.width, bound.height);
				hitArea.graphics.endFill();
				
				hitArea.x = showX;
				hitArea.y = showY;
				
				container.addChild(hitArea);
			}
			else if(targetHitArea is Sprite)
			{
				hitArea = Sprite(targetHitArea);
			}
			else
			{
				hitArea = null;
			}
			
			if (hitArea)
			{
				recoard.hitArea = hitArea;
				hitArea.mouseEnabled = hitArea.mouseChildren = false;	
				//hitArea.alpha = .5;
				hitArea.visible = false;
				sprite.hitArea = hitArea;
			}
			
			recoard.isHide = setToHide;
			if (setToHide)
			{
				sprite.x = hideX;
				sprite.y = hideY;
				if (recoard.removeTargetWhenHiden && sprite.parent) sprite.parent.removeChild(sprite);
				if (recoard.fadeWhenHiding) sprite.alpha = 0;
				//hide(sprite, false);
			}
			else
			{
				sprite.x = showX;
				sprite.y = showY;
				if (sprite.parent != container) container.addChild(sprite);
				//show(sprite, false);
			}
			
			if (activeAfter) active(sprite);
		}
		
		public static function changeTweenSetting(
			sprite:Sprite, 
			showX:Number, 
			showY:Number, 
			hideX:Number, 
			hideY:Number, 
			tweenTime:Number = Number.NaN):void
		{
			var recoard:Recoard = _registedDic[sprite];
			if (!recoard) throw new Error("target sprite not registed");
			
			recoard.showX = showX;
			recoard.showY = showY;
			recoard.hideX = hideX;
			recoard.hideY = hideY;
			if (!isNaN(tweenTime)) recoard.tweenTime = tweenTime;
		}
		
		public static function getIsHide(sprite:Sprite):Boolean
		{
			var recoard:Recoard;
			if (!(recoard = _registedDic[sprite])) throw new Error('Target is not registed');
			
			return recoard.isHide;
		}
		
		public static function switchUI(sprite:Sprite):void
		{
			(getIsHide(sprite)) ? show(sprite) : hide(sprite);
		}
		
		public static function active(sprite:Sprite):void
		{
			var recoard:Recoard;
			if (!(recoard = _registedDic[sprite])) throw new Error('Activing none registed sprite');
			
			sprite.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			sprite.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		public static function disactive(sprite:Sprite):void
		{
			var recoard:Recoard;
			if (!(recoard = _registedDic[sprite])) throw new Error('Disactiving none registed sprite');
			
			sprite.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			sprite.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		private static function mouseOver(evt:MouseEvent):void
		{
			//if (evt.currentTarget != evt.target) return;
			var sprite:Sprite = Sprite(evt.currentTarget);
			show(sprite);
		}
		
		private static function mouseOut(evt:MouseEvent):void
		{
			//trace('mouse out on target ' + evt.target);
			//trace('related target = ' + evt.relatedObject);
			var sprite:Sprite = Sprite(evt.currentTarget);
			//trace('contain target = ' + sprite.contains(DisplayObject(evt.target)));
			//trace('contain relate = ' + sprite.contains(DisplayObject(evt.relatedObject)));
			if (evt.relatedObject && sprite.contains(DisplayObject(evt.relatedObject))) return;
			
			hide(sprite);			
		}
		
		public static function show(sprite:Sprite, tweenIt:Boolean = true, onComplete:Function = null, onCompleteParams:Array = null):void
		{
			var recoard:Recoard;
			if (!(recoard = _registedDic[sprite])) throw new Error('Showing none registed sprite');
			
			if (!recoard.isHide) return;
			recoard.isHide = false;
			
			recoard.clearCallBackParams();
			
			recoard.showCompleteFunc = onComplete;
			recoard.showCompleteFuncParams = onCompleteParams;
			
			if (recoard.removeTargetWhenHiden)
				recoard.container.addChild(sprite);
			
			var tx:Number = recoard.showX;
			var ty:Number = recoard.showY;
			var tweenTime:Number = recoard.tweenTime;
			
			Tweener.removeTweens(sprite);
			if (tweenIt)
			{
				var targetAlpha:Number = (recoard.fadeWhenHiding) ? 1 : sprite.alpha;
				Tweener.addTween(sprite, { time:tweenTime, x:tx, y:ty, alpha:targetAlpha, transition:'easeOutSine', onComplete:showComplete, onCompleteParams:[recoard] } );
			}
			else
			{
				sprite.x = tx;
				sprite.y = ty;
				showComplete(recoard);
			}
		}		
		
		private static function showComplete(recoard:Recoard):void
		{
			if (recoard.showCompleteFunc != null)
			{
				recoard.showCompleteFunc.apply(null, recoard.showCompleteFuncParams);
				recoard.showCompleteFunc = null;
				recoard.showCompleteFuncParams = null;
			}
		}
		
		public static function hide(sprite:Sprite, tweenIt:Boolean = true, onComplete:Function = null, onCompleteParams:Array = null):void
		{
			var recoard:Recoard;
			if (!(recoard = _registedDic[sprite])) throw new Error('Hiding none registed sprite');
			
			if (recoard.isHide) return;
			recoard.isHide = true;
			
			recoard.clearCallBackParams();
			
			recoard.hideCompleteFunc = onComplete;
			recoard.hideCompleteFuncParams = onCompleteParams;
			
			var tx:Number = recoard.hideX;
			var ty:Number = recoard.hideY;
			var tweenTime:Number = recoard.tweenTime;
			
			Tweener.removeTweens(sprite);
			if (tweenIt)
			{
				var targetAlpha:Number = (recoard.fadeWhenHiding) ? 0 : sprite.alpha;
				Tweener.addTween(sprite, { time:tweenTime, x:tx, y:ty, alpha:targetAlpha, transition:'easeInSine', onComplete:hideComplete, onCompleteParams:[recoard] } );
			}
			else
			{
				sprite.x = tx;
				sprite.y = ty;
				hideComplete(recoard);
			}
		}
		
		private static function hideComplete(recoard:Recoard):void
		{
			if (recoard.removeTargetWhenHiden)
				recoard.container.removeChild(recoard.sprite);
			
			if (recoard.hideCompleteFunc != null)
			{
				recoard.hideCompleteFunc.apply(null, recoard.hideCompleteFuncParams);
				recoard.hideCompleteFunc = null;
				recoard.hideCompleteFuncParams = null;
			}
		}
		
		public static function remove(sprite:Sprite):void
		{
			var recoard:Recoard;
			if (!(recoard = _registedDic[sprite])) return;
			
			Tweener.removeTweens(sprite);
			disactive(sprite);
			show(sprite, false);
			if (recoard.needDestroyHitArea)
			{
				sprite.hitArea = null;
				var hitArea:Sprite = recoard.hitArea;
				hitArea.parent.removeChild(hitArea);
				hitArea = null;				
			}
			
			sprite.x = recoard.showX;
			sprite.y = recoard.showY;
			
			recoard.clearCallBackParams();
			recoard.sprite = null;
			recoard.hitArea = null;
			recoard.container = null;
			
			delete _registedDic[sprite];
		}
		
		private static var _registedDic:Dictionary= new Dictionary(true);
	}
}

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
	class Recoard
	{
		public var sprite:Sprite;
		public var hitArea:Sprite;
		public var needDestroyHitArea:Boolean = false;		
		public var showX:Number;
		public var showY:Number;
		public var hideX:Number;
		public var hideY:Number;
		public var tweenTime:Number;
		public var fadeWhenHiding:Boolean;
		
		public var isHide:Boolean = false;
		public var removeTargetWhenHiden:Boolean;
		
		public var showCompleteFunc:Function;
		public var showCompleteFuncParams:Array;
		public var hideCompleteFunc:Function;
		public var hideCompleteFuncParams:Array;
		
		public var container:DisplayObjectContainer;
		
		public function clearCallBackParams():void
		{
			showCompleteFunc = null;
			showCompleteFuncParams = null;
			hideCompleteFunc = null;
			hideCompleteFuncParams = null;
		}
	}
