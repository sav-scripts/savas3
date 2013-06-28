package sav.class3d.stages
{	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import sandy.core.Scene3D;	
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.ATransformable;
	
	import sav.class3d.cameras.ModfiedCamera;
	import sav.class3d.cameras.CameraMotion;
	import sav.class3d.managers.CameraManager;
	
	public class Stage3D extends Sprite implements IStage3D
	{
		static public const RenderOnceCompleted	:String = 'renderOnceCompleted';
		
		public var scene					:Scene3D;		
		public var camera					:ModfiedCamera;
		public var cameraManager			:CameraManager;
		public var cameraMotion				:CameraMotion;
		public var alwaysRenderingObjects	:Array = [];
		public var renderParticleOn			:Boolean = true;
				
		public function reset(excuteDestroy:Boolean = true):void{};
		public function destroy():void{};		
		public function renderAll():void{};
		public function setAllToStopRender():void{};
		public function setAllToStartRender():void{};
		public function renderParticle():void{};		
		public function clear():void{};		
		
		public function renderOnce(keepQuality:Boolean = true):void
		{			
			cameraMotion.changeQualityWhileRendering = (keepQuality == false);
			cameraMotion.yaw(0);
			cameraMotion.addEventListener(CameraMotion.RENDER_OVER , renderOnceCompleted);
		}
		
		private function renderOnceCompleted(evt:Event):void
		{
			cameraMotion.removeEventListener(CameraMotion.RENDER_OVER , renderOnceCompleted);
			cameraMotion.changeQualityWhileRendering = true;
			dispatchEvent(new Event(RenderOnceCompleted));
		}
		
		public function addAlwaysRenderingObject(aTransformable:ATransformable):Boolean
		{
			if (alwaysRenderingObjects.indexOf(aTransformable) == -1) 
			{
				aTransformable.alwaysRenderThis = true;
				alwaysRenderingObjects.push(aTransformable);
				return true;
			}
			return false;
		}
		
		public function removeAlwaysRenderingObject(aTransformable:ATransformable):Boolean
		{
			var index = alwaysRenderingObjects.indexOf(aTransformable);
			if (index != -1) 
			{
				aTransformable.alwaysRenderThis = false;
				alwaysRenderingObjects.splice(index , 1);
				return true;
			}
			return false;
		}
	}
}