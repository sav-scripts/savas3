package sav.ui
{
	import flash.display.Graphics;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sav
	 */
	public class MyButton extends SimpleButton
	{
		public function MyButton(label:String) 
		{
			var format:TextFormat = new TextFormat();
			_tf = new TextField();
			_tf.defaultTextFormat = format;
			_tf.autoSize = TextFieldAutoSize.CENTER;
			_tf.text = label;
			_tf.textColor = 0x555555;
			
			var inflate:int = 4;
			
			var rect:Rectangle = new Rectangle(0, 0, int(_tf.width) + 4*4, int(_tf.height) + 4*2);			
			_tf.x = inflate*2;
			_tf.y = inflate;
			
			var sprite:Sprite = new Sprite();
			sprite.addChild(_tf);
			
			var g:Graphics = sprite.graphics;
			g.beginFill(0xE1E1E1);
			g.drawRoundRect(rect.x, rect.y, rect.width, rect.height, 10, 10);
			g.endFill();
			
			this.hitTestState = this.upState = this.downState = this.overState = sprite;
			
			
			this.useHandCursor = true;
		}
		
		/***  params  ***/
		private var _tf:TextField;
	}

}