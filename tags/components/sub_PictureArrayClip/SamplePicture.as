/******************************************************************************************************************
	This is sub class for PictureArrayClip
	
*******************************************************************************************************************/
package sav.components.sub_PictureArrayClip
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	
	import caurina.transitions.Tweener;
	
	import sav.components.PictureArrayClip;
	import sav.game.McEffecter;
	
	public class SamplePicture extends Sprite
	{
		private var loadingPath				:String;		//	the url this picture came from
		private var clickFunction			:Function;		// 	the function which excuted when this is clicked
		private var _myBitmap				:Bitmap;		//	this picture's bitmap
		
		public function get myBitmap():Bitmap { return _myBitmap; }
		
		public function set myBitmap(bitmap:Bitmap):void
		{
			(bitmap == null) ? removeChild(_myBitmap) : addChild(bitmap);			
			_myBitmap = bitmap;
			
			this.alpha = 0;
			Tweener.addTween(this , {time:0.5 , alpha:1});
		}
		
		public function SamplePicture(cf:Function , lp:String)
		{
			clickFunction		= cf;
			loadingPath			= lp;
			super();
		}
		
		public function activeInteractive():void
		{
			addEventListener(MouseEvent.CLICK , clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
			
		}
		
		public function disactiveInterActive():void
		{
			removeEventListener(MouseEvent.CLICK , clickHandler);
		}
		
		private function clickHandler(evt:MouseEvent):void
		{
			clickFunction(loadingPath);
		}		
		private function mouseOverHandler(evt:MouseEvent):void
		{
			McEffecter.addFlash(this , {time:0.2 , count:2 , color:0xffffff , percent:0.3 , removeAfter:true});
		}
		
		private function mouseOutHandler(evt:MouseEvent):void
		{
		}
		
		public function destroy():void
		{
			removeEventListener(MouseEvent.CLICK , clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
			removeEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
			
			_myBitmap.bitmapData.dispose();
			_myBitmap				= null;
			clickFunction			= null;
		}		
	}
}