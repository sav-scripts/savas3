package sav.class3d.materials
{
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Transform;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	import sandy.materials.MovieMaterial;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.Appearance;

	public class MovieMaterialsForFaces
	{
		private var materials:Array;
		private var sideHeight:uint = 11;
		private var numFaces:uint = 6;
		
		private	var sin180			:Number = Math.sin(Math.PI);
		private	var cos180			:Number = Math.cos(Math.PI);
		private	var sin90			:Number = Math.sin(Math.PI/2);
		private	var cos90			:Number = Math.cos(Math.PI/2);
		private	var sin270			:Number = Math.sin(Math.PI*3/2);
		private	var cos270			:Number = Math.cos(Math.PI*3/2);

		public function MovieMaterialsForFaces(TextureClass:Class , SideTextureClass:Class, pillerHeight:Number , rotate:Number = 0 , xWidth:uint = 100 , yWidth:uint = 100 , zWidth:uint = 100)
		{
			materials = [];
			
			var sideTexture		= new SideTextureClass();
			var tempBitmapData = new BitmapData(xWidth , yWidth);	
			tempBitmapData.draw(sideTexture);			
			
			var mc				= new TextureClass();
			var side			= mc.side;
			var sideHeight		= (side != undefined) ? side.height : 0;
			
			for (var i=0; i<numFaces; i++) 
			{								
				if (side != undefined)
				{
					if (i>=2) 
					{
						side.visible = true;
						var newSideHeight = sideHeight*mc.height/pillerHeight;
						side.height = (sideHeight < pillerHeight) ? newSideHeight:mc.height;
					} 
					else
					{							
						side.visible = false;
					}
				}
				
				if (i== 0)
				{
					var face = mc.getChildAt(mc.numChildren-1);
					rotateFace(face , rotate);
				}
				
				
				var material;
				var bitmapData;
				if (i > 1)
				{	
					bitmapData		= (i>3) ? new BitmapData(pillerHeight , xWidth  , false) : new BitmapData(xWidth , pillerHeight, false);	
					material		= new BitmapMaterial(bitmapData);
					
					var tempBitmapData2 = new BitmapData(xWidth , sideHeight , true , 0x00ffffff);
					tempBitmapData2.draw(side);
					
					var shape = new Shape();
					shape.graphics.beginBitmapFill(tempBitmapData, null , true);
					shape.graphics.drawRect(0,0,xWidth , pillerHeight);
					shape.graphics.beginBitmapFill(tempBitmapData2);
					shape.graphics.drawRect(0,0,xWidth , sideHeight);
					
					var transform = getTransform(i , xWidth , pillerHeight);
					bitmapData.draw(shape , transform.matrix , transform.colorTransform);
					tempBitmapData2.dispose();				
					
				}
				else
				{
					bitmapData		= new BitmapData(xWidth,yWidth,false);
					material		= new BitmapMaterial(bitmapData);
					bitmapData.draw(mc);
				}

				material.smooth = true;
				materials[i] = material;
			}
			tempBitmapData.dispose();
		}
		
		//將儲存的材質套用到物件的每個面上
		public function applyObject(obj:*):void
		{			
			for (var i=0;i<materials.length;i++)
			{
				var appearance:Appearance = new Appearance(materials[i]);
				obj.aPolygons[i].appearance = appearance;
				
				//if(i==1) obj.topFaceAppearance = appearance;			
			}			
		}
		
		private function getTransform(faceIndex:int , w:uint , h:uint):Object
		{
			var matrix				= new Matrix();
			var colorTransform		= new ColorTransform();
			var transform = new Object();
			if (faceIndex == 2)
			{				
				matrix.a = cos180;
				matrix.b = sin180;
				matrix.c = -sin180;
				matrix.d = cos180;
				
				matrix.tx = w;
				matrix.ty = h;				
			}
			else if(faceIndex == 3)
			{
				colorTransform.redOffset	= -80;
				colorTransform.greenOffset	= -80;
				colorTransform.blueOffset	= -80;
			}
			else if(faceIndex == 4)
			{
				matrix.a = cos90;
				matrix.b = sin90;
				matrix.c = -sin90;
				matrix.d = cos90;
				
				matrix.tx = h;
				
				colorTransform.redOffset	= -40;
				colorTransform.greenOffset	= -40;
				colorTransform.blueOffset	= -40;
				
			}
			else if(faceIndex == 5)
			{
				matrix.a = cos270;
				matrix.b = sin270;
				matrix.c = -sin270;
				matrix.d = cos270;
				
				matrix.ty = w;
				colorTransform.redOffset	= -40;
				colorTransform.greenOffset	= -40;
				colorTransform.blueOffset	= -40;
			}
			transform.matrix = matrix;
			transform.colorTransform = colorTransform;
			
			return transform;
		}
		
		private function rotateFace(face:DisplayObject , rotate:int):void
		{					
			if (rotate == 1)
			{
				face.rotation = 90;
				face.x += 100;
			}
			else if(rotate == 2)
			{
				face.rotation = 180;
				face.x += 100;
				face.y += 100;
			}
			else if(rotate == 3)
			{
				face.rotation = 270;
				face.y += 100;
			}
		}
	}
}