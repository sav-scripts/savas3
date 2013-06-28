package sav.effects.swarm
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.display.PixelSnapping;
	import flash.utils.getTimer;
	import sav.utils.ArrayUtils;
	import sav.effects.swarm.swarm_namespace;
	use namespace swarm_namespace;
	
	[Event(name = 'complete', type = 'flash.events.Event')]
	
	public class Swarmer extends EventDispatcher
	{
		swarm_namespace var test:Number = 100;
		
		private var theParent:DisplayObjectContainer;			// sourceClip's parent
		private var stageBound:Rectangle;						// bound of stage local size in theParent
		
		private var canvasBound:Rectangle;
		private var canvasScaleRate:Point;
		
		private var quality:Number = 1;
		private var mosaicOn:Boolean = true;
		
		private var lifeTime:Number;
		private var timePassed:Number;
		private var percent:Number;
		
		private var swarmPath:SwarmPath;	
		private var currentSwarmPathIndex:uint;
		
		public var bitmap:Bitmap;
		
		
		private var numLines:uint;
		private var numRows:uint;
		private var points:Array;
		
		private var pointsNotShifted:Array;
		private var onShifting:Boolean = false;
		private var shiftingProgress:Number = 0;
		private var numShifted:uint = 0;
		private var percentToStartShift:Number = 0;
		private var percentToEndShift:Number = 0;
		private var percentTotalShift:Number = 1;
		private var currentSampleType:String = 'source';		
		
		private var randomX:Number;
		private var randomY:Number;
		
		private var pathProgress:Number;
		private var antiPathProgress:Number;
		private var fromPoint:SwarmPathPoint;
		private var towardingPoint:SwarmPathPoint;
		
		private var numRenderTimer:uint = 0;
		private var numRendered:uint = 0;
		
		public function Swarmer(sourceClip:DisplayObject , params:Object = null)
		{	
			var t:uint = getTimer();
			
			theParent = sourceClip.parent;
						
			var stageWidth:uint = theParent.stage.stageWidth;
			var stageHeight:uint = theParent.stage.stageHeight;
			var stageLeftTop:Point = theParent.globalToLocal(new Point(0, 0));
			var stageRightBottom:Point = theParent.globalToLocal(new Point(stageWidth, stageHeight));
			stageBound = new Rectangle(stageLeftTop.x, stageLeftTop.y, stageRightBottom.x - stageLeftTop.x, stageRightBottom.y - stageLeftTop.y);
			
			var bitmapScaleX:Number = stageBound.width / stageWidth;
			var bitmapScaleY:Number = stageBound.height / stageHeight;
			
			canvasBound = new Rectangle(stageBound.x, stageBound.y, stageWidth * quality, stageHeight * quality);
			canvasScaleRate = new Point(stageWidth / stageBound.width, stageHeight / stageBound.height);
			
			timePassed = 0;
			points = [];
			
			randomX			= (params && params.randomX != undefined)		? params.randomX		: 6;		
			randomY			= (params && params.randomY != undefined)		? params.randomY		: 6;			
			randomX			*= bitmapScaleX * quality;
			randomY			*= bitmapScaleY * quality;
			
			quality			= (params && params.quality != undefined)		? params.quality		: 1;	
			lifeTime		= (params && params.time != undefined)			? params.time			: 1;				
			numLines		= (params && params.numLines != undefined)		? params.numLines		: 50;
			numRows			= (params && params.numRows != undefined)		? params.numRows		: 50;
			
			bitmap = new Bitmap(new BitmapData(1, 1) , PixelSnapping.ALWAYS);
			bitmap.x = stageBound.x;
			bitmap.y = stageBound.y;
			bitmap.scaleX = bitmapScaleX / quality;
			bitmap.scaleY = bitmapScaleY / quality;
			theParent.addChildAt(bitmap, theParent.getChildIndex(sourceClip));
			
			
			var sp:SwarmPath = ((params && params.swarmPath != undefined)) ? params.swarmPath : new SwarmPath();			
			sp.add(new SwarmPathPoint(0, sourceClip, sourceClip.x, sourceClip.y, 'random'));
			setSwarmPath(sp);
			
			pointsNotShifted = points.concat();
			//pointsNotShifted = ArrayUtils.shuffle(pointsNotShifted);	
			
			trace('Take ' + (getTimer() - t) + ' ms to build.');
		}
		
		private function setSwarmPath(sp:SwarmPath):void
		{
			swarmPath = sp;
			
			extractSamples();
			
			checkFinalSpp();
			buildPoints();
			
			resetPathCoordinate();
		}
		
		private function extractSamples():void
		{
			for each(var spp:SwarmPathPoint in swarmPath)
			{
				if (spp.clip)
				{
					spp.sample = getSwarmSample(spp.clip);
					setSwarmSampleGeomData(spp.sample);
				}
			}			
		}
		
		
		// get SwarmSample from a clip
		private function getSwarmSample(clip:DisplayObject):SwarmSample
		{
			theParent.addChild(clip);
			var stagePosition:Point = clip.localToGlobal(new Point(0, 0));
			var bound:Rectangle = clip.getBounds(theParent.stage);		
			var pieceWidth:Number	= bound.width / numLines;
			var pieceHeight:Number	= bound.height / numRows;
			
			var sprite:Sprite = new Sprite();		
			sprite.addChild(clip);
			
			var qualitySeed:Number = (mosaicOn) ? 1 : quality;
			var sb2:Rectangle = clip.getBounds(sprite);
			var bitmapData:BitmapData	= new BitmapData(bound.width , bound.height , true , 0);
			bitmapData.draw(sprite , new Matrix(canvasScaleRate.x*qualitySeed, 0, 0, canvasScaleRate.y*qualitySeed, -sb2.x * canvasScaleRate.x*qualitySeed, -sb2.y * canvasScaleRate.y*qualitySeed));		
			var uvRects:Array		= [];
			var tPoints:Array		= [];	
			sprite.removeChild(clip);
			
			var swarmSample:SwarmSample = new SwarmSample(clip, stagePosition, bitmapData, bound, uvRects , tPoints, pieceWidth , pieceHeight);
			
			return swarmSample;
		}
		
		private function checkFinalSpp():void
		{
			var lastSpp:SwarmPathPoint = swarmPath[swarmPath.length - 1];
			if (!lastSpp.clip) 
			{
				swarmPath.pop();
				lastSpp = swarmPath[swarmPath.length - 1];
			}
			
			if (lastSpp.percent != 1)
			{
				var spp:SwarmPathPoint = lastSpp.cloneV2();
				spp._percent = 1;
				var sppHasSample:SwarmPathPoint = swarmPath.lastPointHasSample(swarmPath.length - 1);
				var sample:SwarmSample = sppHasSample.sample.clone();
				sample.clip = null;
				sample.bitmapData = new BitmapData(sample.bitmapData.width, sample.bitmapData.height, true, 0);
				spp.sample = sample;
				swarmPath.add(spp);
			}			
		}
		
		private function buildPoints():void
		{
			points = [];
			for each(var point:Point in swarmPath[0].sample.tPoints)
			{				
				points.push(new SwarmPoint(point.x, point.y, swarmPath[0].sample ));
			}			
		}
		
		private function setSwarmSampleGeomData(sample:SwarmSample):void
		{			
			var row:uint, line:uint;			
			var rectW:int = Math.ceil(sample.pieceWidth * quality);
			var rectH:int = Math.ceil(sample.pieceHeight * quality);
			
			var qualitySeed:Number = (mosaicOn) ? 1 : quality;
			
			for (row = 0; row < numRows; row++)
			{
				for (line = 0; line < numLines; line++)
				{
					var gapW:Number = sample.pieceWidth * line;
					var gapH:Number = sample.pieceHeight * row;
					
					var px:Number = (sample.bound.x + gapW);
					var py:Number = (sample.bound.y + gapH);
					
					sample.uvRects.push(new Rectangle(gapW*qualitySeed, gapH*qualitySeed, rectW, rectH));
					sample.tPoints.push(new Point( px, py));				
				}
			}
		}
		
		private function resetPathCoordinate():void
		{
			var k:uint, tPointLength:uint = points.length;
			var i:uint, l:uint = swarmPath.length;
			for (i = 0; i < l;i++ )
			{
				var spp:SwarmPathPoint = swarmPath[i];
				var p:Point = theParent.localToGlobal(new Point(spp.x , spp.y));		
				spp.x = p.x;
				spp.y = p.y;
				
				
				if (i == 0)
				{
					spp.tPoints = swarmPath[0].sample.tPoints.concat();
				}
				else
				{
					if (spp.sample)
					{
						for (k = 0; k < tPointLength; k++)
						{
							spp.tPoints[k] = spp.sample.tPoints[k].clone();							
						}
					}
					else
					{
						var lastSppHasSample:SwarmPathPoint = swarmPath.lastPointHasSample(i);
						var sourceSample:SwarmSample = lastSppHasSample.sample;
						var nextSppHasSample:SwarmPathPoint = swarmPath.nextPointHasSample(i);
						var targetSample:SwarmSample = nextSppHasSample.sample;
					
						var shiftPercent:Number = (spp.percent - lastSppHasSample.percent) / (nextSppHasSample.percent - lastSppHasSample.percent);
					
						var firstSpp:SwarmPathPoint = swarmPath[0];
					
						var dx:Number = spp.x - firstSpp.x;
						var dy:Number = spp.y - firstSpp.y;
					
						var dSTPosition:Point = targetSample.stagePosition.subtract(sourceSample.stagePosition);
						var dTX:Number, dTY:Number;
						for (k = 0; k < tPointLength; k++)
						{
							spp.tPoints[k] = sourceSample.tPoints[k].clone();
						
							dTX = (targetSample.tPoints[k].x - sourceSample.tPoints[k].x - dSTPosition.x) * shiftPercent;
							dTY = (targetSample.tPoints[k].y - sourceSample.tPoints[k].y - dSTPosition.y) * shiftPercent;
							spp.tPoints[k].offset(dx + dTX, dy + dTY);		
						
						}
					}
					
				}		
			}			
		}
		
		public function render(dTime:Number):void
		{
			var t:uint = getTimer();
			
			timePassed += dTime;
			percent = timePassed / lifeTime;
			
			checkShift();
			
			
			if (timePassed < lifeTime)
			{		
				checkForPath();
				renderBitmap();
			}
			else
			{
				complete();
			}			
			
			numRenderTimer += getTimer() - t;
			numRendered ++;
		}
		
		private function checkShift():void
		{
			if (percent > percentToStartShift)
			{
				if (onShifting == false)
				{
					onShifting = true;
					numShifted = 0;
				}
				doSomeShift();
			}
		}
		
		private function doSomeShift():void
		{			
			var newNumShifted:uint = int((percent - percentToStartShift) / percentTotalShift * points.length);
			var l:uint = newNumShifted - numShifted;
			if (l > pointsNotShifted.length) l = pointsNotShifted.length;
			
			var targetSample:SwarmSample = swarmPath.nextPointHasSample(0).sample;
			
			for (var i:uint = 0; i < l;i++)
			{
				var point:SwarmPoint = pointsNotShifted.shift();
				point.sample = targetSample;
			}
			
			numShifted = newNumShifted;
		}
		
		private function checkForPath():void
		{
			var i:uint, l:uint = swarmPath.length-1;
			for (i = 0; i < l; i++)
			{				
				fromPoint = swarmPath[i];
				towardingPoint = swarmPath[i + 1];
				if (percent >= fromPoint.percent && percent < towardingPoint.percent) break;
			}
			
			currentSwarmPathIndex = i;
				
			pathProgress = (percent - fromPoint.percent) / (towardingPoint.percent - fromPoint.percent);
			antiPathProgress = 1 - pathProgress;
		}
		
		private function renderBitmap():void
		{
			bitmap.bitmapData.dispose();
			
			var sourceSample:SwarmSample = swarmPath.lastPointHasSample(0).sample;
			
			var canvas:BitmapData = new BitmapData(canvasBound.width, canvasBound.height, true , 0);
			canvas.lock();
			
			var randomXMin:Number = - randomX * 0.5;
			var randomYMin:Number = - randomY * 0.5;
			var sample:SwarmSample, bitmapData:BitmapData;
			var destPoint:Point = new Point();
			//var p:Number = Math.tan(pathProgress * Math.PI * 0.5);
			var rx:Number, ry:Number;
			
			var dx:Number, dy:Number, uvRect:Rectangle, point:SwarmPoint, tPointFrom:Point, tPointToward:Point, dPoint:Point, dPoint0:Point, i:uint, l:uint = points.length;
			for (i = 0; i < l;i++ )
			{
				point = points[i];
				
				sample = point.sample;
				uvRect = sample.uvRects[i];
				
				var sourceTPoint:Point = sourceSample.tPoints[i];
				tPointFrom = fromPoint.tPoints[i];
				tPointToward = towardingPoint.tPoints[i];
				dPoint = tPointToward.subtract(tPointFrom);
				dPoint0 = tPointFrom.subtract(sourceTPoint);
				
				rx = randomXMin + Math.random() * randomX;
				ry = randomYMin + Math.random() * randomY;
				
				if (towardingPoint.swarmType == 'random')
				{
					point.offset(rx, ry);
					destPoint.x = point.x + dPoint0.x + dPoint.x * pathProgress;
					destPoint.y = point.y + dPoint0.y + dPoint.y * pathProgress;
					
				}
				else if (towardingPoint.swarmType == 'recover')
				{
					point.offset(rx, ry);
					//point.dx *= antiPathProgress;
					//point.dy *= antiPathProgress;
					point.offset( -point.dx * pathProgress, -point.dy * pathProgress);
					destPoint.x = point.x + dPoint0.x + (dPoint.x * pathProgress);
					destPoint.y = point.y + dPoint0.y + (dPoint.y * pathProgress);		
				}			
				destPoint.x *= quality;
				destPoint.y *= quality;
				
				canvas.copyPixels(sample.bitmapData, uvRect, destPoint);
			}
			
			canvas.unlock();
			bitmap.bitmapData = canvas;	
		}
		
		private function complete():void
		{
			trace('Average render time = ' + numRenderTimer / numRendered + ' ms.');
			
			bitmap.bitmapData.dispose();
			
			if (swarmPath[swarmPath.length - 1].sample.clip != null) theParent.addChildAt(swarmPath[swarmPath.length - 1].sample.clip , bitmap.parent.getChildIndex(bitmap));
			
			theParent.removeChild(bitmap);			
			
			points = null;
			for each(var spp:SwarmPathPoint in swarmPath) spp.destroy();
			swarmPath = null;			
			
			dispatchEvent(new Event(Event.COMPLETE));	
		}
	}
}