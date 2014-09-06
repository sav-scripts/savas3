package sav.box2d
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2DSeparator.b2Separator;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	public class SavBox2D extends Object
	{
		public function SavBox2D(scaleFactor:Number = 30, gravityX:Number = 0, gravityY:Number = 0, doSleep:Boolean = true, withDebugDraw:Boolean = true):void
		{
			_draggingDic = new Dictionary();
			
			_SF = scaleFactor;
			_world = new b2World(new b2Vec2(gravityX, gravityY), doSleep);
			if (withDebugDraw) createDebugDraw();
		}
		
		public function createDebugDraw():Sprite
		{
			if (_debugDraw) throw new Error("DebugDraw already created");
			
			_debugDraw = new b2DebugDraw();
			_debugDrawSprite = new Sprite();
			_debugDraw.SetSprite(_debugDrawSprite);
			_debugDraw.SetDrawScale(_SF);
			_debugDraw.SetLineThickness(1);
			_debugDraw.SetFlags(b2DebugDraw.e_jointBit | b2DebugDraw.e_shapeBit);
			_world.SetDebugDraw(_debugDraw);
			
			_debugDraw.SetFillAlpha(.5);
			
			return _debugDrawSprite;
		}
		
		/************************
		*     body creates
		************************/
		/// create zone
		public function createCloseZone(x:Number, y:Number, width:Number, height:Number, size:Number):void
		{	
			createBox(0, x + size, y, width - size * 2, size);
			createBox(0, x + width - size, y, x + width, height);
			createBox(0, x + size, y + height - size, width - size * 2, size);
			createBox(0, x, y, size, height);
		}
		
		/// create box
		public function createBox(
			type:int,
			x:Number, y:Number, 
			width:Number, height:Number,
			fixtureDefParams:Object = null):b2Body
		{
			var halfWidth:Number = width / _SF / 2;
			var halfHeight:Number = height / _SF / 2;
			
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = type;
			bodyDef.position.Set(x / _SF + halfWidth, y / _SF + halfHeight);
			
			var body:b2Body = _world.CreateBody(bodyDef);
			
			var shape:b2PolygonShape = new b2PolygonShape();
			shape.SetAsBox(halfWidth, halfHeight);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = shape;
			fixtureDef.density = default_density;
			fixtureDef.friction = default_friction;
			fixtureDef.restitution = default_restition;
			
			var key:String;
			if (fixtureDefParams != null) for (key in fixtureDefParams) fixtureDef[key] = fixtureDefParams[key];
			
			var fixture:b2Fixture = body.CreateFixture(fixtureDef);
			
			return body;
		}
		
		public function attachBox(
			body:b2Body, 
			dx:Number, dy:Number, width:Number, height:Number, 
			density:Number = 3):b2Fixture
		{	
			dx /= _SF;
			dy /= _SF;
			width /= _SF;
			height /= _SF;
			
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			vertices.push(new b2Vec2(dx, dy));
			vertices.push(new b2Vec2(dx+width, dy));
			vertices.push(new b2Vec2(dx+width, dy+height));
			vertices.push(new b2Vec2(dx, dy + height));
			
			var shape:b2PolygonShape = new b2PolygonShape();
			shape.SetAsVector(vertices, vertices.length);
			
			return body.CreateFixture2(shape, density);
		}
		
		/// create wheel
		public function createWheel(
			type:int, 
			x:Number, y:Number, radius:Number,
			fixtureDefParams:Object = null):b2Body
		{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = type;
			bodyDef.position.Set(x / _SF, y / _SF);
			
			var body:b2Body = _world.CreateBody(bodyDef);
			
			var shape:b2CircleShape = new b2CircleShape(radius / _SF);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = shape;
			fixtureDef.density = default_density;
			fixtureDef.friction = default_friction;
			fixtureDef.restitution = default_restition;
			
			var key:String;
			if (fixtureDefParams != null) for (key in fixtureDefParams) fixtureDef[key] = fixtureDefParams[key];
			
			var fixture:b2Fixture = body.CreateFixture(fixtureDef);
			
			return body;
		}
		
		public function attachWheel(
			body:b2Body, 
			dx:Number, dy:Number, radius:Number, 
			density:Number = 3):b2Fixture
		{
			var shape:b2CircleShape = new b2CircleShape(radius / _SF);
			shape.SetLocalPosition(new b2Vec2(dx / _SF, dy / _SF));
			return body.CreateFixture2(shape, density);
		}
		
		/// create polygon
		public function createPolygon(
			type:int, 
			x:Number, y:Number, vertices:Vector.<b2Vec2>,
			fixtureDefParams:Object = null):b2Body
        {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = type;
            bodyDef.position.Set(x/_SF , y/_SF);
			
            var body:b2Body = _world.CreateBody(bodyDef);
			
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.density = default_density;
			fixtureDef.friction = default_friction;
			fixtureDef.restitution = default_restition;
			
			var key:String;
			if (fixtureDefParams != null) for (key in fixtureDefParams) fixtureDef[key] = fixtureDefParams[key];
			
			var separtor:b2Separator = new b2Separator();
			var result:int = separtor.Validate(vertices);
			
			if (result == 0)
			{
				separtor.Separate(body, fixtureDef, vertices,1);
			}
			else if (result == 2)
			{
				var newVertices:Vector.<b2Vec2> = vertices.reverse();
				separtor.Separate(body, fixtureDef, newVertices);
			}
			else
			{
				trace("unable create polygon, test result = " + result);
				return null;
			}
			
			return body;
        }
		
		/************************
		*      alter body
		************************/
		public function offsetBodyCenter(body:b2Body, offsetX:Number, offsetY:Number, resetToSameWorldCenter:Boolean = false):void
		{
			offsetX = offsetX / _SF;
			offsetY = offsetY / _SF;
			
			var fixture:b2Fixture = body.GetFixtureList();
			var shape:b2Shape;
			var polygonShape:b2PolygonShape;
			var circleShape:b2CircleShape;
			var vertices:Vector.<b2Vec2>;
			var vec:b2Vec2;
			
			while (fixture)
			{
				shape = fixture.GetShape();
				if (shape is b2PolygonShape)
				{
					vertices = b2PolygonShape(shape).GetVertices();
					for each(vec in vertices)
					{
						vec.x += offsetX;
						vec.y += offsetY;
					}
				}
				else if (shape is b2CircleShape)
				{
					vec = b2CircleShape(shape).GetLocalPosition();
					vec.x += offsetX;
					vec.y += offsetY;
				}
				else
				{
					throw Error("unexpected b2Shape type : " + shape);
				}
				
				fixture = fixture.GetNext();
			}
			
			if (resetToSameWorldCenter)
			{
				vec = body.GetWorldCenter();
				vec.x -= offsetX;
				vec.y -= offsetY;
				body.SetPosition(vec);
			}
		}
		
		/************************
		*      interactives
		************************/
		public function hitTestBody(x:Number, y:Number):b2Body
		{
			var vec:b2Vec2 = new b2Vec2(x / _SF, y / _SF);
			var body:b2Body;
			
			function callBack(fixture:b2Fixture):void
			{
				if (fixture == null) return;
				body = fixture.GetBody();
			}
			
			_world.QueryPoint(callBack, vec);
			return body;
		}
		
		public function startDrag(body:b2Body, x:Number, y:Number, power:Number = 1000):void
		{
			if (_draggingDic[body])
			{
				updateDrag(body, x, y);
			}
			else
			{
				var mouseJointDef:b2MouseJointDef = new b2MouseJointDef();
				mouseJointDef.bodyA = _world.GetGroundBody();
				mouseJointDef.bodyB = body;
				mouseJointDef.target.Set(x / _SF, y / _SF);
				mouseJointDef.maxForce = power;
				
				var mouseJoint:b2MouseJoint = _world.CreateJoint(mouseJointDef) as b2MouseJoint;
				_draggingDic[body] = mouseJoint;
				_numDragging ++;
			}
		}
		
		public function stopDrag(body:b2Body):void
		{
			var mouseJoint:b2MouseJoint = _draggingDic[body];
			
			if (mouseJoint)
			{
				_world.DestroyJoint(mouseJoint);
				delete _draggingDic[body];
				_numDragging --;
			}
		}
		
		public function stopDragAll():void
		{
			for each(var mouseJoint:b2MouseJoint in _draggingDic)
			{
				_world.DestroyJoint(mouseJoint);
			}
			_draggingDic = new Dictionary();
			
			_numDragging = 0;
		}
		
		public function updateDrag(body:b2Body, x:Number, y:Number):void
		{
			var mouseJoint:b2MouseJoint = _draggingDic[body];
			if (mouseJoint)	mouseJoint.SetTarget(new b2Vec2(x / _SF, y / _SF));
		}
		
		public function updateDragAll(x:Number, y:Number):void
		{
			if (_numDragging <= 0) return;
			
			var vec:b2Vec2 = new b2Vec2(x / _SF, y / _SF);
			for each(var mouseJoint:b2MouseJoint in _draggingDic)
			{
				mouseJoint.SetTarget(vec);
			}
		}
		
		/************************
		*        utility
		************************/
		public function verticesMultiplyScaleFactor(vertices:Vector.<b2Vec2>):void
		{
			for each(var vector:b2Vec2 in vertices)
			{
				vector.x /= _SF;
				vector.y /= _SF;
			}
		}
		
		public function pointListToB2Vec2List(pointList:Vector.<Point>, multiplyWithScaleFactor:Boolean = true):Vector.<b2Vec2>
		{
			var point:Point;
			var i:int, l:int = pointList.length;
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			
			if (multiplyWithScaleFactor)
			{
				for (i = 0; i < l; i++)
				{
					point = pointList[i];
					vertices.push(new b2Vec2(point.x / _SF, point.y / _SF));
				}
			}
			else
			{
				for (i = 0; i < l; i++)
				{
					point = pointList[i];
					vertices.push(new b2Vec2(point.x, point.y));
				}
			}
			
			return vertices;
		}
		
		/************************
		*     static methods
		************************/
		public static function isBodyTouchBody(bodyA:b2Body, bodyB:b2Body):Boolean
		{
			var contactEdge:b2ContactEdge = bodyA.GetContactList();
			if (!contactEdge) return false;
			
			while (contactEdge)
			{
				if (contactEdge.contact.IsTouching() && contactEdge.other == bodyB) return true;
				contactEdge = contactEdge.next;
			}
			
			return false;
		}
		
		public static function isFixtureTouchBody(fixture:b2Fixture, bodyB:b2Body):Boolean
		{
			var bodyA:b2Body = fixture.GetBody();
			
			var contactEdge:b2ContactEdge = bodyA.GetContactList();
			if (!contactEdge) return false;
			
			while (contactEdge)
			{
				if (contactEdge.contact.IsTouching() && contactEdge.other == bodyB && (contactEdge.contact.GetFixtureB() == fixture || contactEdge.contact.GetFixtureA() == fixture)) return true;
				contactEdge = contactEdge.next;
			}
			
			return false;
		}
		
		/************************
		*         utils
		************************/
		public static function getString(obj:Object):String
		{
			if (obj is b2Vec2)
			{
				return '(' + obj.x + ', ' + obj.y + ')';
			}
			
			return obj.toString();
		}
		
		
		/************************
		*         params
		************************/
		private var _world:b2World;
		public function get world():b2World { return _world; }
		
		private var _debugDraw:b2DebugDraw;
		public function get debugDraw():b2DebugDraw { return _debugDraw; }
		
		private var _debugDrawSprite:Sprite;
		public function get debugDrawSprite():Sprite { return _debugDrawSprite; }
		
		private var _SF:Number;
		public function get scaleFactor():Number { return _SF; }
		
		private var _draggingDic:Dictionary;
		private var _numDragging:int = 0;
		
		/// body fixture define default values
		public var default_density:Number = 3;
		public var default_friction:Number = .3;
		public var default_restition:Number = .2;
	}
}
