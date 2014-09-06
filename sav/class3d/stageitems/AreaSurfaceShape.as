package sav.class3d.stageitems
{
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	import flash.events.MouseEvent;
	
	import sandy.core.scenegraph.Sprite2D;
	import sandy.primitive.Plane3D;
	import sandy.materials.Appearance;
	import sandy.materials.MovieMaterial;
	import sandy.materials.Appearance;
	
	import sav.class3d.materials.MovieMaterialsForFaces;
	
	public class AreaSurfaceShape extends Plane3D
	{
		public var movieClipItem				:MovieClip;
		public var myArea						:Area;
		public var objectData					:Object;
		public var distanceToFocusPoint			:Number;
		
		public function AreaSurfaceShape(MovieClass:Class , theName:String = null , w:uint = 100, h:uint = 100)		
		{	
			super(theName , w , h);
			
			movieClipItem					= new MovieClass();			
			//movieClipItem.mouseEnabled		= false;
			
			var movieMaterial:MovieMaterial	= new MovieMaterial(movieClipItem);
			movieMaterial.smooth			= true;
			var _appearance:Appearance		= new Appearance(movieMaterial);
			this.appearance					= _appearance;
			
			//container.mouseEnabled = false;
		}
		
		override public function destroy():void
		{
			movieClipItem = null;
			objectData = null;
			myArea = null;
			alwaysRenderThis = false;
			super.destroy();
		}
	}
}