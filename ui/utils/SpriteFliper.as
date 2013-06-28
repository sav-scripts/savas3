package sav.ui.utils
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	public class SpriteFliper extends PlaneFliper
	{
		public var source:Sprite;
		
		public function SpriteFliper(sprite:Sprite, params:Object = null)
		{
			source = sprite;
			var bound:Rectangle = source.getBounds(source);
			
			var bitmapData:BitmapData = new BitmapData(bound.width, bound.height, true, 0);
			var matrix:Matrix = new Matrix();
			matrix.translate(-bound.left, -bound.top);
			bitmapData.draw(sprite, matrix, null, null, null, true);
			
			super(bitmapData, params);
		}
		
		public function replaceSource():void
		{
			if (!source.parent) throw new Error("Source doesn't have parent");
			
			var p:DisplayObjectContainer = source.parent;
			var bound:Rectangle = source.getBounds(source);
			
			var index:int = p.getChildIndex(source);
			planeLayer.x = bound.left;
			planeLayer.y = bound.top;
			
			p.addChildAt(this, index);
			p.removeChild(source);
			
			this.transform.matrix = source.transform.matrix;
			this.transform.colorTransform = source.transform.colorTransform;
		}
		
		public function recoverSource():void
		{
			if (!parent) throw new Error("Doesn't have parent, can't replace source back");
			var p:DisplayObjectContainer = parent;
			
			var index:int = p.getChildIndex(this);
			p.addChildAt(source, index);
			
			p.removeChild(this);
		}
		
		override public function destroy():void 
		{
			source = null;
			super.destroy();
		}
	}
}