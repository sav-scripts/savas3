package sav.ui.utils
{
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	public class ToolHinter
	{
		public static function init(stg:Stage):void
		{
			if (_stage) return;
			_stage = stg;
			_hinterDic = new Dictionary(true);
			
			HintLabel.stg = _stage;
		}
		
		public static function add(target:InteractiveObject, message:String, showInTop:Boolean = true, dx:Number = 0, dy:Number = 0, delay:Number = 0, duration:Number = 0):void
		{
			if (!_hinterDic) return;
			if (_hinterDic[target]) remove(target);
			
			var yDirection:int = (showInTop) ? 1 : -1;
			
			var hinter:Hinter = new Hinter(target, message, dx, dy, delay, yDirection, duration);
			_hinterDic[target] = hinter;			
			
			target.addEventListener(MouseEvent.MOUSE_OVER, target_MouseOver);
			target.addEventListener(MouseEvent.MOUSE_OUT, target_MouseOut);
		}
		
		private static function target_MouseOver(evt:MouseEvent):void
		{
			var hinter:Hinter = _hinterDic[evt.currentTarget];
			
			if (hinter.delay <= 0)
			{
				makeLabel(hinter);
			}
			else
			{
				_targetHinter = hinter;
				
				clearTimer();
				
				_timer = new Timer(hinter.delay * 1000, 1);
				_timer.addEventListener(TimerEvent.TIMER, timerTick);
				_timer.start();
			}
		}
		
		private static function clearTimer():void
		{
			if (_timer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, timerTick);
				_timer = null;
			}			
		}
		
		private static function timerTick(evt:TimerEvent):void
		{
			clearTimer();
			
			makeLabel(_targetHinter);
			_targetHinter = null;
		}
		
		private static function makeLabel(hinter:Hinter):void
		{
			var message:String = hinter.message;
			var target:InteractiveObject = hinter.target;			
			
			var position:Point = target.localToGlobal(new Point());
			position.offset(hinter.dx, hinter.dy);
			_label = new HintLabel(hinter.message, Math.round(position.x), Math.round(position.y), hinter.yDirection, hinter.duration);
		}
		
		private static function target_MouseOut(evt:MouseEvent):void
		{
			hide();
		}
		
		public static function hide():void
		{
			clearTimer();
			
			if (_label) 
			{
				_label.destroy();
				_label = null;
			}
		}
		
		public static function remove(target:InteractiveObject):void
		{
			if (!_hinterDic) return;
			
			target.removeEventListener(MouseEvent.MOUSE_OVER, target_MouseOver);
			target.removeEventListener(MouseEvent.MOUSE_OUT, target_MouseOut);
		}
		
		private static var _timer:Timer;
		private static var _targetHinter:Hinter;
		
		private static var _stage:Stage;
		private static var _hinterDic:Dictionary;
		
		private static var _label:HintLabel;
		
	}
}

import flash.display.*;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;

class Hinter
{
	public function Hinter(target:InteractiveObject, message:String, dx:Number = 0, dy:Number = 0, delay:Number = 0, yDirection:int = 1, duration:Number = 2)
	{
		this.target = target;
		this.message = message;
		this.dx = dx;
		this.dy = dy;
		this.delay = delay;
		this.yDirection = yDirection;
		this.duration = duration;
	}
	
	public var target:InteractiveObject;
	public var message:String;
	public var delay:Number;
	public var yDirection:int;
	
	public var dx:Number;
	public var dy:Number;
	
	public var duration:Number;
}

class HintLabel extends Sprite
{
	public function HintLabel(message:String, tx:Number, ty:Number, yDirection:int = 1, duration:Number = 2)
	{
		mouseChildren = mouseEnabled = false;
		
		x = tx;
		y = ty;
		
		_tf = new TextField();
		_tf.autoSize = TextFieldAutoSize.LEFT;
		_tf.text = message;
		_tf.x = -_tf.width / 2;
		_tf.y = -_tf.height / 2 - (RAISE_HEIGHT * yDirection);
		
		_tf.textColor = 0x999999;
		
		addChild(_tf);
		
		
		// draw basement
		
		var ddx:Number = 0, ddy:Number = 0;
		
		var bound:Rectangle = _tf.getBounds(this);
		bound.x = Math.round(bound.x);
		bound.y = Math.round(bound.y);
		bound.width = Math.round(bound.width);
		bound.height = Math.round(bound.height);
		
		
		//var topLeft:Point = bound.topLeft;
		
		var bound2:Rectangle = _tf.getBounds(_stage);
		
		var dLeft:Number = _limitBound.left - bound2.left;
		var dRight:Number = bound2.right - _limitBound.right;
		var dTop:Number = _limitBound.top - bound2.top;
		var dBottom:Number = bound2.bottom - _limitBound.bottom;
		
		if (dLeft > 0)
			ddx = dLeft;
		else if (dRight > 0)
			ddx = -dRight;
		
		if (dTop > 0)
			ddy = dTop;
		else if (dBottom > 0)
			ddy = -dBottom;
		
		_tf.x += ddx;
		_tf.y += ddy;
		
		bound.offset(ddx, ddy);
		//bound.inflate(6, 2);
		bound.inflate(7, 3);
		bound.y -= 1;
		
		if (yDirection == -1)
		{
			bound.y += 2;
			_tf.y += 2;
		}
		
		var g:Graphics = graphics;
		g.beginFill(0x000000);
		g.drawRoundRect(bound.x, bound.y, bound.width, bound.height, ROUND_CONER);
		bound.inflate( -1, -1);
		
		g.beginFill(0xaaaaaa);
		g.drawRoundRect(bound.x, bound.y, bound.width, bound.height, ROUND_CONER-2);
		bound.inflate( -1, -1);
		
		/*
		g.lineStyle(Number.NaN);		
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(bound.width, bound.height, Math.PI / 2, bound.x, bound.y);
		
		g.beginGradientFill(
			GradientType.LINEAR,
			[0x555555, 0x262626, 0x3C3C3C], 
			[1, 1, 1],
			[0x00, 0x00, 0xff], 
			matrix);
		*/
			
		g.beginFill(0x333333);
		g.drawRoundRect(bound.x, bound.y, bound.width, bound.height, ROUND_CONER-4);
			
		g.endFill();
		
		g.beginFill(0);
		g.drawCircle(0, 0, 3);
		g.beginFill(0x555555);
		g.drawCircle(0, 0, 2);
		g.endFill();
		
		
		_stage.addChild(this);
		
		
		if (duration > 0)
		{
			_removeTimer = new Timer(duration * 1000, 1);
			_removeTimer.addEventListener(TimerEvent.TIMER, removeTimerTick);
			_removeTimer.start();
		}
	}
	
	private function removeTimerTick(evt:TimerEvent):void
	{
		destroy();
	}
	
	public function destroy():void
	{
		if (_isDestroy) return;
		
		if (_removeTimer)
		{
			_removeTimer.stop();
			_removeTimer.removeEventListener(TimerEvent.TIMER, removeTimerTick);
			_removeTimer = null;
		}
		
		if (_tf)
		{
			removeChild(_tf);
			_tf = null;
		}
		
		if (parent) parent.removeChild(this);
		
		_isDestroy = true;
	}
	
	/**********************
	 *       params
	 * *******************/
	private var _removeTimer:Timer;
	
	private var _isDestroy:Boolean = false;
	
	private var _tf:TextField;
	
	private static const RAISE_HEIGHT:Number = 15;
	private static const V_WIDTH:Number = 20;
	private static const ROUND_CONER:Number = 10;
	
	
	private static var _limitBound:Rectangle;	 
	private static var _stage:Stage;
	public static function set stg(s:Stage):void
	{
		_stage = s;
		
		_limitBound = new Rectangle(0, 0, _stage.stageWidth, _stage.stageHeight);
		_limitBound.inflate( -10, -10);
	}
}