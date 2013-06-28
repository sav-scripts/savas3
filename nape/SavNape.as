package sav.nape 
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	import nape.constraint.PivotJoint;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Broadphase;
	import nape.space.Space;
	import nape.util.Debug;
	import nape.util.ShapeDebug;
	/**
	 * ...
	 * @author sav
	 */
	public class SavNape 
	{
		public function SavNape(gravityX:Number = 0, gravityY:Number = 400, broadphase:Broadphase = null)
		{
			_space = new Space(new Vec2(gravityX, gravityY), broadphase);
		}
		
		/**** body creators ****/
		public function createCircleBody(bodyType:BodyType, centerX:Number, centerY:Number, radius:Number, localCOM:Vec2 = null, material:Material = null, filter:InteractionFilter = null):Body
		{
			var body:Body = new Body(BodyType.DYNAMIC, new Vec2(centerX, centerY));
			body.shapes.add(new Circle(radius, localCOM, material, filter));
			body.space = _space;
			
			return body;
		}
		
		public function createBoxBody(bodyType:BodyType, centerX:Number, centerY:Number, width:Number, height:Number, material:Material = null, filter:InteractionFilter = null):Body
		{
			var body:Body = new Body(bodyType, new Vec2(centerX, centerY));
			var shape:Polygon = new Polygon(Polygon.box(width, height, false));
			body.shapes.add(shape);
			body.space = _space;
			
			return body;
		}
		
		public function createPolygonBody(bodyType:BodyType, centerX:Number, centerY:Number, vecList:Vector.<Vec2>, material:Material = null, filter:InteractionFilter = null):Body
		{
			var body:Body = new Body(BodyType.DYNAMIC, new Vec2(centerX, centerY));
			body.shapes.add(new Polygon(vecList, material, filter));
			body.space = _space;
			
			return body;
		}
		
		public function createCloseArea(x:Number, y:Number, width:Number, height:Number, size:Number = 10):void
		{
			var d:Number = size / 2;
			createBoxBody(BodyType.STATIC, x + width / 2, y - d, width, size);
			createBoxBody(BodyType.STATIC, x + width / 2, y + height + d, width, size);
			createBoxBody(BodyType.STATIC, x - d, y + height / 2, size, height);
			createBoxBody(BodyType.STATIC, x +width + d, y + height / 2, size, height);
		}
		
		/**** drag ****/
		public function startDragBodyList(bodyList:BodyList, x:Number, y:Number):void
		{
			stopDragAllBodyList();
			
			_draggingBodyJointDic = new Dictionary();
			
			var a:Number = 100;
			var draggingVec:Vec2 = new Vec2(x, y);
			bodyList.foreach(function(body:Body):void
			{
				startDragBodyList_startDragBody(body, x, y);
			});
		}
		
		private function startDragBodyList_startDragBody(body:Body, x:Number, y:Number):void
		{
			var worldBody:Body = _space.world;
            var joint:PivotJoint = new PivotJoint(worldBody, body, Vec2.weak(x, y), body.worldPointToLocal(Vec2.weak(x, y)));
            joint.stiff = false;
			joint.space = _space;
			
			_draggingBodyJointDic[body] = joint;
		}
		
		public function updateDragging(x:Number, y:Number):void
		{
			if (!_draggingBodyJointDic) return;
			
			var joint:PivotJoint;
			for each(joint in _draggingBodyJointDic) joint.anchor1.setxy(x, y);
		}
		
		public function stopDragAllBodyList():void
		{
			if (_draggingBodyJointDic)
			{
				var joint:PivotJoint;
				
				for each(joint in _draggingBodyJointDic)
				{
					joint.body1 = null;
					joint.body2 = null;
					joint.space = null;
				}
				
				_draggingBodyJointDic = null;
			}
		}
		
		/**** utils ****/
		public function buildDebug(container:DisplayObjectContainer, width:Number, height:Number, drawConstraints:Boolean = true, bgColor:int = 3355443):void
		{
			_debug = new ShapeDebug(width, height, bgColor);
			_debug.drawConstraints = drawConstraints;
			if (container) container.addChild(_debug.display);
		}
		
		public function updateDebug():void
		{
			if (_debug)
			{
				_debug.clear();
				_debug.flush();
				_debug.draw(_space);
			}
		}
		
		/**** params ****/
		private var _space:Space;
		public function get space():Space { return _space; }
		
		private var _debug:ShapeDebug;
		public function get debug():ShapeDebug { return _debug; }
		
		private var _draggingBodyJointDic:Dictionary;
	}
}