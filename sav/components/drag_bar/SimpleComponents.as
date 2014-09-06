package sav.components.drag_bar 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author sav
	 */
	public class SimpleComponents extends Sprite
	{
		public function SimpleComponents():void
		{
			_dragBar = new Sprite();
			addChild(_dragBar);
		}
		
		public function draw():void
		{
			var rc:Number = _baseHeight;
			
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(_baseColor);
			g.drawRoundRect(0, 0, _baseWidth, _baseHeight, rc, rc);
			g.endFill();
			
			g = _dragBar.graphics;
			g.clear();
			g.beginFill(_dragBarColor);
			g.drawRoundRect(0, 0, _dragBarWidth, _baseHeight, rc, rc);
			g.endFill();
		}
		
		/************************
		*         params
		************************/
		public function get minX():Number { return 0; }
		public function get maxX():Number { return _baseWidth - _dragBarWidth; }
		
		private var _baseColor:int = 0x000000;
		private var _dragBarColor:int = 0xffffff;
		
		private var _baseWidth:Number = 200;
		private var _baseHeight:Number = 20;
		
		private var _dragBarWidth:Number = 60;
		
		private var _dragBar:Sprite; public function get dragBar():Sprite { return _dragBar; }
	}

}