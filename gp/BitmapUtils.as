package sav.gp
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	public class BitmapUtils
	{
		public static function resize(oldBitmapData:BitmapData , newWidth:uint , newHeight:uint , smooth:Boolean = true):BitmapData
		{
			var newBitmapData:BitmapData		= new BitmapData(newWidth , newHeight , true , 0xffffffff);
			var sx:Number						= newWidth / oldBitmapData.width;
			var sy:Number						= newHeight / oldBitmapData.height;
			var matrix:Matrix					= new Matrix(sx , 0 , 0 , sy);
			newBitmapData.draw(oldBitmapData , matrix , null , null , null , smooth);
			
			return newBitmapData;
		}
		
		public static function spriteToBitmapGraphics(sprite:Sprite, bleed:Number = 2, smooth:Boolean = false, useSelfBound:Boolean = true, cleanSource:Boolean = true, targetGraphics:Graphics = null):BitmapData
		{
			var bound:Rectangle = (useSelfBound == true) ? sprite.getBounds(sprite) : getPureBound(sprite);
			
			bound.inflate(bleed, bleed);
			
			var bitmapData:BitmapData = cacheBitmapData(sprite, bleed, smooth, useSelfBound);
			
			if (cleanSource)
			{
				while (sprite.numChildren) sprite.removeChildAt(0);
				sprite.graphics.clear();
			}
			
			var matrix:Matrix = new Matrix();
			matrix.tx = bound.x;
			matrix.ty = bound.y;
			
			if (targetGraphics == null) targetGraphics = sprite.graphics;
			
			targetGraphics.clear();
			targetGraphics.beginBitmapFill(bitmapData, matrix, false, smooth);
			targetGraphics.drawRect(bound.x, bound.y, bound.width, bound.height);
			
			return bitmapData;
		}
		
		public static function cacheBitmapData(sprite:Sprite, bleed:Number = 2, smooth:Boolean = false, useSelfBound:Boolean = true):BitmapData
		{
			var bound:Rectangle;
			var bitmapData:BitmapData;
			
			if (useSelfBound)
			{
				bound = sprite.getBounds(sprite);
				bound.inflate(bleed, bleed);
				bound.x = Math.floor(bound.x);
				bound.y = Math.floor(bound.y);
				bound.width = Math.ceil(bound.width);
				bound.height = Math.ceil(bound.height);
				
				bitmapData = new BitmapData(bound.width, bound.height, true, 0x00000000);
				bitmapData.draw(sprite, new Matrix(1, 0, 0, 1, -bound.x, -bound.y), null, null, null, smooth);
			}
			else
			{
				var oldX:Number = sprite.x;
				var oldY:Number = sprite.y;
				var oldParent:DisplayObjectContainer = sprite.parent;
				var oldChildIndex:int = (oldParent != null) ? oldParent.getChildIndex(sprite) : -1;
				
				var tempParent:Sprite = new Sprite();				
				tempParent.addChild(sprite);
				sprite.x = 0;
				sprite.y = 0;
				
				bound = sprite.getBounds(tempParent);
				bound.inflate(bleed, bleed);
				bound.x = Math.floor(bound.x);
				bound.y = Math.floor(bound.y);
				bound.width = Math.ceil(bound.width);
				bound.height = Math.ceil(bound.height);
				
				bitmapData = new BitmapData(bound.width, bound.height, true, 0x00000000);
				bitmapData.draw(tempParent, new Matrix(1, 0, 0, 1, -bound.x, -bound.y), null, null, null, smooth);
				
				sprite.x = oldX;
				sprite.y = oldY;
				(oldParent != null) ? oldParent.addChildAt(sprite, oldChildIndex) : tempParent.removeChild(sprite);
			}
			
			return bitmapData;
		}
		
		private static function getPureBound(sprite:Sprite):Rectangle
		{
			var oldX:Number = sprite.x;
			var oldY:Number = sprite.y;
			var oldParent:DisplayObjectContainer = sprite.parent;
			var oldChildIndex:int = (oldParent != null) ? oldParent.getChildIndex(sprite) : -1;
			
			var tempParent:Sprite = new Sprite();				
			tempParent.addChild(sprite);
			sprite.x = 0;
			sprite.y = 0;
			
			var bound:Rectangle = sprite.getBounds(tempParent);
			
			sprite.x = oldX;
			sprite.y = oldY;
			(oldParent != null) ? oldParent.addChildAt(sprite, oldChildIndex) : tempParent.removeChild(sprite);
			
			return bound;
		}
		
		public static function getBitmapFilledBitmapData(width:int, height:int, sourceBmd:BitmapData, matrix:Matrix = null, smooth:Boolean = false):BitmapData
		{
			var shape:Shape = new Shape();
			var g:Graphics = shape.graphics;
			g.beginBitmapFill(sourceBmd, matrix, true, smooth);
			g.drawRect(0, 0, width, height);
			g.endFill();
			
			var resultBmd:BitmapData = new BitmapData(width, height, true, 0x00000000);
			resultBmd.draw(shape);
			
			return resultBmd;
		}
		
		public static function getMapMask(MapEdgeBmdClass:Class, bmdBound:Rectangle, bmdBaseColor:int = 0x00000000):BitmapData
		{
			var shape:Shape = new Shape();
			var g:Graphics = shape.graphics;
			
			var bmd:BitmapData = new MapEdgeBmdClass();
			
			var bw:Number = bmd.width;
			var bh:Number = bmd.height;
			
			var bound:Rectangle = bmdBound.clone();
			
			bound.inflate( -bw-2, -bw-2);
			bound.x = int(bound.x);
			bound.y = int(bound.y);
			bound.width = int(bound.width);
			bound.height = int(bound.height);
			
			var totalLength:Number = bound.width * 2 + bound.height * 2;
			var numMapRepeats:int = int(totalLength / bh);
			var mapDensity:Number = totalLength / numMapRepeats;
			
			var vertices:Vector.<Number> = new Vector.<Number>;
			var indices:Vector.<int> = new Vector.<int>;
			var uvData:Vector.<Number> = new Vector.<Number>;
			
			var u0:Number = 0;
			var u1:Number = 0.98;
			var v0:Number = 0;
			var v1:Number = 0;
			
			var si:int = 0;
			
			var rect:Rectangle;
			rect = new Rectangle(bound.right, bound.top, bw, bound.height);
			v0 = v1;
			v1 += bound.height / bh;
			vertices.push(rect.left, rect.top, rect.right, rect.top, rect.right, rect.bottom, rect.left, rect.bottom);
			indices.push(si+0, si+1, si+3, si+1, si+2, si+3);
			uvData.push(u0, v0, u1, v0, u1, v1, u0, v1);
			si += 4;
			
			rect = new Rectangle(bound.right, bound.bottom, bw, bw);
			v0 = v1;
			v1 += bw / bh;
			vertices.push(rect.left, rect.top, rect.right, rect.top, rect.right, rect.bottom);
			indices.push(si+0, si+1, si+2);
			uvData.push(u0, v0, u1, v0, u1, v1);
			si += 3;
			
			v0 = v1;
			v1 += bw / bh;
			vertices.push(rect.left, rect.top, rect.right, rect.bottom, rect.left, rect.bottom);
			indices.push(si+0, si+1, si+2);
			uvData.push(u0, v0, u1, v0, u1, v1);
			si += 3;
			
			rect = new Rectangle(bound.left, bound.bottom, bound.width, bw);
			v0 = v1;
			v1 += bound.width / bh;
			vertices.push(rect.left, rect.top, rect.right, rect.top, rect.right, rect.bottom, rect.left, rect.bottom);
			indices.push(si+0, si+1, si+3, si+1, si+2, si+3);
			uvData.push(u0, v1, u0, v0, u1, v0, u1, v1);
			si += 4;
			
			rect = new Rectangle(bound.left-bw, bound.bottom, bw, bw);
			v0 = v1;
			v1 += bw / bh;
			vertices.push(rect.right, rect.top, rect.right, rect.bottom, rect.left, rect.bottom);
			indices.push(si+0, si+1, si+2);
			uvData.push(u0, v0, u1, v0, u1, v1);
			si += 3;
			
			v0 = v1;
			v1 += bw / bh;
			vertices.push(rect.right, rect.top, rect.left, rect.bottom, rect.left, rect.top);
			indices.push(si+0, si+1, si+2);
			uvData.push(u0, v0, u1, v0, u1, v1);
			si += 3;
			
			rect = new Rectangle(bound.left-bw, bound.top, bw, bound.height);
			v0 = v1;
			v1 += bound.height / bh;
			vertices.push(rect.left, rect.top, rect.right, rect.top, rect.right, rect.bottom, rect.left, rect.bottom);
			indices.push(si+0, si+1, si+3, si+1, si+2, si+3);
			uvData.push(u1, v1, u0, v1, u0, v0, u1, v0);
			si += 4;
			
			rect = new Rectangle(bound.left - bw, bound.top - bw, bw, bw);
			v0 = v1;
			v1 += bw / bh;
			vertices.push(rect.right, rect.bottom, rect.left, rect.bottom, rect.left, rect.top);
			indices.push(si+0, si+1, si+2);
			uvData.push(u0, v0, u1, v0, u1, v1);
			si += 3;
			
			v0 = v1;
			v1 += bw / bh;
			vertices.push(rect.right, rect.bottom, rect.left, rect.top, rect.right, rect.top);
			indices.push(si+0, si+1, si+2);
			uvData.push(u0, v0, u1, v0, u1, v1);
			si += 3;
			
			rect = new Rectangle(bound.left, bound.top-bw, bound.width, bw);
			v0 = v1;
			v1 += bound.width / bh;
			vertices.push(rect.left, rect.top, rect.right, rect.top, rect.right, rect.bottom, rect.left, rect.bottom);
			indices.push(si+0, si+1, si+3, si+1, si+2, si+3);
			uvData.push(u1, v0, u1, v1, u0, v1, u0, v0);
			si += 4;
			
			rect = new Rectangle(bound.right, bound.top - bw, bw, bw);
			v0 = v1;
			v1 += bw / bh;
			vertices.push(rect.left, rect.bottom, rect.left, rect.top, rect.right, rect.top);
			indices.push(si+0, si+1, si+2);
			uvData.push(u0, v0, u1, v0, u1, v1);
			si += 3;
			
			v0 = v1;
			v1 += bw / bh;
			vertices.push(rect.left, rect.bottom, rect.right, rect.top, rect.right, rect.bottom);
			indices.push(si+0, si+1, si+2);
			uvData.push(u0, v0, u1, v0, u1, v1);
			si += 3;
			
			
			g.beginBitmapFill(bmd);
			g.drawTriangles(vertices, indices, uvData);
			bound.inflate(2, 2);
			g.beginFill(0xff0000);
			g.drawRect(bound.x, bound.y, bound.width, bound.height);
			g.endFill();
			
			
			var exportingBmd:BitmapData = new BitmapData(bmdBound.width, bmdBound.height, true, bmdBaseColor);
			exportingBmd.draw(shape, new Matrix(1, 0, 0, 1, -bmdBound.x, -bmdBound.y));
			
			return exportingBmd;
		}
	}
}