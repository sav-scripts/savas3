package sav.scene.tween
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[Event(name = 'complete', type = 'flash.events.Event')]
	
	public class CircleTween extends EventDispatcher
	{		
		public function CircleTween(
			container:DisplayObjectContainer, maskedSprite:Sprite = null, 
			coverWidth:Number = Number.NaN, coverHeight:Number =  Number.NaN, 
			startFromTop:Boolean = true)
		{
			if (!container.stage) throw new Error('container must on stage');
			this.container = container;
			this.stage = container.stage;
			this.maskedSprite = maskedSprite;
			this.coverWidth = (isNaN(coverWidth) == true) ? this.stage.stageWidth : coverWidth;
			this.coverHeight = (isNaN(coverHeight) == true) ? this.stage.stageHeight : coverHeight;
			
			_startFromTop = startFromTop;
			
			currentStates = IDDLE;
			
			buildSprites();
			buildCells();
		}
		
		private function buildSprites():void
		{	
			if (maskedSprite == null)
			{
				maskedSpriteWasNull = true;
				maskedSprite = new Sprite();
				var g:Graphics = maskedSprite.graphics;
				g.beginFill(0x000000);
				g.drawRect(0, 0, coverWidth, coverHeight);
				g.endFill();
			}
			
			maskSprite = new Sprite();
			
			maskedSprite.mask = maskSprite;
		}
		
		private function buildCells():void
		{
			while (maskSprite.numChildren > 0) maskSprite.removeChildAt(0);
			
			numLines = coverWidth / cellWidth + 1;
			numRows = coverHeight / cellHeight + 1;
			
			var rect:Rectangle = new Rectangle(0, 0, numLines * cellWidth, numRows * cellHeight);
			rect.offset((coverWidth - rect.width) / 2, (coverHeight - rect.height) / 2);
			
			var pen:Point = new Point(rect.x + cellWidth / 2, rect.y + cellHeight / 2);
			
			cellArray = [];
			
			var startRow:int = (_startFromTop) ? 0 : numRows-1;
			var endRow:int = (_startFromTop) ? numRows : -1;
			var dRow:int = (_startFromTop) ? 1 : -1;
			
			row = startRow;
			
			do
			{
				cellArray[row] = [];
				for (line = 0; line < numLines; line++)
				{
					var shape:Shape = new Shape();
					var g:Graphics = shape.graphics;
					g.beginFill(0);
					g.drawCircle(0, 0, cellWidth);
					g.endFill();
					shape.x = pen.x;
					shape.y = pen.y;
					
					cellArray[row][line] = shape;	
					
					maskSprite.addChild(shape);
					
					pen.offset(cellWidth, 0);
				}
				pen.offset( -cellWidth * numLines, cellHeight);
				
				row += dRow;
			} while (row != endRow);	
		}
		
		public function resize(coverWidth:Number, coverHeight:Number, cellWidth:Number = Number.NaN, cellHeight:Number = Number.NaN):void
		{
			this.coverWidth = coverWidth;
			this.coverHeight = coverHeight;
			if (!isNaN(cellWidth)) this.cellWidth = cellWidth;
			if (!isNaN(cellHeight)) this.cellHeight = cellHeight;
			
			if (maskedSpriteWasNull)
			{
				var g:Graphics = maskedSprite.graphics;
				g.clear();
				g.beginFill(0x000000);
				g.drawRect(0, 0, coverWidth, coverHeight);
				g.endFill();
			}
			
			buildCells();
		}
		
		public function start(fadeType:String = 'fadeIn'):void
		{
			if (currentStates == FADING_IN || currentStates == FADING_OUT) throw new Error('Scene tween already started');
			currentStates = (fadeType == FADE_IN) ? FADING_IN : FADING_OUT;
			
			container.addChild(maskedSprite);
			container.addChild(maskSprite);
			
			var startScale:Number = (fadeType == FADE_IN) ? 0 : 0.8;
			var endScale:Number = (fadeType == FADE_IN) ? 0.8 : 0;			
			
			var delay:Number = 0, shape:Shape;			
			var lineDelay:Array = [];			
			for (line = 0; line < numLines; line++) lineDelay[line] = 0;
			
			for (row = 0; row < numRows; row++)
			{
				for (line = 0; line < numLines; line++)
				{
					lineDelay[line] += Math.random() / 10;
					shape = cellArray[row][line];
					
					shape.scaleX = shape.scaleY = startScale;
					
					Tweener.addTween(shape, { delay:(delay+lineDelay[line]), time:0.5, scaleX:endScale, scaleY:endScale, transition:'linear'} );
				}
				delay += 0.05;
			}
			lineDelay.sort(Array.NUMERIC | Array.DESCENDING);
			Tweener.addTween(maskedSprite, { delay:(delay + lineDelay[0]), time:0.3, onComplete:complete } );			
		}
		
		private function complete():void
		{
			currentStates = (currentStates == FADING_IN) ? FADED_IN : FADED_OUT;
			if (currentStates == FADED_OUT)
			{
				if (maskSprite.parent) maskSprite.parent.removeChild(maskSprite);
				if (maskedSprite.parent) maskedSprite.parent.removeChild(maskedSprite);
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function destroy():void
		{
			if (maskSprite.parent) maskSprite.parent.removeChild(maskSprite);
			if (maskedSpriteWasNull) container.removeChild(maskedSprite);
			
			container = null;
			stage = null;
			maskedSprite.mask = null;
			maskedSprite = null;
			maskSprite = null;
			
			cellArray = null;
		}
		
		public static const FADE_IN:String = 'fadeIn';
		public static const FADE_OUT:String = 'fadeOut';
		
		private var container:DisplayObjectContainer;
		private var stage:Stage;
		private var maskedSprite:Sprite;
		private var maskSprite:Sprite;
		
		private var maskedSpriteWasNull:Boolean = false;
		
		private var coverWidth:Number;
		private var coverHeight:Number;
		public function get width():Number { return coverWidth; }
		public function get height():Number { return coverHeight; }
		
		private var cellArray:Array;
		
		private var numLines:uint;
		private var numRows:uint;
		private var line:int;
		private var row:int;
		
		private var cellWidth:Number = 50;
		private var cellHeight:Number = 50;
		
		private var _startFromTop:Boolean;
		
		private var started:Boolean = false;
		
		private var currentStates:String = IDDLE;
		public function get states():String { return currentStates; }
		
		public static const IDDLE:String = 'iddle';
		public static const FADING_IN:String = 'fadingIn';
		public static const FADING_OUT:String = 'fadingOut';
		public static const FADED_IN:String = 'fadedIn';
		public static const FADED_OUT:String = 'fadedOut';
	}
}