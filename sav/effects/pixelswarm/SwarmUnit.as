package sav.effects.pixelswarm
{
	import caurina.transitions.Equations;
	import fl.motion.Color;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	public class SwarmUnit
	{		
		public function SwarmUnit(startX:Number, startY:Number, distanceX:Number, distanceY:Number, width:Number, height:Number, aRGB:uint, nextUnit:SwarmUnit = null)
		{
			sx = startX;
			sy = startY;
			
			dx = _startDx = distanceX;
			dy = _startDy = distanceY;
			
			tx = sx + dx;
			ty = sy + dy;
			
			rect = new Rectangle(sx, sy, width, height);
			
			_color = aRGB;
			_rgb = aRGB & 0xffffff;
			_alpha = _startAlpha = aRGB >>> 24;
			
			var color:Color = new Color();
			color.color = _rgb;
			brigtness = color.brightness;
		}
		
		private var _rgb:uint;
		public function get rgb():uint { return _rgb; }
		
		private var _startAlpha:uint;
		private var _alpha:uint;
		
		public var brigtness:uint;
		
		
		private var _color:uint;
		public function get color():uint { return _color; }
		
		
		private var _progress:Number = 0;
		public function get progress():Number { return _progress; }
		public function set progress(n:Number):void
		{
			//_progress = (n < 0.01) ? 0 : n;
			_progress = (n > 1) ? 1 : n;
			
			//_scale = (_progress > 0.5) ? 1 - progress : _progress;
			
			//var _pg:Number = (_progress < 0.5) ? 1 - progress : _progress;
			
			//dx = _progress * _startDx;
			//dy = _progress * _startDy;
			//dx = Equations.easeInSine(_pg, tx, -_startDx, 1);
			//dy = Equations.easeInSine(_pg, ty, -_startDy, 1);
			
			dx = Equations.easeOutBack(_progress, sx, _startDx, 1);
			dy = Equations.easeOutSine(_progress, sy, _startDy, 1);
			
			//dx = Equations.easeOutBounce(_progress, sx, _startDx, 1);
			//dy = Equations.easeOutBounce(_progress, sy, _startDy, 1);
			
			//var dAlpha:Number = Equations.easeOutSine(_progress, 1, -1, 1);
			
			//dx = Equations.easeNone(_progress, sx, _startDx, 1);
			//dy = Equations.easeNone(_progress, sy, _startDy, 1);
			
			//dx = Equations.easeInOutBack(_progress, sx, _startDx, 1);
			//dy = Equations.easeInOutBack(_progress, sy, _startDy, 1);
			
			
			_color = (int(_startAlpha * (1-_progress)) << 24) + _rgb;
			//_color = (int(_startAlpha * dAlpha) << 24) + _rgb;
		}
		
		//private var _bitmapData:BitmapData;
		//public function get bitmapData():BitmapData;
		
		public static function easeNone (t:Number, b:Number, c:Number, d:Number, p_params:Object = null):Number
		{
			return c*t/d + b;
		}
		
		public static function easeOutSine (t:Number, b:Number, c:Number, d:Number, p_params:Object = null):Number {
			return c * Math.sin(t/d * (Math.PI/2)) + b;
		}
		
		public static function easeInSine (t:Number, b:Number, c:Number, d:Number, p_params:Object = null):Number {
			return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
		}
		
		private var _scale:Number;
		public function get scale():Number { return _scale; }
		
		public var sx:Number;
		public var sy:Number;
		
		public var tx:Number;
		public var ty:Number
		
		public var dx:Number;
		public var dy:Number;
		
		private var _startDx:Number;
		private var _startDy:Number;
		
		public var rect:Rectangle;
	}
}