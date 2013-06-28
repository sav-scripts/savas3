/******************************************************************************************************************
	This is a stand-alone class for browse pictures , it use SamplePicture and FullStageViewer as it's child class
	
	This only work with xml picture index .
	
	For build this class :
		(1) Declare it with a Scroller , clipWidth and clipHeight is set to 500 x 400 if not declared
		(2)	resetParams , default value is set in params area . (this step is not necessary if you don't wana change anything)
		(3)	call loadPicturesFromXML method with a xml , will make this start working .
	
*******************************************************************************************************************/
package sav.components
{
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.filters.DropShadowFilter;
	
	import caurina.transitions.Tweener;
	
	import sav.data.Resources;
	import sav.components.sub_PictureArrayClip.SamplePicture;
	import sav.components.FullStageViewer;
	
	public class PictureArrayClip extends Sprite
	{
		private var sampleWidth				:uint = 110;
		private var sampleHeight			:uint = 110;
		private var sampleGapWidth			:uint = 10;
		private var sampleGapHeight			:uint = 10
		private var clipWidth				:uint = 500;
		private var clipHeight				:uint = 400;
				
		private var resources				:Resources;
		private var focusResources			:Resources;
		private var LoadingIconClass		:Class;
		private var maskShape				:Shape;
		private var sampleSprite			:Sprite;
		private var lastSampleLoaded		:Sprite;
		private var pictureArray			:Array;
		private var indexArray				:Array;		
		private var focusingObject			:Object;
		
		public var fullStageViewer			:FullStageViewer;
		public var scroller					:Scroller;
		
		public function get currentPicturePath():String
		{
			return focusingObject.path;
		}
		
		//	constructor , Scroller is necessary for this , also you can provide it a lic(LoadingIconClass) , which will be used for building loading icon when pictures is loading
		public function PictureArrayClip(s:Scroller , cw:uint = 500 , ch:uint = 400 , lic:Class = null)
		{
			scroller				= s;
			LoadingIconClass		= lic;
			
			resetParams({clipWidth:cw , clipHeight:ch} , false);
			init();
		}
		
		
		public function init():void
		{
			pictureArray		= [];
			indexArray			= [];
			resources			= new Resources();
			focusResources		= new Resources();
			maskShape			= new Shape();
			sampleSprite		= new Sprite();
			sampleSprite.mask	= maskShape;
			scroller.bindWith(this.sampleSprite);
			fullStageViewer		= new FullStageViewer();
			addChild(maskShape);
			addChild(sampleSprite);
			
			resources.addEventListener(Resources.COMPLETE,loadCompleteHandler);
			resources.addEventListener(Resources.START_NEW_MISSION , startNewMissionHandler);
			resources.addEventListener(Resources.SINGLE_MISSION_COMPLETED , singleMissionCompletedHandler);
			//resources.addEventListener(Resources.MISSION_PROGRESS , loadingProgressHandler);
			focusResources.addEventListener(Resources.COMPLETE,focusResourcesComplete);
		}
		
		//	assign params to this class , if arrangeAfter is true , pictureArrayClip will arrange all samplePictures after
		public function resetParams(params:Object , arrangeAfter:Boolean = false):void
		{
			sampleWidth				= (params.sampleWidth != undefined) ? params.sampleWidth			: sampleWidth;
			sampleHeight			= (params.sampleHeight != undefined) ? params.sampleHeight			: sampleHeight;
			sampleGapWidth			= (params.sampleGapWidth != undefined) ? params.sampleGapWidth		: sampleGapWidth;
			sampleGapHeight			= (params.sampleGapHeight != undefined) ? params.sampleGapHeight	: sampleGapHeight;
			clipWidth				= (params.clipWidth != undefined) ? params.clipWidth				: clipWidth;
			clipHeight				= (params.clipHeight != undefined) ? params.clipHeight				: clipHeight;
			
			if (arrangeAfter) arrange();
		}
		
		//	arrange sample pictures , if redrawMaskAndSort is true , mask will be redrawed and reset Scroller .
		public function arrange(redrawMaskAndSort:Boolean = true):void
		{			
			var gapW			= (sampleWidth + sampleGapWidth);
			var gapH			= (sampleHeight + sampleGapHeight);
			var numLines		= int((clipWidth - sampleGapWidth) / gapW);
			var numRows			= int((clipHeight - sampleGapHeight) / gapH);
			var startX			= int((clipWidth - gapW * numLines - sampleGapWidth) / 2) + sampleGapWidth;
			//var startY			= int((clipHeight - gapH * numRows - sampleGapHeight) / 2) + sampleGapHeight;
			var startY			= 1;
			
			
			if (redrawMaskAndSort)
			{
				maskShape.graphics.clear();
				maskShape.graphics.beginFill(0xff0000);
				maskShape.graphics.drawRect(0,0,clipWidth,clipHeight);
				
				for (var i=0;i<indexArray.length;i++)
				{
					var line			= i % numLines;
					var row				= int(i / numLines);
					var path			= indexArray[i];
					var object			= pictureArray[path];
					object.samplePicture.x		= startX + line * gapW;
					object.samplePicture.y		= startY + row * gapH;
				}
				scroller.resetToMin();
			}
			
			
			if (lastSampleLoaded) // < this is a SamplePicture , not a Boolean
			{
				var targetHeight = lastSampleLoaded.y + sampleHeight;
				
				sampleSprite.graphics.clear();
				sampleSprite.graphics.lineStyle(1 , 0xff0000 , 0);   
				sampleSprite.graphics.drawRect(0,0,10,targetHeight);   //scroller use this for caculate dragable area
			}	
			
			scroller.updateDragArea();		
		}
		
		//	load pictures from a xml , each pictures mission we build a object to contain infos , and stop in pictureArray(is a object) , indexArray for index picureArray
		public function loadPicturesFromXML(xml:XML):void
		{
			pictureArray		= [];
			indexArray			= [];
			
			var pictureMasterPath	= String(xml.pictureMasterPath);
			var sampleMasterPath	= String(xml.sampleMasterPath);
			
			for each(var file in xml.file) 
			{
				var object							= {};
				object.path							= (String(file.@ignoreMasterPath) == 'true')
													  ? String(file.@path) : pictureMasterPath + String(file.@path);
				object.hasSample					= (String(file.@samplePath) == '') ? false : true;
				object.samplePath					= sampleMasterPath + String(file.@samplePath);				
				var loadingPath						= (object.hasSample) ? object.samplePath : object.path;
				object.samplePicture				= new SamplePicture(showPicture , loadingPath);
				
				sampleSprite.addChild(object.samplePicture);								
				indexArray.push(loadingPath);
				pictureArray[loadingPath] = object;
				
				resources.addMission(Resources.PICTURE , loadingPath , loadingPath);
			}
			
			arrange();
			
			resources.startLoading();
		}
		
		private function loadCompleteHandler(evt:Event):void
		{
			dispatchEvent(new Event('allPicturesLoaded'));
		}
		
		//	if there is LoadingIconClass assigned from constructor , build a icon for loading displaying
		private function startNewMissionHandler(evt:Event):void
		{
			if (LoadingIconClass != null)
			{
				var path				= resources.currentMissionName;
				var object				= pictureArray[path];
				
				var sampleLoadingIcon	= new LoadingIconClass();
				sampleLoadingIcon.x		= sampleWidth / 2;
				sampleLoadingIcon.y		= sampleHeight / 2;
				sampleLoadingIcon.name	= 'aLoadingIcon';
				object.samplePicture.addChild(sampleLoadingIcon);
			}
		}
		
		//	a picture is loaded , resize it , and assign it to it's samplePicture , also , we give filters for enchant displaying
		private function singleMissionCompletedHandler(evt:Event):void
		{			
			var path			= resources.currentMissionName;
			var loaderInfo 		= resources.getPack(path);
			var object			= pictureArray[path];			
			
			var bitmap			= loaderInfo.content;
			resizeSampleBitmap(bitmap);
			bitmap.x			= int((sampleWidth - bitmap.width) /2);
			bitmap.y			= int((sampleHeight - bitmap.height) /2);
			var whileLine		= new GlowFilter(0xffffff , 1 , 4 , 4 , 6 , 1 , true);
			var shadow			= new DropShadowFilter(2 , 45 , 0 , 0.5);
			bitmap.filters		= [whileLine , shadow];
			
			if (LoadingIconClass != null) object.samplePicture.removeChild(object.samplePicture.getChildByName('aLoadingIcon'));
			object.samplePicture.myBitmap = bitmap;
			object.samplePicture.activeInteractive();
			
			lastSampleLoaded = object.samplePicture;
			arrange(false);
		}
		
		//	resize oldBitmap fit it to sampleWidth and sampleHeight
		private function resizeSampleBitmap(oldBitmap:Bitmap):void
		{
			var newWidth , newHeight;
			var rawRatio		= oldBitmap.width / oldBitmap.height;
			var sampleRatio		= sampleWidth / sampleHeight;
			
			if (rawRatio > sampleRatio)
			{
				newWidth		= sampleWidth;
				newHeight		= oldBitmap.height * sampleWidth / oldBitmap.width;
			}
			else
			{
				newHeight		= sampleHeight;
				newWidth		= oldBitmap.width * sampleHeight / oldBitmap.height;
			}
			
			oldBitmap.width = newWidth;
			oldBitmap.height = newHeight;
			oldBitmap.smoothing = true;
		}
		
		//	this function is called when samplePicture is clicked 
		//	if the clicked picture is a sample picture , tell focusResrouces to load the full size picture , when that picture is loaded , 
		//	let fullStageViewer replace it with samplePicure and excute zoomIn to fullStageSize
		public function showPicture(loadingPath:String):void
		{
			scroller.enableMouseWheel = false;
			
			var object = pictureArray[loadingPath];
			focusingObject = object;
			
			var blurFilter				= new BlurFilter(5 , 5);
			sampleSprite.filters		= [blurFilter];
			sampleSprite.mouseChildren	= false;
			fullStageViewer.parentRef	= this.stage;
			fullStageViewer.viewBitmap(object.samplePicture.myBitmap , object.hasSample);
			fullStageViewer.addEventListener('undoViewCompleted' , undoViewCompleted);
			fullStageViewer.addEventListener('undoViewStarted' , undoViewStarted);
				
			if (object.hasSample == true)
			{
				if (object.fullSizeBitmap == undefined)
				{
					if (LoadingIconClass != null)
					{
						var sampleLoadingIcon	= new LoadingIconClass();
						fullStageViewer.addLoadingIcon(sampleLoadingIcon);
					}					
					
					focusResources.addMission(Resources.PICTURE , object.path , object.path);
					focusResources.startLoading();
				}
				else
				{					
					fullStageViewer.replaceBitmap(object.fullSizeBitmap);
				}
			}
		}
		
		private function focusResourcesComplete(evt:Event):void
		{
			if (LoadingIconClass != null) fullStageViewer.removeLoadingIcon();
			
			var loaderInfo 							= focusResources.getPack(focusResources.currentMissionName);
			focusingObject.fullSizeBitmap			= loaderInfo.content;			
			var whileLine							= new GlowFilter(0xffffff , 1 , 4 , 4 , 6 , 1 , true);
			var shadow								= new DropShadowFilter(2 , 45 , 0 , 0.5);
			focusingObject.fullSizeBitmap.filters	= [whileLine , shadow];
			focusingObject.fullSizeBitmap.smoothing = true;
			fullStageViewer.replaceBitmap(focusingObject.fullSizeBitmap);			
		}
		
		private function undoViewStarted(evt:Event):void
		{
			sampleSprite.filters = [];
			sampleSprite.mouseChildren = true;
		}
		
		private function undoViewCompleted(evt:Event):void
		{
			fullStageViewer.removeEventListener('undoViewCompleted' , undoViewCompleted);
			fullStageViewer.removeEventListener('undoViewStarted' , undoViewStarted);
			scroller.enableMouseWheel = true;
		}		
		
		// kamikazaii !!
		public function destroy():void
		{
			fullStageViewer.destroy();
			resources.destroy();
			focusResources.destroy();
			
			for each(var object in pictureArray) 
			{
				var samplePicture = object.samplePicture;
				samplePicture.destroy();
			}
			
			LoadingIconClass			= null;
			maskShape					= null;
			sampleSprite				= null;
			lastSampleLoaded			= null;
			pictureArray				= null;
			indexArray					= null;
			focusingObject				= null;		
			fullStageViewer				= null;
			scroller					= null;
			resources					= null;
			focusResources				= null;
			
		}
	}
}