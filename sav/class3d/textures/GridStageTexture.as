package sav.class3d.textures
{
	//import flash.system.ApplicationDomain;
	
	import flash.display.MovieClip;
	import flash.display.LoaderInfo;
	import sandy.materials.MovieMaterial;
	
	import sav.class3d.materials.*;
	
	public class GridStageTexture
	{		
		public var textureArray			:Array;
		public var miscTextureArray		:Array;
		
		private var levelGap			:uint;
		private var gridWidth			:uint;
		private var gridHeight			:uint;
		
		public function GridStageTexture()
		{
			//buildMiscTextures();
		}
		
		public function buildTexture(xml:XML , textureAsset:LoaderInfo):void
		{
			textureArray = [];
									
			var materials;
			var numLines			= Number(xml.numLines);
			var numRows				= Number(xml.numRows);
			var sideTexture			= String(xml.sideTexture);
			var sideTextureClass	= textureAsset.applicationDomain.getDefinition(sideTexture) as Class
			levelGap				= Number(xml.levelGap);
			gridWidth				= Number(xml.gridWidth);
			gridHeight				= Number(xml.gridHeight);

			
			for (var row=0;row<numRows;row++)
			{
				var rowConfig	= xml.row[row];
				
				for (var line=0;line<numLines;line++)
				{
					var lineConfig			= rowConfig.line[line];
					buildSingleTexture(lineConfig , textureAsset , sideTextureClass);
				}
			}
		}
		
		public function buildSingleTexture(xml:XML , textureAsset:Object , sideTextureClass:Class):void
		{
			var texture				= String(xml.@texture);
			var level				= Number(xml.@level);
			var rotate				= (Number(xml.@rotate)) ? Number(xml.@rotate) : 0;
			var textureName			= texture+'Level_' + level + '_' + rotate;
			var pillerHeight		= (30*level > 1) ? 30*level : 1;
			
			if (textureArray[textureName] == undefined)
			{
				var textureClass = textureAsset.applicationDomain.getDefinition(texture) as Class;
				var materials = new MovieMaterialsForFaces(textureClass , sideTextureClass , pillerHeight , rotate);
				textureArray[textureName] = materials;
			}
		}
		
		public function getTexture(textureName:String):MovieMaterialsForFaces
		{
			return textureArray[textureName];
		}
		
		/*
		public function buildMiscTextures():void
		{
			miscTextureArray			= [];
			buildMiscTexture('MoveUp');			
			buildMiscTexture('MoveRight');
			buildMiscTexture('MoveDown');
			buildMiscTexture('MoveLeft');			
		}
		
		public function buildMiscTexture(theName:String):void
		{
			var MovieClass				= main.resources.getClass(theName,'PillerTexturePack');
			var movieClip				= new MovieClass();
			var material				= new MovieMaterial(movieClip,40);
			miscTextureArray[theName]	= material;			
		}
		*/
		
	}
}