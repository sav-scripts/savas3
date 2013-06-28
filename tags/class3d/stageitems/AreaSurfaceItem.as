package sav.class3d.stageitems
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.events.MouseEvent;
	import flash.display.BitmapData;
	
	import sandy.core.scenegraph.Sprite2D;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	
	import sav.class3d.materials.MovieMaterialsForFaces;
	import sav.game.McEffecter;
	
	public class AreaSurfaceItem extends Sprite2D
	{
		public var movieClipItem				:MovieClip;
		public var myArea						:Area;
		public var currentDirection				:String = 'right';
		public var objectData					:Object;
		public var distanceToFocusPoint			:Number;
		
		public var interactiveOn				:Boolean = false;
		public var button						:Sprite;
		
		public function AreaSurfaceItem(MovieClass:Class , theName:String)		
		{	
			movieClipItem					= new MovieClass();			
			movieClipItem.mouseEnabled		= false;
			
			movieClipItem.cacheAsBitmap = true;
			super(theName,movieClipItem);
			
			autoCenter = false;
			container.mouseEnabled = false;
			var bitmapMaterial:BitmapMaterial = new BitmapMaterial(new BitmapData(100,100,false,0xffffff));
			this.material = bitmapMaterial;
		}
		
		public function changeFacingSide(direction:String):void
		{
			currentDirection = direction;
			if (direction == 'right')
			{
				movieClipItem.scaleX = 1;
			}
			else
			{
				movieClipItem.scaleX = -1;
			}			
		}
		
		public function applyOutline():void
		{					
			var glowFilter = new GlowFilter(0x000000,1,2,2,2);
			var filterArray = [glowFilter];			
			movieClipItem.filters = filterArray;
		}
		
		public function activeInteractive(w:uint = 100 , h:uint = 50):void
		{
			//var HitArea = Config.main.resources.getClass('HitArea' , 'ObjectPack');
			//var button = new HitArea();
			if (interactiveOn == false)
			{
				interactiveOn = true;
				button = new Sprite();
				button.graphics.beginFill(0xff0000 , 0);
				button.graphics.drawRect(-w/2 , -h/2 , w , h);
				button.useHandCursor = true;
				button.addEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
				button.addEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
				button.addEventListener(MouseEvent.CLICK , clickHandler);
				
				button.buttonMode = true;
				button.mouseEnabled = true;			
				container.mouseChildren = true;
				
				container.addChild(button);
			}
		}
		
		public function disactiveInteractive():void
		{
			if (interactiveOn == true)
			{
				interactiveOn = false;	
				container.mouseChildren = false;
				
				button.removeEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
				button.removeEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
				button.removeEventListener(MouseEvent.CLICK , clickHandler);
				
				container.removeChild(button);		
				button = null;
			}
		}
		
		public function mouseOverHandler(evt:MouseEvent = null):void
		{
			focusThis();
		}
		
		public function mouseOutHandler(evt:MouseEvent = null):void
		{
			undoFocus();
		}
		
		public function clickHandler(evt:MouseEvent = null):void
		{
		}
		
		private function focusThis():void
		{
			McEffecter.addFlash(container , {time:0.2 , percent:0.6 , removeAfter:false});
		}
		
		private function undoFocus():void
		{
			McEffecter.removeFlash(container);
		}
		
		override public function destroy():void
		{
			disactiveInteractive();
			movieClipItem = null;
			myArea = null;
			objectData = null;
			alwaysRenderThis = false;
			
			super.destroy();
		}		
	}
}