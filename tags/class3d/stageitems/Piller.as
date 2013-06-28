package sav.class3d.stageitems
{
	import flash.display.MovieClip;
	
	import sandy.primitive.Box;
	import sandy.materials.Appearance;
	
	import sav.class3d.materials.MovieMaterialsForFaces;
	
	public class Piller extends Box
	{
		public var topFaceAppearance:Appearance;
		public var isAnimeArea:Boolean;
		public var renderThis:Boolean = true;
		public var distanceToFocusPoint		:Number;
		
		public function Piller(materials:MovieMaterialsForFaces , theName:String , xW:Number , yW:Number , zW:Number)		
		{	
			
			super(theName,xW,yW,zW,"quad",1);
			this.container.mouseEnabled = false;
			materials.applyObject(this);
			
		}
		
		
		public function changeTopFace(app:Appearance):void
		{
			if (topFaceAppearance == null) topFaceAppearance = aPolygons[1].appearance;
			aPolygons[1].appearance = app;
		}
		
		public function recoverTopFace():void
		{
			if (topFaceAppearance != null) aPolygons[1].appearance = topFaceAppearance;
		}
		
		override public function destroy():void
		{
			topFaceAppearance = null;
			super.destroy();
		}	
	}
}