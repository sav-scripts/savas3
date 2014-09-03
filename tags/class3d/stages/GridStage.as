package sav.class3d.stages
{
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.filters.DropShadowFilter;
	import sav.class3d.stageitems.AreaSurfaceItem;
	import sav.class3d.stageitems.AreaSurfaceShape;
	
	import sandy.core.Scene3D;
	import sandy.core.data.*;
	import sandy.core.scenegraph.*;
	import sandy.materials.*;
	import sandy.materials.attributes.*;
	import sandy.primitive.*;
	import sandy.math.*;
	
	import sav.class3d.cameras.*;
	import sav.class3d.textures.GridStageTexture;
	import sav.class3d.managers.CameraManager;
	import sav.class3d.stageitems.Piller;
	import sav.class3d.stageitems.Area;
	
	public class GridStage extends Stage3D
	{		
		//規格參數
		private var startX					:Number;
		private var startY					:Number;		
		private var spriteWidth				:uint;
		private var spriteHeight			:uint;
		private var numLines				:uint;
		private var numRows					:uint;		
		
		public var gridWidth				:uint = 100;
		public var gridHeight				:uint = 100;
		public var levelGap					:uint = 30;
		
		private var numMapRows				:uint;
		private var numMapLines				:uint;
		private var currentMapName			:String;
		
		public var gridStageTexture			:GridStageTexture;
		
		public var areaArray				:Array;		
		public var areaScreenArray			:Array;
		
		public function GridStage()
		{
			mouseEnabled = false;
			cacheAsBitmap = true;
		}

		public function init(sw:uint = 100 , sh:uint = 100):void
		{					
			alwaysRenderingObjects	= [];
			areaArray				= [];
			areaScreenArray			= [];
			spriteWidth				= sw
			spriteHeight			= sh;
			camera					= new ModfiedCamera(spriteWidth , spriteHeight , 45 , 0);
			cameraMotion			= new CameraMotion(camera , renderAll , this);
			gridStageTexture		= new GridStageTexture();
			cameraManager			= new CameraManager(this);
			cameraManager.init();
			cameraManager.lock();
		}
		
		override public function reset(excuteDestroy:Boolean = true):void
		{			
			if(excuteDestroy) destroy();
			alwaysRenderingObjects	= [];
			camera					= new ModfiedCamera(spriteWidth , spriteHeight , 45 , 0);
			cameraMotion			= new CameraMotion(camera , renderAll , this);			
			cameraManager			= new CameraManager(this);
			cameraManager.init();
			cameraManager.lock();
		}
		
		override public function destroy():void
		{
			cameraManager.lock();
			alwaysRenderingObjects	= [];
			areaArray				= [];
			scene.root.destroy();
			scene.dispose();
			camera.destroy();
			cameraManager.destroy();
			
			
		}

		public function buildSceneFromXml(xml:XML , textureAsset:LoaderInfo , doApplyFilters:Boolean = true):void
		{
			areaArray				= [];
			var group				= new Group();
			
			numLines			= Number(xml.numLines);
			numRows				= Number(xml.numRows);
			gridWidth			= Number(xml.gridWidth);
			gridHeight			= Number(xml.gridHeight);
			levelGap			= Number(xml.levelGap);
			var rowWidth:Number	= gridWidth*(numLines-1);
			var lineWidth:Number= gridHeight*(numRows-1);
			startX				= -rowWidth / 2;
			startY				= -lineWidth / 2;			
			var zoomRate:Number = Number(xml.zoomRate);
			
			gridStageTexture.buildTexture(xml , textureAsset);			
			
			for (var row=0; row<numRows; row++) 
			{
				areaArray[row] = [];
				
				for (var line=0; line<numLines; line++) 
				{
					var areaData			= xml.row[row].line[line];
					var area				= buildArea(line , row , areaData , group);
				}
			}
			
			group.useSingleContainer = true;		
			scene = new Scene3D("scene" , this , camera , group);
			camera.zoomRate = zoomRate;
			if (doApplyFilters) applyFilters();
		}		
		
		public function buildArea(line:uint , row:uint , areaData:XML , group:Group):void
		{	
		
			var level				= Number(areaData.@level);
			var texture				= String(areaData.@texture);
			var rotate				= Number(areaData.@rotate);
			var textureName			= texture+'Level_' + level + '_' + rotate;			
			var areaName			= 'area_' + line + '_' + row;
			
			var area			= new Area(areaName ,row , line , level , levelGap , gridWidth , gridHeight);	
			area.gridStage		= this;
			area.x				= startX + gridWidth * line;
			area.y				= startY + gridHeight * row;
			area.z				= 0;
			
			var materials		= gridStageTexture.getTexture(textureName);
			area.setPiller(materials);	
			
			group.addChild(area);
			areaScreenArray.push(area);
			areaArray[row][line] = area;						
		}
		
		public function changeAreaLevel(line:uint , row:uint , level:int , materialName:String):void
		{
		}
		
		public function removeArea(line:uint , row:uint):void
		{
			var area = areaArray[row][line];
			if (area.areaSurfaceShape) 
			{
				removeAlwaysRenderingObject(area.areaSurfaceShape);
				area.areaSurfaceShape.alwaysRenderThis = false;
				area.removeSurfaceShape();
				//area.areaSurfaceShape.destroy();
			}			
			
			area.destroy();
			areaArray[row][line] = undefined;
			var index = areaScreenArray.indexOf(area);
			areaScreenArray.splice(index , 1);
		}
		
		public function applyFilters():void
		{
			var filterArray = new Array();
			var glow = new GlowFilter(0,1,2,2,1,1);
			var shadow = new DropShadowFilter(3,90,0x000000,0.5,5,5);
			filterArray = [glow,shadow];
			filters = filterArray;
		}
		
		public function removeFilters():void
		{
			filters = [];
		}
		
		public function autoRenderOn():void
		{
			cameraManager.cameraRenderOver();
		}
		
		//render整個場景，通常是camera調整後使用
		public override function renderAll():void
		{						
			clear();
			scene.render(true,false);
			sortDepths();
		}
		
		//render存放在alwaysRenderingObjects這個陣列中的物件
		public override function renderParticle():void
		{		
			if(renderParticleOn) scene.render(true,false);	
		}
		
		//設定所有的物件為停止render的狀態，然後將alwaysRenderingObjects這個陣列中的物件設定為啟動render的狀態
		public override function setAllToStopRender():void
		{
			//applyFilters();
			for each(var area in areaScreenArray) 				area.setAlwaysRenderThisTo(false);
			for each(var shape3D in alwaysRenderingObjects)		shape3D.alwaysRenderThis = true;
		}
		
		//啟動所有物件的render
		public override function setAllToStartRender():void
		{
			for each(var area in areaScreenArray) area.setAlwaysRenderThisTo(true);
		}
		
		public override function clear():void
		{
			for each(var area:Area in areaScreenArray)
			{
				area.piller.clear();								
				
				for each(var areaSurfaceShape:AreaSurfaceShape in area.areaSurfaceShapeArray)
				{
					areaSurfaceShape.clear();
				}
				
				for each(var areaSurfaceItem:AreaSurfaceItem in area.areaSurfaceItemArray)
				{
					areaSurfaceItem.clear();
				}
			}
		}
		
		//重新整理物件深度
		private function sortDepths():void
		{
			var focusPoint = camera.viewerPoint;
			var theParent;
			for each (var area:Area in areaScreenArray) 
			{				
				var oldX:Number		= area.x;
				var oldY:Number		= area.y;				
				var arc:Number		= camera.yawDegree/180*Math.PI;
				var newX:Number		= Math.cos(-arc)*oldX - Math.sin(-arc)*oldY;
				var newY:Number		= Math.cos(-arc)*oldY + Math.sin(-arc)*oldX;				
				var dx:Number		= focusPoint.x - newX;
				var dy:Number		= focusPoint.y - newY;
				
				area.distanceToFocusPoint = Math.sqrt(dx*dx+dy*dy);
				
				if (area.areaSurfaceItemArray.length > 0)
				{
					for each(var item:AreaSurfaceItem in area.areaSurfaceItemArray)
					{
						oldX	= area.x + item.x;
						oldY	= area.y + item.y;								
						arc		= camera.yawDegree/180*Math.PI;
						newX	= Math.cos(-arc)*oldX - Math.sin(-arc)*oldY;
						newY	= Math.cos(-arc)*oldY + Math.sin(-arc)*oldX;				
						dx		= focusPoint.x - newX;
						dy		= focusPoint.y - newY;
				
						item.distanceToFocusPoint = Math.sqrt(dx*dx+dy*dy);						
					}
					area.areaSurfaceItemArray.sortOn('distanceToFocusPoint',Array.NUMERIC| Array.DESCENDING);
				}

			}			
			areaScreenArray.sortOn('distanceToFocusPoint',Array.NUMERIC| Array.DESCENDING);
			
			for each(area in areaScreenArray) 
			{				
				addChild(area.piller.container);
				
				for each(var areaSurfaceShape:AreaSurfaceShape in area.areaSurfaceShapeArray)
				{
					addChild(areaSurfaceShape.container);
				}
				
				for each(var areaSurfaceItem:AreaSurfaceItem in area.areaSurfaceItemArray)
				{
					addChild(areaSurfaceItem.container);
				}				
			}						
			
		}
	}
}