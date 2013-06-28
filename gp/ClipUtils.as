package sav.gp 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	/**
	 * ...
	 * @author sav
	 */
	public class ClipUtils 
	{
		/**
		 * draw sourceClip with black and white outlines, then pass graphic data to another clip and reutrn it
		 * 
		 * @param	sourceClip	
		 * @param	initScale	this value only scale sourceClip
		 * @param	extraScale	this value scale both sourceClip and outline
		 * @return	Sprite
		 */
		public static function clipToOutlineClip(sourceClip:Sprite, initScale:Number = 1, extraScale:Number = 1, outlineArray:Array = null):Sprite
		{
			sourceClip.scaleX = sourceClip.scaleX / Math.abs(sourceClip.scaleX) * initScale * extraScale;
			sourceClip.scaleY = sourceClip.scaleY / Math.abs(sourceClip.scaleY) * initScale * extraScale;
			
			//if (outlineArray == null) outlineArray = [ { color:0x000000, size:2 }, { color:0xffffff, size:4 } ];
			
			var obj:Object = getOutlineFilters(outlineArray, extraScale);	
			sourceClip.filters = obj.filters;
			//sourceClip.filters = [new GlowFilter(0, 1, 2 * extraScale, 2 * extraScale, 3, 1), new GlowFilter(0xffffff, 1, 4 * extraScale, 4 * extraScale, 20, 1)];
			
			var resultClip:Sprite = new Sprite();
			BitmapUtils.spriteToBitmapGraphics(sourceClip, obj.size* extraScale, true, false, false, resultClip.graphics);
			
			return resultClip;
		}
		
		private static function getOutlineFilters(outlineArray:Array = null, extraScale:Number = 1):Object
		{
			if (outlineArray == null) outlineArray = default_outline_setting;
			
			var result:Object = { };
			var filters:Array = [];
			var i:int, l:int = outlineArray.length;
			var size:Number = 0;
			
			for (i = 0; i < l; i++)
			{
				var obj:Object = outlineArray[i];
				size += obj.size;
				filters.push(new GlowFilter(obj.color, 1,  obj.size* extraScale, obj.size * extraScale, 20, 1));
			}
			
			result.size = size;
			result.filters = filters;
			
			return result;
		}
		
		
		public static function movieClipToOutLineClips(sourceClip:MovieClip, initScale:Number = 1, extraScale:Number = 1, name__labelArray:* = 'frame', startIndex:int = 1, endIndex:int = 1, outlineArray:Array = null):Array
		{
			if (endIndex < startIndex || endIndex > sourceClip.totalFrames || startIndex < 1) throw new Error('unexpected error, totalFrames : ' + sourceClip.totalFrames);
			
			sourceClip.scaleX = sourceClip.scaleX / Math.abs(sourceClip.scaleX) * initScale * extraScale;
			sourceClip.scaleY = initScale * extraScale;
			
			
			var obj:Object = getOutlineFilters(outlineArray, extraScale);	
			sourceClip.filters = obj.filters;
			//sourceClip.filters = [new GlowFilter(0, 1, 2 * extraScale, 2 * extraScale, 3), new GlowFilter(0xffffff, 1, 4 * extraScale, 4 * extraScale, 20, 1)];
			
			var array:Array = [];
			
			var newName:String;
			var resultClip:Sprite;
			
			if (name__labelArray is String)
			{
				var i:int;
				for (i = startIndex; i <= endIndex; i++)
				{
					sourceClip.gotoAndStop(i);
					resultClip = new Sprite();
					BitmapUtils.spriteToBitmapGraphics(sourceClip, obj.size * extraScale, true, false, false, resultClip.graphics);
					
					newName = name__labelArray + String(i);
					array.push( { name:newName, clip:resultClip } );
				}
			}
			else if(name__labelArray is Array)
			{
				for each(newName in name__labelArray)
				{
					sourceClip.gotoAndStop(newName);
					resultClip = new Sprite();
					BitmapUtils.spriteToBitmapGraphics(sourceClip, obj.size * extraScale, true, false, false, resultClip.graphics);
					
					array.push( { name:newName, clip:resultClip } );
				}
			}
			else
			{
				throw new Error('unepxected error');
			}
			
			return array;
		}
		
		public static function getBitmapClip(sprite:Sprite, bleed:Number = 2, smooth:Boolean = false, initScale:Number = 1, extraScale:Number = 1):Sprite
		{
			sprite.scaleX = sprite.scaleX / Math.abs(sprite.scaleX) * initScale * extraScale;
			sprite.scaleY = sprite.scaleY / Math.abs(sprite.scaleY) * initScale*extraScale;
			
			var resultClip:Sprite = new Sprite();
			BitmapUtils.spriteToBitmapGraphics(sprite, bleed, smooth, false, false, resultClip.graphics);
			
			return resultClip;
		}
		
		/************************
		*         params
		************************/
		public static var default_outline_setting:Array = [];
	}

}