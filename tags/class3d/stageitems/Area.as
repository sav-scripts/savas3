package sav.class3d.stageitems
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	
	import sandy.core.scenegraph.TransformGroup;
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Sprite2D;
	
	import sav.class3d.stages.GridStage;
	import sav.class3d.materials.MovieMaterialsForFaces;
	
	public class Area extends TransformGroup
	{
		private var xWidth					:uint;
		private var yWidth					:uint;
		private var zWidth					:uint;
		
		public var pillerLevel				:int;		
		public var levelGap					:uint;
		public var areaSurfaceItemArray		:Array;
		public var areaSurfaceShapeArray	:Array;
		public var row						:uint;
		public var line						:uint;
		public var distanceToFocusPoint		:Number;
		public var piller					:Piller;
		public var gridStage				:GridStage;
		
		public function Area(myName:String , mr:uint , ml:uint , pl:int = 1 , lg:uint = 30 , xw:uint = 100 , yw:uint = 100)
		{
			useSingleContainer = true;
			
			row			= mr;
			line		= ml;
			pillerLevel = pl;
			levelGap	= lg;
			
			xWidth 		= xw;
			yWidth 		= yw;
			zWidth 		= pillerLevel * levelGap;			
			
			areaSurfaceItemArray = [];
			areaSurfaceShapeArray = [];
			
			super(myName);
		}
		
		public function changeLevel(pl:int , materials:MovieMaterialsForFaces):void
		{			
			pillerLevel = pl;
			zWidth 		= pillerLevel * levelGap;
			piller.destroy();
			setPiller(materials);
			
			if (areaSurfaceItemArray != null) areaSurfaceItemArray.z = -zWidth;
		}
		
		public function setPiller(materials:MovieMaterialsForFaces):void
		{
			piller			= new Piller(materials,'piller',xWidth,yWidth,zWidth);
			piller.z		=  -  zWidth / 2;
			addChild(piller);
			
			piller.container.mouseEnabled = false;	
			piller.container.name = row+'_'+line;
		}		
		
		public function addSurfaceItem(areaSurfaceItem:AreaSurfaceItem , x:int=0 , y:int=0 , z:int=0):void
		{
			var oldArea:Area = areaSurfaceItem.myArea;
			if (oldArea != null) oldArea.removeSurfaceItem(areaSurfaceItem);

			areaSurfaceItem.x				= x;
			areaSurfaceItem.y				= -y;
			areaSurfaceItem.z				= -zWidth - z;
			areaSurfaceItem.myArea			= this;
			areaSurfaceItemArray.push(areaSurfaceItem);
			addChild(areaSurfaceItem);
		}
		
		public function removeSurfaceItem(areaSurfaceItem:AreaSurfaceItem = null , removeFromDisplayList:Boolean = false):AreaSurfaceItem
		{
			if (areaSurfaceItem == null)
			{
				if (areaSurfaceItemArray.length == 0) return null;
				areaSurfaceItem = areaSurfaceItemArray[0];
			}
			
			var index:int = areaSurfaceItemArray.indexOf(areaSurfaceItem);
			removeChildByName(areaSurfaceItem.name);
			
			if (areaSurfaceItem.container.parent && removeFromDisplayList) 
				areaSurfaceItem.container.parent.removeChild(areaSurfaceItem.container);
			
			areaSurfaceItem.myArea = null;			
			areaSurfaceItemArray.splice(index , 1);
			
			return areaSurfaceItem;
		}		
		
		public function addSurfaceShape(areaSurfaceShape:AreaSurfaceShape):void
		{
			var oldArea:Area = areaSurfaceShape.myArea;
			if (oldArea != null) oldArea.removeSurfaceShape(areaSurfaceShape);

			areaSurfaceShape.z				= -zWidth - z;
			areaSurfaceShape.x				= 0;
			areaSurfaceShape.y				= 0;
			areaSurfaceShape.myArea			= this;
			areaSurfaceShapeArray.push(areaSurfaceShape);
			addChild(areaSurfaceShape);
		}
		
		public function removeSurfaceShape(areaSurfaceShape:AreaSurfaceShape = null , removeFromDisplayList:Boolean = false):AreaSurfaceShape
		{
			if (areaSurfaceShape == null)
			{
				if (areaSurfaceShapeArray.length == 0) return null;
				areaSurfaceShape = areaSurfaceShapeArray[0];
			}
			
			var index:int = areaSurfaceShapeArray.indexOf(areaSurfaceShape);			
			
			areaSurfaceShape.clear();
			areaSurfaceShape.myArea		= null;
			if (areaSurfaceShape.container.parent && removeFromDisplayList) 
				areaSurfaceShape.container.parent.removeChild(areaSurfaceShape.container);
				
			areaSurfaceShapeArray.splice(index , 1);	
				
			return areaSurfaceShape;
		}
		
		public function setAlwaysRenderThisTo(boolean:Boolean):void
		{
			if(piller)						piller.alwaysRenderThis = boolean;
			
			if(areaSurfaceShapeArray.length > 0)
			{
				for each(var areaSurfaceShape:AreaSurfaceShape in areaSurfaceShapeArray)
				{
					areaSurfaceShape.alwaysRenderThis = boolean;					
				}
			}
			
			if(areaSurfaceItemArray.length > 0)
			{
				for each(var areaSurfaceItem:AreaSurfaceItem in areaSurfaceItemArray)
				{
					areaSurfaceItem.alwaysRenderThis = boolean;					
				}
			}
		}
		
		override public function destroy():void
		{			
			areaSurfaceItemArray = null;
			areaSurfaceShapeArray = null;
			piller = null;
			gridStage = null;
			
			super.destroy();
		}
	}
}