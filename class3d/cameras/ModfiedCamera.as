package sav.class3d.cameras
{ 
	import flash.display.Sprite;
	
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.Scene3D;
	import sandy.math.*;
	import sandy.util.NumberUtil;
	import sandy.core.data.Point3D;

	public class ModfiedCamera extends Camera3D
	{
		//yawDegree和tilt意義上不同
		//yawDegree是相機位置和場景中心Z軸的角度
		//tilt是相機相對於XY平面的仰角
		public var center				:Point3D = new Point3D(0,0,0);
		public var viewerPoint			:Point3D = new Point3D(0,-2700,0);
		public var minZoomDistance		:Number = 50;
		public var yawDegree			:Number = 0;
		
		private var _zoomRate			:Number = 0;

		private var lastNorm			:Point3D;
		//private var axisZRotated		:Number = 0;

		public function ModfiedCamera(stageW:uint,stageH:uint,fov:Number=45,near:Number=50,far:Number=10000)
		{
			super(stageW,stageH,fov,near,far);
		}
		
		//讓攝影機繞著中心旋轉
		//攝影機改變位置後，會再調整z軸旋轉以對準中心
		public function yaw(degree:Number):void
		{
			rotateAxis(0,0,1,-yawDegree);//先把相機的水平旋轉歸零
			
			yawDegree = (yawDegree + 360 + degree) % 360;			
			
			var dx:Number		= x-center.x;
			var dy:Number 		= y-center.y;
			var length:Number 	= Math.sqrt(dx * dx + dy * dy);
			var arc:Number		= Math.atan2(dy,dx) + degree / 180 * Math.PI;
			
			var newX			= length * Math.cos(arc);
			var newY			= length * Math.sin(arc);
			
			x = newX;
		    y = newY;			
			
			rotateAxis(0,0,1,yawDegree);			
		}

		//縮放鏡頭
		public function zoom(dd:Number,changeViewerPoint:Boolean = false):void
		{
			_zoomRate += dd;
			
			var vector=new Point3D(x,y,z);
			var distance=vector.getNorm();

			distance = Math.max((distance-dd),minZoomDistance);

			vector.normalize();
			vector.scale(distance);
			if (changeViewerPoint)
			{
				var dx		= vector.x - x;
				var dy		= vector.y - y;
				var arc		= yawDegree/180*Math.PI;
				var tx		= Math.cos(-arc)*dx - Math.sin(-arc)*dy;
				var ty		= Math.cos(-arc)*dy + Math.sin(-arc)*dx;
			}

			setPosition(vector.x,vector.y,vector.z);
		}
		
		public function get zoomRate():Number { return _zoomRate;}
		
		public function set zoomRate(zoomValue:Number):void
		{
			var d:Number = zoomValue - _zoomRate;
			if (d != 0) zoom(d);			
		}
		
		//移動攝影機到某個點
		//lookAtCenter為true的話，移動後將攝影機對準中心點(以攝影機保持水平平衡的方式)
		public function moveTo(tx:Number,ty:Number,tz:Number,lookAtCenter:Boolean = false):void
		{
						
			if (lookAtCenter)
			{
				rotateAxis(0,0,1,-yawDegree);//先把相機的水平旋轉歸零
				
				x = tx;
				y = ty;
				z = tz;
				
				yawDegree = Math.atan2(y,x)/Math.PI*180+90;				
				
				var dx:Number = x-center.x;
				var dy:Number = y-center.y;
				var dz:Number = z-center.z;
				var positionPoint3D:Point3D	= new Point3D(-dx,-dy,-dz);
				var projectXYPoint3D:Point3D	= new Point3D(-dx,-dy,0);//投影在XY平面上的座標
				
				tilt = Point3DMath.getAngle(projectXYPoint3D,positionPoint3D)/Math.PI*180 - 90;			
				
				rotateAxis(0,0,1,yawDegree);
				//trace('yaw = ' + int(yawDegree));
			} else {
				x = tx;
				y = ty;
				z = tz;
			}			
		}

		//以螢幕座標域為參考，執行攝影機的XY平面移動
		public function screenMove(tx:Number,ty:Number,moveSprite:Boolean = false):void
		{			
			if (moveSprite) 
			{
				scene.container.x += tx;
				scene.container.y += ty;
			}
			else 
			{
				var arc:Number = yawDegree/180*Math.PI;
				var dx:Number = Math.cos(arc)*tx - Math.sin(arc)*ty;
				var dy:Number = Math.cos(arc)*ty + Math.sin(arc)*tx;
				moveTo(x+dx,y+dy,z,false);
				viewerPoint.x += tx;
				viewerPoint.y += ty;
			}			
		}
		
		
	}

}