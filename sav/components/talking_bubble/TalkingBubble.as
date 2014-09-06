package sav.components.talking_bubble 
{
	import caurina.transitions.Tweener;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import sav.gp.BitmapUtils;
	import sav.gp.GraphicDrawer;
	/**
	 * ...
	 * @author Sav
	 */
	public class TalkingBubble extends Sprite
	{
		public function TalkingBubble(text:String, textFieldWidth:uint = 100, direction:String = "top", style:TalkingBubbleStyle = null ) 
		{
			_text = text;
			_textFieldWidth = textFieldWidth;
			_direction = direction;
			_style = (style == null) ? TalkingBubble.defaultStyle : style;
			
			_clip = new Sprite();
			this.mouseChildren = this.mouseEnabled = false;
			addChild(_clip);
			
			update();
		}
		
		public function update():void
		{
			buildTf();
			redraw();
		}
		
		public function showAt(container:DisplayObjectContainer, tx:Number = 0, ty:Number = 0, tweenIt:Boolean = true, toBitmapAfter:Boolean = true):void
		{
			x = tx;
			y = ty;
			container.addChild(this);
			
			if (toBitmapAfter) toBitmap();
			
			if (tweenIt)
			{
				_clip.scaleX = 0;
				_clip.scaleY = 0;
				Tweener.addTween(_clip, { time:0.4, scaleX:1, scaleY:1, transition:'easeInOutBack' } );
			}
		}
		
		public function toBitmap(inflate:Number = 2):void
		{
			if (_bitmapData) _bitmapData.dispose();
			_bitmapData = BitmapUtils.spriteToBitmapGraphics(_clip, 2);
		}
		
		private function redraw():void
		{
			var offsetRange:Number = _style.extendLength + _style.bubble_bleed_height;
			var offsetRange2:Number = int(_style.extendLength * .5) + _style.bubble_bleed_height;
			
			var et:Number = _style.extendLength;
			var extraRate:Number = 1;
			
			switch(_direction)
			{
				case TalkingBubbleDirection.TOP:
					_tf.x = -_tf.width / 2;
					_tf.y = -_tf.height - offsetRange;
				break;
				
				case TalkingBubbleDirection.RIGHT:
					_tf.x = offsetRange;
					_tf.y = -_tf.height / 2;
				break;
				
				case TalkingBubbleDirection.BOTTOM:
					_tf.x = -_tf.width / 2;
					_tf.y = offsetRange;
				break;
				
				case TalkingBubbleDirection.LEFT:
					_tf.x = -_tf.width - offsetRange;
					_tf.y = -_tf.height / 2;
				break;
				
				case TalkingBubbleDirection.TOP_RIGHT:
					_tf.x = offsetRange2;
					_tf.y = -_tf.height - offsetRange2;
					extraRate = 0.5;
				break;
				
				case TalkingBubbleDirection.TOP_LEFT:
					_tf.x = -_tf.width - offsetRange;
					_tf.y = -_tf.height - offsetRange2;
					extraRate = 0.5;
				break;
				
				case TalkingBubbleDirection.BOTTOM_RIGHT:
					_tf.x = offsetRange2;
					_tf.y = offsetRange2;
					extraRate = 0.5;
				break;
				
				case TalkingBubbleDirection.BOTTOM_LEFT:
					_tf.x = -_tf.width - offsetRange2;
					_tf.y = offsetRange2;
					extraRate = 0.5;
				break;
				
				default:
					throw new Error("Illegal direction : " + _direction);
			}			
			
			var bound:Rectangle = _tf.getBounds(this);
			bound.inflate(_style.bubble_bleed_width, _style.bubble_bleed_height);
			
			var rc:Number = _style.roundConer;			
			var inflate:Number = 0;
			var dInflate:Number;
			et = et * extraRate;
			
			var g:Graphics = _clip.graphics;
			g.clear();
			
			// draw outline
			g.beginFill(_style.bubble_line_color, _style.bubble_line_alpha);
			drawShape(g, bound, rc, et);
			
			dInflate = _style.bubble_line_thickness;
			inflate -= dInflate;
			bound.inflate( -dInflate, -dInflate);
			rc -= dInflate;
			et -= dInflate*extraRate;
			drawShape(g, bound, rc, et, inflate);

			
			// draw body
			
			g.beginFill(_style.bubble_body_color, _style.bubble_body_alpha);			
			dInflate = _style.bubble_line_inflate;
			inflate -= dInflate;
			bound.inflate( -dInflate, -dInflate);
			rc -= dInflate;
			et -= dInflate*extraRate;
			drawShape(g, bound, rc, et, inflate);
		}
		
		private function drawShape(g:Graphics, bound:Rectangle, rc:Number, et:Number, inflate:Number = 0):void
		{
			var cw:Number = bound.left + bound.width / 2;
			var ch:Number = bound.top + bound.height / 2;
			var rc2:Number = rc + inflate;
			
			if (_direction == TalkingBubbleDirection.BOTTOM_RIGHT)
			{
				g.moveTo(bound.left - et, bound.top - et);
				g.moveTo(bound.left + rc2, bound.top);
			}
			else
			{
				g.moveTo(bound.left + rc, bound.top);
			}
			
			if (_direction == TalkingBubbleDirection.BOTTOM)
			{
				g.lineTo(cw + et, bound.top);
				g.lineTo(cw, bound.top - et);
				g.lineTo(cw - et, bound.top);
			}
			
			if (_direction == TalkingBubbleDirection.BOTTOM_LEFT)
			{
				g.lineTo(bound.right - rc2, bound.top);				
				g.lineTo(bound.right + et, bound.top - et);
				g.lineTo(bound.right, bound.top + rc2);
			}
			else
			{
				g.lineTo(bound.right - rc, bound.top);
				g.curveTo(bound.right, bound.top, bound.right, bound.top + rc);
			}
			
			if (_direction == TalkingBubbleDirection.LEFT)
			{
				g.lineTo(bound.right, ch - et)
				g.lineTo(bound.right + et, ch);
				g.lineTo(bound.right, ch + et);
			}
			
			if (_direction == TalkingBubbleDirection.TOP_LEFT)
			{
				g.lineTo(bound.right, bound.bottom - rc2);				
				g.lineTo(bound.right + et, bound.bottom + et);
				g.lineTo(bound.right - rc2, bound.bottom);
			}
			else
			{
				g.lineTo(bound.right, bound.bottom - rc);
				g.curveTo(bound.right, bound.bottom, bound.right - rc, bound.bottom);
			}
			
			if (_direction == TalkingBubbleDirection.TOP)
			{
				g.lineTo(cw + et, bound.bottom);
				g.lineTo(cw, bound.bottom + et);
				g.lineTo(cw - et, bound.bottom);
			}
			
			if (_direction == TalkingBubbleDirection.TOP_RIGHT)
			{
				g.lineTo(bound.left + rc2, bound.bottom);				
				g.lineTo(bound.left - et, bound.bottom + et);
				g.lineTo(bound.left, bound.bottom - rc2);
			}
			else
			{
				g.lineTo(bound.left +rc, bound.bottom);
				g.curveTo(bound.left, bound.bottom, bound.left, bound.bottom - rc);
			}
			
			if (_direction == TalkingBubbleDirection.RIGHT)
			{
				g.lineTo(bound.left, ch - et)
				g.lineTo(bound.left - et, ch);
				g.lineTo(bound.left, ch + et);
				
			}
			
			if (_direction == TalkingBubbleDirection.BOTTOM_RIGHT)
			{
				g.lineTo(bound.left, bound.top + rc2)
				g.lineTo(bound.left - et, bound.left -et);
			}
			else
			{
				g.lineTo(bound.left, bound.top + rc);
				g.curveTo(bound.left, bound.top, bound.left + rc, bound.top);
			}
		}
		
		private function buildTf():void
		{
			if (_tf) throw new Error("text field should only be built once");
			
			var format:TextFormat = new TextFormat();
			
			format.color = _style.text_solor;
			format.size = _style.text_size;
			_tf = new TextField();
			_tf.defaultTextFormat = format;
			_tf.multiline = true;
			_tf.selectable = _style.text_selectable;
			
			
			_tf.autoSize = _style.text_align;
			
			if (_style.resizeTextField)
			{
				_tf.wordWrap = false;
				
				(_style.text_htmlText == true) ? _tf.htmlText = _text : _tf.text = _text;
				
				if (_tf.width > _textFieldWidth)
				{
					_tf.width = _textFieldWidth;
					_tf.wordWrap = true;
				}
			}
			else
			{
				if (_textFieldWidth > 0)
				{
					_tf.width = _textFieldWidth;
					_tf.wordWrap = true;
				}
				else
				{
					_tf.wordWrap = false;
				}
				
				(_style.text_htmlText == true) ? _tf.htmlText = _text : _tf.text = _text;
			}
			
			_tf.filters = _style.text_filters;
			_clip.addChild(_tf);
		}
		
		public function testBound(container:DisplayObjectContainer, bound:Rectangle, tx:Number, ty:Number):String
		{
			this.x = tx;
			this.y = ty;
			
			container.addChild(this);
			
			var testBound:Rectangle = this.getBounds(container);
			
			container.removeChild(this);
			
			//trace("tx = " + tx + ", ty = " + ty);
			//trace('bound = ' + bound);
			//trace('testBound = ' + testBound);
			//trace('test = ' + (!bound.containsRect(testBound) && bound.width > testBound.width && bound.height > testBound.height));
			
			if (!bound.containsRect(testBound) && bound.width > testBound.width && bound.height > testBound.height)
			{
				if ((tx - bound.left) <= testBound.width && (ty - bound.top) <= testBound.height)
				{
					return TalkingBubbleDirection.BOTTOM_RIGHT;
				}
				else if ((bound.right - tx) <= testBound.width && (ty - bound.top) <= testBound.height)
				{
					return TalkingBubbleDirection.BOTTOM_LEFT;
				}
				else if ((tx - bound.left) <= testBound.width && (bound.bottom - ty) <= testBound.height)
				{
					return TalkingBubbleDirection.TOP_RIGHT;
				}
				else if ((bound.right - tx) <= testBound.width && (bound.bottom - ty) <= testBound.height)
				{
					return TalkingBubbleDirection.TOP_LEFT;
				}
				else if((bound.right - tx) <= testBound.width)
				{
					return TalkingBubbleDirection.LEFT;
				}
				else if((tx - bound.left) <= testBound.width)
				{
					return TalkingBubbleDirection.RIGHT;
				}
				else if((ty - bound.top) <= testBound.height)
				{
					return TalkingBubbleDirection.BOTTOM;
				}
			}
			
			return TalkingBubbleDirection.TOP;
		}
		
		public function destroy():void
		{
			if (_isDestroy) return;
			_isDestroy = true;
			
			if (_bitmapData)
			{
				_bitmapData.dispose();
				_bitmapData = null;
			}
			
			if (_tf)
			{
				if (_tf.parent) _tf.parent.removeChild(_tf);
				_tf = null;
			}
			
			if (_clip)
			{
				Tweener.removeTweens(_clip);
				removeChild(_clip);
				_clip = null;
			}
			
			_style = null;
			
			if (parent) parent.removeChild(this);
		}
		
		/**********************
		 *       params
		 * *******************/
		private var _tf:TextField;		
		private var _style:TalkingBubbleStyle;
		
		private var _bitmapData:BitmapData;
		private var _clip:Sprite;
		 
		 
		private var _isDestroy:Boolean = false;
		 
		private var _text:String;
		private var _textFieldWidth:uint;
		
		private var _direction:String;
		public function get direction():String { return _direction; }
		public function set direction(newDirection:String):void
		{
			if (_direction == newDirection) return;
			_direction = newDirection;
			redraw();
		}
		
		public function get textFieldWidth():Number	{ return _tf.getBounds(this).width; }
		
		public function get textFieldHeight():Number { return _tf.getBounds(this).height; }
		
		public function get bubbleWidth():Number 
		{ return textFieldWidth + (_style.bubble_bleed_width * 2) + _style.extendLength; }
		
		public function get bubbleHeight():Number 
		{ return textFieldHeight + (_style.bubble_bleed_height * 2) + _style.extendLength; }
		
		
		private var CIRCLE_GAP:Number = 2;
		
		
		/**********************
		 *    static params
		 * *******************/
		public static var defaultStyle:TalkingBubbleStyle = new TalkingBubbleStyle();
	}
}