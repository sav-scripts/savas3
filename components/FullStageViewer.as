/******************************************************************************************************************
	This is sub class for PictureArrayClip
	
		When a samplePicture is selected in PictureArrayClip , it send a Bitmap to here , if that Bitmap is not sample ,
	we zoom it to max size it can be for stage , if that bitmap is a sample , we move it to center of stage and wait PictureArrayClip
	load the original size picture and call <replaceBitmap> function here , to replace bitmap .
	
		When a bitmap is in full stage size , but its original size is bigger , there is another function <excuteFullSize> allow 
	we zoom that bitmap to full size .
	
		In full stage size mode , click blackCover will undo view for this class , in full picture size mode , you can drag picture 
	by mouseDown on blackCover , and double click on blackCover will undo view	
	
*******************************************************************************************************************/
package sav.components
{
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import caurina.transitions.Tweener;
	
	import sav.game.MouseRecorder;
	
	public class FullStageViewer extends Sprite
	{
		public var parentRef				:DisplayObjectContainer;		//	where this should be added on displayList , usually it is stage
		public var blackCover				:Sprite;						//	a blackCover , mouse listeners is bind on it
		public var viewingBitmap			:Bitmap;						//	the Bitmap we are viewing , it maybe a sample picture
		public var replacingBitmap			:Bitmap;						//	the Bitmap we use to replace current bitmap , it usually is original size of same picture
		
		private var viewingBitmapOldParent		:DisplayObjectContainer;	//	old parent for viewingBitmap , when undo view is completed , we send viewingBitmap to its old papa
		private var viewingBitmapOldBound		:Rectangle;					//	where viewingBitmap was , and how bit it was when it is send here
		private var viewingBitmapOldBoundHere	:Rectangle;					//	same as viewingBitmapOldBound , but different coordinate
		private var _fullStageSizeBound			:Rectangle;					//	How big and where we should zoom bitmap to , for fit stage size .
		private var _fullSizeBound				:Rectangle;					//	same as _fullStageSizeBound , but is full size of picture
		private var alreadyFullSize				:Boolean;					//	a recoard for is the picture we viewing alerady in full size or not
		
		public function get fullSizeBound():Rectangle { return _fullSizeBound; }		
		public function get fullStageSizeBound():Rectangle { return _fullStageSizeBound; }		
		
		public function get bitmap():Bitmap
		{
			if (replacingBitmap) return replacingBitmap;
			if (viewingBitmap) return viewingBitmap;
			return null;
		}
		
		public var enableFullSizeFunction		:Boolean;					//	use this to make full size viewing able or not
		public var isActive						:Boolean = false;			//	is this called by PictureArrayClip and added on displayList
		public var inflateValue					:int = 40;					//	a fix value for full stage bound , use it for make more space between picture and stage edge
		
		
		public function FullStageViewer()
		{
		}
		
		//	this is start function for FullStageViewer when viewing a picture 
		
		//	when this Class is start working , PictureArrayClicp send a bitmap here , we BORROW it from SamplePicture and store it s viewingBitmap here
		//	be noted , that bitmap is borrow from SamplePicture class , we will return it to its old parent and position , when viewing is complete here
		
		//	send a bitmap , we caculate it's old bound , and build blackCover , and set displayObjects here
		//	in end part of this function , we call zoomIn to start zoom the bitmap
		//	when this function is completed , 'viewStarted' event is dispatched
		public function viewBitmap(bitmap:Bitmap , isSample:Boolean = false):void
		{
			isActive				= true;
			viewingBitmap			= bitmap;
			viewingBitmapOldParent	= bitmap.parent;
			var rectangle			= new Rectangle(0 , 0  , parentRef.stage.stageWidth , parentRef.stage.stageHeight);
			
			blackCover				= new Sprite();
			blackCover.doubleClickEnabled = true;
			blackCover.graphics.beginFill(0x000000 , 0.5);
			blackCover.graphics.drawRect(rectangle.x , rectangle.y , rectangle.width , rectangle.height);
			blackCover.alpha = 0;
			
			var oldPosition = new Point(bitmap.x , bitmap.y);
			var newPosition = bitmap.parent.localToGlobal(oldPosition);
			bitmap.x		= newPosition.x;
			bitmap.y		= newPosition.y;
			
			rectangle.inflate(-inflateValue , -inflateValue);
			
			viewingBitmapOldBoundHere	= bitmap.getBounds(bitmap.parent);			
			viewingBitmapOldBound		= viewingBitmapOldBoundHere.clone();
			viewingBitmapOldBound.x		= oldPosition.x;
			viewingBitmapOldBound.y		= oldPosition.y;
						
			addChildAt(bitmap , 0)
			addChildAt(blackCover , 0);;
			parentRef.addChild(this);
			
			Tweener.addTween(blackCover , {time:0.3 , alpha:1});
			zoomInBitmap(bitmap , isSample);
			
			dispatchEvent(new Event('viewStarted'));			
		}		
		
		//	zoom in a bitmap , we caculate two bounds <fullSizeeBound> and <fullStageSizeBound> here , and use fullStageSizeBound to zoom in here
		//	fullSize bound is used when excuteFullSize is excuted
		//	in end of this function , dispatch 'zoomIn' event
		public function zoomInBitmap(bitmap:Bitmap , isSample:Boolean = false):void
		{
			var rectangle			= new Rectangle(0 , 0  , parentRef.stage.stageWidth , parentRef.stage.stageHeight);
			rectangle.inflate(-inflateValue , -inflateValue);
			
			var bitmapOldWidth		= bitmap.width / bitmap.scaleX;
			var bitmapOldHeight	= bitmap.height / bitmap.scaleY;
			var bitmapRatio				= bitmapOldWidth / bitmapOldHeight;
			var stageRatio				= rectangle.width / rectangle.height;
			var targetWidth;
			var targetHeight;
			if (bitmapRatio > stageRatio) 
			{
				if (rectangle.width > bitmapOldWidth) 
				{
					targetWidth				= bitmapOldWidth;
					targetHeight			= bitmapOldHeight;
					alreadyFullSize			= true;
					enableFullSizeFunction	= false;
				}
				else
				{
					targetWidth				= rectangle.width;
					targetHeight			= bitmapOldHeight * rectangle.width / bitmapOldWidth;
					alreadyFullSize			= false;
					enableFullSizeFunction	= true;
				}
			}
			else
			{
				if (rectangle.height > bitmapOldHeight)
				{					
					targetWidth				= bitmapOldWidth;
					targetHeight			= bitmapOldHeight;
					alreadyFullSize			= true;
					enableFullSizeFunction	= false;
				}
				else
				{
					targetHeight			= rectangle.height;
					targetWidth				= bitmapOldWidth * rectangle.height / bitmapOldHeight;			
					alreadyFullSize			= false;
					enableFullSizeFunction	= true;
				}	
			}

			var targetX		= int(rectangle.x + (rectangle.width - targetWidth)/2);
			var targetY		= int(rectangle.y + (rectangle.height - targetHeight)/2);
			var targetX2	= int(rectangle.x + (rectangle.width - bitmapOldWidth)/2);
			var targetY2	= int(rectangle.y + (rectangle.height - bitmapOldHeight)/2);
			
			_fullSizeBound			= new Rectangle(targetX2 , targetY2 , bitmapOldWidth , bitmapOldHeight);
			_fullStageSizeBound		= new Rectangle(targetX , targetY , targetWidth , targetHeight);
			
			(isSample) ? Tweener.addTween(bitmap , {time:0.7 , x:targetX , y:targetY , width:targetWidth , height:targetHeight})
					   : Tweener.addTween(bitmap , {time:0.7 , x:targetX , y:targetY , width:targetWidth , height:targetHeight , onComplete:bitmapViewComplete});
			
			dispatchEvent(new Event('zoomIn'));			
		}
		
		//	when the viewingBitmap is a sample picture for the picture we are seeing , PictureArrayClip will send a new bitmap here which is the 
		//	original size picture's bitmap(called replacingBitmap here) , we use this new bitmap to replace old bitmap .
		//	but note that viewingBitmap is not destroyed , it was just hided , when undo view function flow is started , we will send it back to it's old parent and reveal it
		
		//	when raw replace work is completed , replacingBitmap is same size as viewingBitmap , which is small , call zoomInBitmap to change that
		public function replaceBitmap(bitmap:Bitmap):void
		{
			bitmap.width = viewingBitmap.width;
			bitmap.height = viewingBitmap.height;
			bitmap.x = viewingBitmap.x;
			bitmap.y = viewingBitmap.y;
			
			addChildAt(bitmap , 1);
			
			zoomInBitmap(bitmap);
			
			replacingBitmap = bitmap;
			viewingBitmap.visible = false;
		}
		
		private function bitmapViewComplete():void
		{
			blackCover.addEventListener(MouseEvent.CLICK , undoView);
			blackCover.addEventListener(MouseEvent.DOUBLE_CLICK , undoView);
			dispatchEvent(new Event('viewCompleted'));
		}
		
		//	if a picture's real size is bigger than stage (fix with inflateValue) , this function is enabled for further zoom in to full size
		public function excuteFullSize():Boolean
		{
			if (enableFullSizeFunction = false) return false;
			
			blackCover.mouseEnabled = false;
			
			if (alreadyFullSize == false) 
			{
				if (replacingBitmap != null) 
				{					
					resizeThis(replacingBitmap , _fullSizeBound , fullSizeCompleted);
				}
				else
				{		
					resizeThis(viewingBitmap , _fullSizeBound , fullSizeCompleted);
				}
			}
			else
			{
				if (replacingBitmap != null) 
				{					
					resizeThis(replacingBitmap , _fullStageSizeBound , fullSizeCompleted);
				}
				else
				{		
					resizeThis(viewingBitmap , _fullStageSizeBound , fullSizeCompleted);
				}
			}
			return true;
		}
		
		//	a resize function , for tween animation , note resizeThis , "This" is not mean FullStageViewer , but mean 
		//	the asigned target displayObject (should be viewingBitmap or replacingBitmap here)
		private function resizeThis(target:DisplayObject , bound:Rectangle , completeFunction:Function = null):void
		{
			Tweener.removeTweens(target);
			Tweener.addTween(target , {time:0.7 , x:bound.x , y:bound.y , width:bound.width , height:bound.height , onComplete:completeFunction});		
		}
		
		private function fullSizeCompleted():void
		{
			if (alreadyFullSize == true)
			{
				alreadyFullSize = false;
				blackCover.removeEventListener(MouseEvent.MOUSE_DOWN , dragBitmap);
				blackCover.addEventListener(MouseEvent.CLICK , undoView);
			}
			else
			{
				alreadyFullSize = true;
				blackCover.addEventListener(MouseEvent.MOUSE_DOWN , dragBitmap);
				blackCover.removeEventListener(MouseEvent.CLICK , undoView);
			}
			blackCover.mouseEnabled = true;
		}
		
		//	when we are in full size mode , make this drag able 
		private function dragBitmap(evt:MouseEvent):void
		{
			MouseRecorder.updatePosition(this);
			stage.addEventListener(MouseEvent.MOUSE_MOVE , stageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP , stageMouseUp);
		}
		
		private function stageMouseMove(evt:MouseEvent):void
		{
			var dPoint				= MouseRecorder.updatePosition(this);
			viewingBitmap.x			+= dPoint.x;
			viewingBitmap.y			+= dPoint.y;
			if (replacingBitmap != null)
			{
				replacingBitmap.x			+= dPoint.x;
				replacingBitmap.y			+= dPoint.y;
			}
		}
		
		private function stageMouseUp(evt:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE , stageMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP , stageMouseUp);
		}
	
		//	unde view , end works here , we tween viewingBitmap and replacingBitmap(if there is) back to sample size and position (where is was at SamplePicture)
		//	and when tween animation completed , we clear stuffs here , send viewingBitmap to its old parent , and dispatch 'undoViewCompleted' event
		public function undoView(evt:MouseEvent = null):void
		{
			blackCover.removeEventListener(MouseEvent.CLICK , undoView);
			blackCover.removeEventListener(MouseEvent.DOUBLE_CLICK , undoView);
			
			Tweener.addTween(blackCover , {time:0.3 , alpha:0});
			Tweener.addTween(viewingBitmap , {time:0.7 , x:viewingBitmapOldBoundHere.x , y:viewingBitmapOldBoundHere.y
							 , width:viewingBitmapOldBoundHere.width , height:viewingBitmapOldBoundHere.height , onComplete:undoViewComplete});
			if (replacingBitmap)
			{
				Tweener.addTween(replacingBitmap , {time:0.7 , x:viewingBitmapOldBoundHere.x , y:viewingBitmapOldBoundHere.y
								 , width:viewingBitmapOldBoundHere.width , height:viewingBitmapOldBoundHere.height});				
			}

			dispatchEvent(new Event('undoViewStarted'));
		}
		
		private function undoViewComplete():void
		{
			removeChild(blackCover);
			viewingBitmapOldParent.addChild(viewingBitmap);
			viewingBitmap.x = viewingBitmapOldBound.x;
			viewingBitmap.y = viewingBitmapOldBound.y;
			viewingBitmap.visible = true;			
			viewingBitmap = null;
			
			if (replacingBitmap) 
			{
				Tweener.removeTweens(replacingBitmap);
				removeChild(replacingBitmap);
				replacingBitmap = null;
			}
			
			isActive = false;
			dispatchEvent(new Event('undoViewCompleted'));
		}
		
		//	if LoadingIcon is used in PictureArrayClip , a icon anime will be send here for telling user we are loading (loading the original size picture)
		public function addLoadingIcon(loadingIcon:DisplayObjectContainer):void
		{
			loadingIcon.name	= 'aLoadingIcon';
			loadingIcon.x		= parentRef.stage.stageWidth / 2;
			loadingIcon.y		= parentRef.stage.stageHeight / 2;
			addChild(loadingIcon);			
		}
		
		public function removeLoadingIcon():void
		{
			removeChild(getChildByName('aLoadingIcon'));
		}
		
		//	When stage resize event happening , call this function for necessary changes
		public function excuteResize():void
		{
			if (blackCover)
			{
				blackCover.graphics.clear();
				blackCover.graphics.beginFill(0x000000 , 0.5);
				blackCover.graphics.drawRect(0 , 0 , parentRef.stage.stageWidth , parentRef.stage.stageHeight);				
			}
			if (viewingBitmap) zoomInBitmap(viewingBitmap);
			if (replacingBitmap) zoomInBitmap(replacingBitmap);
		}
		
		//	Don't .... oh....no ........ please .....Orz......
		public function destroy():void
		{
			if (viewingBitmap) viewingBitmap.bitmapData.dispose();
			if (replacingBitmap) replacingBitmap.bitmapData.dispose();
		}		
	}
}