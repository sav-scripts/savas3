package sav.components
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import br.com.stimuli.loading.loadingtypes.VideoItem;
	import caurina.transitions.properties.DisplayShortcuts;
	import caurina.transitions.Tweener;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.navigateToURL;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	
	public class ADVShow extends Sprite
	{
		public static const	ADV_HIDDEN	:String = 'advHidden';
		
		private var xmlAdress			:String;
		private var advList				:XMLList;
		private var currentIndex		:int;
		private var currentAdvUrl		:String;
		private var currentAdvType		:String;
		private var advBound			:Rectangle;
		private var loader				:BulkLoader;
		private var netStream			:NetStream;
		private var video				:Video;
		private var blackCover			:Sprite;
		private var adv					:DisplayObject;
		private var hyperLinkButton		:SimpleButton;
		private var closeButton			:CloseButton;
		
		private var _states				:String = ADVStates.INITING;
		public function get states()	:String { return _states; }
		
		public var useCover				:Boolean = true;
		public var coverColor			:Number = 0x000000;
		public var coverAlpha			:Number = 0.5;
		
		public function ADVShow(xmlAdress:String , boundWidth:Number , boundHeight:Number)
		{
			this.xmlAdress = xmlAdress;
			advBound = new Rectangle(0, 0, boundWidth, boundHeight);
		}
		
		public function init():void
		{
			currentIndex = -1;
			
			loader = new BulkLoader();
			loader.add(xmlAdress);
			
			loader.addEventListener(BulkProgressEvent.COMPLETE , advXmlLoaded);
			loader.addEventListener(BulkLoader.ERROR , errorHandler);
			loader.start();
			
			closeButton = new CloseButton();
			closeButton.addEventListener(MouseEvent.CLICK , hideThisAdv);
		}
		
		
		private function advXmlLoaded(evt:BulkProgressEvent):void
		{
			loader.removeEventListener(BulkProgressEvent.COMPLETE , advXmlLoaded);	
			loader.addEventListener(BulkProgressEvent.COMPLETE , nextAdvLoaded);
			
			var xml:XML = loader.getXML(xmlAdress , true);
			advList = xml.adv;
			prepareNext();
		}
		
		private function errorHandler(evt:Event):void
		{
			trace('ERROR' + evt);
			_states = ADVStates.ERROR;
		}
		
		public function prepareNext():void
		{						
			currentIndex = (currentIndex == (advList.length() - 1)) ? 0 : currentIndex + 1;
			_states = ADVStates.LOADING;
			
			currentAdvUrl = String(advList[currentIndex].@url);			
			currentAdvType = loader.add(currentAdvUrl , {pausedAtStart:true}).type;
			loader.start();
		}
		
		private function nextAdvLoaded(evt:BulkProgressEvent):void
		{
			_states = ADVStates.READY;
		}
		
		public function show():void
		{
			useCover = (String(advList[currentIndex].@useCover) == 'false') ? false : true;
			if (useCover) 
			{
				makeBlackCover();
			}
			else
			{
				makeBlackCover(0,0);
			}
		}
		
		private function makeAdv():void
		{
			trace('Showing a ' + currentAdvType + ' file.');
			
			adv = this[currentAdvType + 'Show']();
			adv.alpha = 0;
			Tweener.addTween(adv ,{time:0.5 , alpha:1 } );
			
			var hyperLink:String = String(advList[currentIndex].@hyperLink);
			if (hyperLink != '')
			{
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0x000000);
				shape.graphics.drawRect(0, 0, adv.width, adv.height);
				hyperLinkButton = new SimpleButton();
				hyperLinkButton.hitTestState = shape;
				hyperLinkButton.x = adv.x;
				hyperLinkButton.y = adv.y;
				addChild(hyperLinkButton);
				
				hyperLinkButton.addEventListener(MouseEvent.CLICK , advClicked);
			}
			closeButton.x = advBound.right;
			closeButton.y = advBound.top;
			this.addChild(closeButton);
			
			_states = ADVStates.SHOWING;
		}
		
		private function advClicked(evt:MouseEvent):void
		{
			var hyperLink:String = String(advList[currentIndex].@hyperLink);
			navigateToURL(new URLRequest(hyperLink));
		}
		
		private function makeBlackCover(fadeInTime:Number = 0.6 , tweenTargetAlpha:Number = 1):void
		{
			blackCover = new Sprite();
			blackCover.graphics.beginFill(coverColor , coverAlpha);
			blackCover.graphics.drawRect(0, 0, advBound.width, advBound.height);
			blackCover.alpha = 0;
			blackCover.addEventListener(MouseEvent.CLICK , hideThisAdv);
			this.addChild(blackCover);
			Tweener.addTween(blackCover , { time:fadeInTime , alpha:tweenTargetAlpha, onComplete:makeAdv } );
		}
		
		private function hideThisAdv(evt:MouseEvent):void
		{
			hide();
		}		
		
		private function imageShow():Bitmap
		{
			var bitmap:Bitmap = loader.getContent(currentAdvUrl);
			
			bitmap.smoothing = true;			
			bitmap.x = int(advBound.x + (advBound.width - bitmap.width) / 2);
			bitmap.y = int(advBound.y + (advBound.height - bitmap.height) / 2);
			addChild(bitmap);
			
			return bitmap;
		}
		
		private function movieclipShow():MovieClip
		{
			var movieClip:MovieClip = loader.getMovieClip(currentAdvUrl);
			
			movieClip.x = int(advBound.x + (advBound.width - movieClip.width) / 2);
			movieClip.y = int(advBound.y + (advBound.height - movieClip.height) / 2);
			movieClip.mouseEnabled = false;
			movieClip.play();
			addChild(movieClip);
			
			return movieClip;
		}
		
		private function videoShow():Video
		{
			netStream = loader.getNetStream(currentAdvUrl);
			video = new Video();
			video.attachNetStream(netStream);
			addChild(video);
			
			netStream.client.onMetaData = onMetaData;
			netStream.play(currentAdvUrl);
			
			return video;
		}
		
		private function onMetaData(info:Object):void
		{
			video.width = video.videoWidth;
			video.height = video.videoHeight;
			
			video.x = int(advBound.x + (advBound.width - video.width) / 2);
			video.y = int(advBound.y + (advBound.height - video.height) / 2);			
			
			hyperLinkButton.x = video.x;
			hyperLinkButton.y = video.y;
			hyperLinkButton.hitTestState.width = video.width;
			hyperLinkButton.hitTestState.height = video.height;			
		}
		
		public function hide():void
		{
			closeButton.mouseEnabled = false;
			if (hyperLinkButton)
			{
				hyperLinkButton.removeEventListener(MouseEvent.CLICK , advClicked);
				hyperLinkButton = null;
			}
			
			if (blackCover)
			{
				blackCover.removeEventListener(MouseEvent.CLICK , hideThisAdv);
				blackCover = null;
			}
			
			loader.remove(currentAdvUrl);	
			
			Tweener.addTween(this , { time:0.5 , alpha:0 , onComplete:clearDisplayObjects} );
			
		}
		
		private function clearDisplayObjects():void
		{			
			while (numChildren > 0) 
			{
				var object:* = removeChildAt(0);
				Tweener.removeTweens(object);
				if (object == video)
				{
					netStream.close();
					netStream = null;
					video = null;
				}
				else if (object is Bitmap)
				{
					object.bitmapData.dispose();
				}
			}		
			_states = ADVStates.HIDING;
			this.alpha = 1;
			closeButton.mouseEnabled = true;
			
			dispatchEvent(new Event(ADV_HIDDEN));
		}
	}
}

import flash.display.SimpleButton;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;

class CloseButton extends SimpleButton
{
	private var spring:Number = 0.3;
	private var friction:Number = 0.8;
	private var vr:Number = 0;
	
	public function CloseButton() 
	{
		var shape1:Shape = new Shape();
		drawShape(shape1, 0x222222, 0xcccccc);
		var shape2:Shape = new Shape();
		drawShape(shape2, 0x000000, 0xffffff);
		var shape3:Shape = new Shape();
		shape3.graphics.beginFill(0xff0000);
		shape3.graphics.drawCircle(0, 0, 40);
		shape3.graphics.endFill();
		
		this.filters = [new GlowFilter(0x000000, 1, 7, 7, 1)];
		
		this.upState = shape1;
		this.overState = this.downState = shape2;
		this.hitTestState = shape3;
		
		this.addEventListener(MouseEvent.MOUSE_OVER , shakeButton);
		this.addEventListener(MouseEvent.MOUSE_OUT , stopShake);
	}
	
	private function shakeButton(evt:MouseEvent):void
	{
		this.addEventListener(Event.ENTER_FRAME , changeRotation);
		this.overState.rotation = -45;
		vr = 0;
	}
	
	private function changeRotation(evt:Event):void
	{
		var dr:Number = 0 - this.overState.rotation;
		var ar:Number = dr * spring;
		vr += ar;
		vr *= friction;
		
		this.overState.rotation += vr;
		
		if (Math.abs(vr) < 0.3)
		{
			this.overState.rotation = 0;
			this.removeEventListener(Event.ENTER_FRAME , changeRotation);
		}
	}
	
	private function stopShake(evt:MouseEvent):void
	{
		this.removeEventListener(Event.ENTER_FRAME , changeRotation);
		this.overState.rotation = 0;
	}
	
	private function drawShape(shape:Shape , fillColor:Number=0x000000 , xColor:Number = 0xcccccc):void
	{
		var d1:Number = 10;
		var d2:Number = d1 * 2;
		var d3:Number = d1 * 3;
		var xSize:Number = 8;
		
		shape.graphics.beginFill(fillColor , 0.8);	
		shape.graphics.lineStyle(1 , 0);		
		shape.graphics.moveTo( -d1 , 0);
		shape.graphics.curveTo( -d1 , d1 , -d2 , d1);
		shape.graphics.curveTo( -d3, d1, -d3, d2);
		shape.graphics.curveTo( -d3, d3, -d2, d3);
		shape.graphics.curveTo( -d1, d3, -d1, d2);
		shape.graphics.curveTo( -d1, d1, 0, d1);		
		shape.graphics.curveTo( d1, d1, d1, 0);		
		shape.graphics.curveTo( d1, -d1, 0, -d1);		
		shape.graphics.curveTo( -d1, -d1, -d1, 0);
		shape.graphics.lineTo(0, 0);
		shape.graphics.endFill();				
		
		shape.graphics.lineStyle(2 , xColor);		
		shape.graphics.moveTo(-d2 - xSize / 2 , d2 - xSize/2);
		shape.graphics.lineTo(-d2 + xSize / 2 , d2 + xSize/2);
		shape.graphics.moveTo(-d2 - xSize / 2 , d2 + xSize/2);
		shape.graphics.lineTo(-d2 + xSize / 2 , d2 - xSize/2);		
	}
}