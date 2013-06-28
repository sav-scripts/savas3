package sav.class3d.cameras
{
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.display.StageQuality;
	
	import sav.class3d.stages.Stage3D;

	public class CameraMotion extends EventDispatcher
	{
		public var friction			:Number = 1/2;
		public var rotateFriction	:Number = 1/4;
	
		public static const RENDER_OVER		:String = 'renderOver';
		public static const RENDER_START	:String = 'renderStart';
		public static const ROTATE_OVER		:String = 'rotateOver';
		
		public var changeQualityWhileRendering:Boolean = true;
		
		private var oldStageQuality			:String;

		public var camera					:ModfiedCamera;
		public var motionActiving			:Boolean = false;
		public var renderFunction			:Function;
		
		private var stage3D					:Stage3D;
		private var timer					:Timer;
		private var timerStarted			:Boolean = false;
		private var screenMoveFinished		:Boolean = true;
		private var yawFinished				:Boolean = true;
		private var zoomFinished			:Boolean = true;

		private var dx						:Number;
		private var dy						:Number;
		private var dYawDegree				:Number;
		private var rotateValue 			:Number = 3.7;
		private var dZoom					:Number;

		public function CameraMotion(cam:ModfiedCamera , func:Function , sm:Stage3D)
		{
			stage3D			= sm;
			camera				= cam;
			renderFunction		= func;
			timer				= new Timer(30);
			timer.addEventListener(TimerEvent.TIMER,timerHandler);
			resetValue();
		}
		
		public function destroy():void
		{
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER,timerHandler);
			timer = null;			
		}

		public function resetValue():void
		{
			dx = 0;
			dy = 0;
			dYawDegree = 0;
			dZoom = 0;
		}

		public function screenMove(tx:Number,ty:Number):void
		{
			dx += tx;
			dy +=ty;
			startTimer();
		}

		public function yaw(degree:Number,addNewTimer:Boolean = true):void
		{
			dYawDegree+=degree;
			
			if(addNewTimer) startTimer();
		}

		public function zoom(dz:Number):void
		{
			dZoom+=dz;
			startTimer();
		}

		private function startTimer():void
		{
			screenMoveFinished=false;
			yawFinished=false;
			zoomFinished=false;

			if (timerStarted==false)
			{				
				if (changeQualityWhileRendering) 
				{
					oldStageQuality		= stage3D.stage.quality;
					stage3D.stage.quality = StageQuality.MEDIUM;
				}
				timerStarted=true;
				dispatchEvent(new Event(CameraMotion.RENDER_START));
				timer.start();
			}
		}

		private function timerHandler(evt:TimerEvent):void
		{
			doScreenMove();
			doYaw();
			doZoom();

			renderFunction();
			
			if(yawFinished)
			{
				dispatchEvent(new Event(ROTATE_OVER));
			}
			
			if (yawFinished && screenMoveFinished && zoomFinished)
			{
				stopMotion();
			}

		}
		
		public function stopMotion():void
		{
			timerStarted=false;				
			timer.stop();
			if (changeQualityWhileRendering) stage3D.stage.quality = oldStageQuality;
			dispatchEvent(new Event(RENDER_OVER));
		}

		private function doScreenMove():void
		{
			if (screenMoveFinished==false)
			{
				var length=Math.sqrt(dx*dx+dy*dy);

				if (length>1)
				{
					camera.screenMove(dx*friction,dy*friction);
					dx *= (1-friction);
					dy *= (1-friction);
				}
				else
				{
					//trace('screenMoveFinished');
					camera.screenMove(dx,dy);
					dx=0;
					dy=0;
					screenMoveFinished=true;
				}
			}
		}

		private function doYaw():void
		{
			if (yawFinished==false)
			{
				if (Math.abs(dYawDegree)>Math.abs(rotateValue))
				{
					//camera.yaw(dYawDegree*rotateFriction);
					//dYawDegree*=(1-rotateFriction);
					var dDegree = dYawDegree/Math.abs(dYawDegree)*rotateValue;
					camera.yaw(dDegree);
					dYawDegree -= dDegree;
					dispatchEvent(new Event('rotated'));
					
				}
				else
				{
					camera.yaw(dYawDegree);
					dYawDegree=0;
					yawFinished=true;
				}
				
			}
		}

		private function doZoom():void
		{
			if (zoomFinished==false)
			{
				if (Math.abs(dZoom)>1)
				{
					camera.zoom(dZoom*friction,true);
					dZoom*=(1-friction);

				}
				else
				{
					camera.zoom(dZoom,true);
					dZoom=0;
					zoomFinished=true;
				}
			}
		}


	}
}