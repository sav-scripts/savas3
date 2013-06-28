package sav.game.map.for_test
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import sav.game.map.prototype.MapNode;

	public class CirclePoint extends Sprite
	{
		public function CirclePoint(radius:Number = 5):void
		{
			_radius = radius;
			buttonMode = useHandCursor = true;
			selected = false;
		}
		
		protected var _selected:Boolean = true;
		public function get selected():Boolean { return _selected; }
		public function set selected(b:Boolean):void
		{
			if (b == _selected) return;
			_selected = b;
			
			var g:Graphics = this.graphics;
			g.clear();
			//g.lineStyle(2, 0x7891E7);
			g.lineStyle(2, 0x333333);
			(_selected) ? g.beginFill(0) : g.beginFill(0xcccccc);
			g.drawCircle(0, 0, _radius);
		}
		
		/************************
		*         params
		************************/
		protected var _radius:Number;
		public var node:MapNode;
	}
}