package sav.class3d.managers
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.display.StageQuality;
	import flash.display.Sprite;
	
	import caurina.transitions.Tweener;
	
	import sav.Key;
	import sav.class3d.cameras.*;
	import sav.class3d.stages.Stage3D;
	
	public class CameraManager extends EventDispatcher
	{
		public var camera				:ModfiedCamera;
		public var cameraMotion			:CameraMotion;
		private var stage3D			:Stage3D;
		
		private var oldMouseX			:Number;
		private var oldMouseY			:Number;
		private const maxMoveBound		:Rectangle	= new Rectangle(-400,-400,800,800);
		private const currentPosition	:Point		= new Point(0,0);
		private const mapStartPoint		:Point		= new Point(0,0);
		private const zoomBound			:Point		= new Point(-500,500);
		private const D_SCREEN_MOVE		:uint		= 20;
		private var zoomValue			:Number		= 0;
		private var controlMovieClip	:Sprite;
		
		private var cameraRotating		:Boolean 	= false;		
		
		private var locked				:Boolean = true;
		
		public function CameraManager(sm:Stage3D)
		{
			stage3D			= sm;
			camera				= stage3D.camera;
			cameraMotion		= stage3D.cameraMotion;
		}
		
		public function init(initZoomRate:int = -600):void
		{
			camera.fov = 30;
			camera.moveTo(0,-1500,-700,true);			
			camera.zoom(initZoomRate);
			//camera.yaw(225);
			camera.screenMove(0,200);
			cameraMotion.resetValue();
			lock();
			
			cameraMotion.addEventListener(CameraMotion.RENDER_OVER,cameraRenderOver);
			cameraMotion.addEventListener(CameraMotion.RENDER_START,cameraRenderStart);		
			//stage3D.addEventListener(Event.ENTER_FRAME,renderParticleHandler);
		}
		
		public function activeInteractive(cm:Sprite):void
		{
			controlMovieClip	= cm;
		}
		
		public function destroy():void
		{
			cameraMotion.removeEventListener(CameraMotion.RENDER_OVER,cameraRenderOver);
			cameraMotion.removeEventListener(CameraMotion.RENDER_START,cameraRenderStart);
			cameraMotion.removeEventListener(CameraMotion.ROTATE_OVER,cameraRotateListener);
			
			stage3D.stage.removeEventListener(Event.ENTER_FRAME,keyPressedHandler);
			stage3D.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			stage3D.removeEventListener(Event.ENTER_FRAME,renderParticleHandler);
			stage3D.removeEventListener(Event.ENTER_FRAME,mousePressedEnterFrame);
			stage3D.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			
			camera.destroy();
			cameraMotion.destroy();
			camera			= null;
			cameraMotion	= null;
			stage3D		= null;		
		}
		
		public function unlock():void
		{
			if (locked) 
			{
				locked = false;
				stage3D.stage.addEventListener(Event.ENTER_FRAME , keyPressedHandler);
				stage3D.stage.addEventListener(MouseEvent.MOUSE_WHEEL , mouseWheelHandler);
			}
		}
		
		public function lock():void
		{
			if (locked == false)
			{
				locked = true;
				stage3D.stage.removeEventListener(Event.ENTER_FRAME , keyPressedHandler);
				stage3D.stage.removeEventListener(MouseEvent.MOUSE_WHEEL , mouseWheelHandler);
			}
		}		
		
		public function cameraRenderOver(evt = null):void
		{			
			stage3D.setAllToStopRender();
			stage3D.removeEventListener(Event.ENTER_FRAME,renderParticleHandler);
			stage3D.addEventListener(Event.ENTER_FRAME,renderParticleHandler);
		}
		
		public function cameraRenderStart(evt = null):void
		{
			stage3D.setAllToStartRender();
			stage3D.removeEventListener(Event.ENTER_FRAME,renderParticleHandler);
		}

		private function renderParticleHandler(event:Event):void
		{
			stage3D.renderParticle();
			//stage3D.renderAll();
		}
		
		
		private function keyPressedHandler(event:Event):void
		{
			if (Key.isDown(104)) excuteZoom(40);
			
			if (Key.isDown(98)) excuteZoom(-40);
			
			if (Key.isDown(81) || Key.isDown(100)) cameraRotate(-45);
			
			if (Key.isDown(69) || Key.isDown(102)) cameraRotate(45);
			
			if (Key.isDown(87) || Key.isDown(Keyboard.UP)) screenMove(0,D_SCREEN_MOVE);
			
			if (Key.isDown(83) || Key.isDown(Keyboard.DOWN)) screenMove(0,-D_SCREEN_MOVE);
			
			if (Key.isDown(65) || Key.isDown(Keyboard.LEFT)) screenMove(-D_SCREEN_MOVE,0);
			
			if (Key.isDown(68) || Key.isDown(Keyboard.RIGHT)) screenMove(D_SCREEN_MOVE,0);
			
		}
		
		public function excuteZoom(value:Number):void
		{
			var dz;
			var targetValue = zoomValue + value;
			dz = targetValue - zoomBound.y;
			if (dz > 0) value -= dz;
			dz = targetValue - zoomBound.x;
			if (dz < 0) value -= dz;
			
			if(dz != 0) cameraMotion.zoom(value);
			
			zoomValue += value;
		}
		
		private function mouseWheelHandler(evt:MouseEvent):void
		{
			if (evt.delta > 0)
			{	
				cameraRotate(-45);
			} else {
				cameraRotate(45);
			}
		}
		
		private function mouseDownHandler(evt:MouseEvent):void
		{			
			oldMouseX = stage3D.stage.mouseX;
			oldMouseY = stage3D.stage.mouseY;
			stage3D.addEventListener(Event.ENTER_FRAME,mousePressedEnterFrame);
			stage3D.stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
		}

		private function mousePressedEnterFrame(evt:Event):void
		{
			var newMouseX		= stage3D.stage.mouseX;
			var newMouseY		= stage3D.stage.mouseY;
			var dx = newMouseX - oldMouseX;
			var dy = newMouseY - oldMouseY;
			
			oldMouseX = newMouseX;
			oldMouseY = newMouseY;
			
			screenMove(-dx,dy);
		}
		
		private function mouseUpHandler(evt:MouseEvent):void
		{
			stage3D.removeEventListener(Event.ENTER_FRAME,mousePressedEnterFrame);
			stage3D.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
		}
		
		public function screenMove(x:Number,y:Number):void
		{
			if((currentPosition.x+x) > maxMoveBound.right)x+=(maxMoveBound.right - (currentPosition.x+x));
			if((currentPosition.y+y) > maxMoveBound.bottom)y+=(maxMoveBound.bottom - (currentPosition.y+y));
			if((currentPosition.x+x) < maxMoveBound.left)x+=(maxMoveBound.left - (currentPosition.x+x));
			if((currentPosition.y+y) < maxMoveBound.top)y+=(maxMoveBound.top - (currentPosition.y+y));
			
			currentPosition.x += x;
			currentPosition.y += y;			
						
			cameraMotion.screenMove(x,y);
		}
		
		public function cameraRotate(angle:Number):void
		{
			if (cameraRotating == false)
			{
				cameraRotating = true;
				cameraMotion.addEventListener(CameraMotion.ROTATE_OVER,cameraRotateListener);
				
				cameraMotion.yaw(angle);
			}
		}
		
		public function cameraRotateListener(evt):void
		{
			cameraRotating = false;
			cameraMotion.removeEventListener(CameraMotion.ROTATE_OVER,cameraRotateListener);
		}
		
	}
}