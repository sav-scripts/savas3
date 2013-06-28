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
	import sav.events.SwarmerEvent;
	use namespace swarm_namespace;
	
	[Event(name = 'complete', type = 'sav.events.SwarmerEvent')]
	
	public class Swarmer extends EventDispatcher
	{		
		private var theParent:DisplayObjectContainer;	// sourceClip's parent
		private var stageBound:Rectangle;				// bound of stage local size in theParent
		
		private var canvasBound:Rectangle;				// bound of canvas		
		private var canvasScaleRate:Point;				// a scale rate of canvas size and real stage width
		
		private var quality:Number = 1;					// quality of canvas , this value is 0~1
		
		private var lifeTime:Number;					// duration of this swarm
		private var timePassed:Number;					// time passed
		
		private var percent:Number = 0;					// current progress , is a percent of lifeTime
		private var dPercent:Number = 0;				// 
		
		private var swarmPath:SwarmPath;				// path of this swarm , is instance of a SwarmPath
		
		public var bitmap:Bitmap;						// display object of this swarmer , is a Bitmap		
		
		private var numLines:uint;						// num of lines
		private var numRows:uint;						// num of rows
		private var numPieces:uint;
		private var points:Array;						// all swarm points
		
		private var pointsNotShifted:Array;				// 
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
		
		private var activeTime:Number = 1;		
		private var activeProgress:Number = 0;
		private var notActivedPoints:Array;
		private var activedPoints:Array;
		private var completedPoints:Array;
		
		/**
		 * @param	sourceClip	DisplayObject	first clip for whole swarm, Swarmer will automaticaly use it create a SwarmPathPoint with 0 percent property.
		 * @param	params		Object			give additional parames to this Swarmer.
		 */
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
			
			randomX			= (params && params.randomX != undefined)		? params.randomX		: 6;		
			randomY			= (params && params.randomY != undefined)		? params.randomY		: 6;			
			randomX			*= bitmapScaleX * quality;
			randomY			*= bitmapScaleY * quality;
			
			quality			= (params && params.quality != undefined)		? params.quality		: 1;	
			lifeTime		= (params && params.time != undefined)			? params.time			: 1;	
			activeTime		= (params && params.activeTime != undefined)	? params.activeTime		: 1;	
			numLines		= (params && params.numLines != undefined)		? params.numLines		: 50;
			numRows			= (params && params.numRows != undefined)		? params.numRows		: 50;
			numPieces		= numLines * numRows;
			
			var cellWidth:Number = (params && params.cellWidth != undefined)		? params.cellWidth		: 50;
			var cellHeight:Number = (params && params.cellHeight != undefined)		? params.cellHeight		: 50;
			
			bitmap = new Bitmap(new BitmapData(1, 1) , PixelSnapping.ALWAYS);
			bitmap.x = stageBound.x;
			bitmap.y = stageBound.y;
			bitmap.scaleX = bitmapScaleX / quality;
			bitmap.scaleY = bitmapScaleY / quality;
			theParent.addChildAt(bitmap, theParent.getChildIndex(sourceClip));			
			
			var sp:SwarmPath = ((params && params.swarmPath != undefined)) ? params.swarmPath : new SwarmPath();			
			sp.add(0, sourceClip, sourceClip.x, sourceClip.y, 'random');
			setSwarmPath(sp);
			
			trace('Take ' + (getTimer() - t) + ' ms to build.');				
		}
		
		/**
		 * Give a SwarmPath to this Swarmer, this method will then calculate and transform necessary data for SwarmPathPoints in this this path.
		 * @param	sp		SwarmPath
		 */
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
		
		// change a clip in swarmPath into SwarmSample
		private function getSwarmSample(clip:DisplayObject):SwarmSample
		{
			theParent.addChild(clip);
			var stagePosition:Point = clip.localToGlobal(new Point(0, 0));
			var bound:Rectangle		= clip.getBounds(theParent.stage);		
			var pieceWidth:Number	= bound.width / numLines;
			var pieceHeight:Number	= bound.height / numRows;
			
			var sprite:Sprite = new Sprite();		
			sprite.addChild(clip);
			
			var sb2:Rectangle = clip.getBounds(sprite);
			var bitmapData:BitmapData	= new BitmapData(bound.width , bound.height , true , 0);
			bitmapData.draw(sprite , new Matrix(canvasScaleRate.x*quality, 0, 0, canvasScaleRate.y*quality, -sb2.x * canvasScaleRate.x*quality, -sb2.y * canvasScaleRate.y*quality));		
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
				sample.bitmapData = new BitmapData(sppHasSample.sample.bitmapData.width, sppHasSample.sample.bitmapData.height, true, 0);
				spp.sample = sample;
				swarmPath.addSPP(spp);
			}			
		}
		
		private function buildPoints():void
		{
			points = [];
			var i:uint, l:uint = swarmPath[0].sample.tPoints.length;
			
			for (i = 0; i < l;i++ )
			{
				var tPoint:Point = swarmPath[0].sample.tPoints[i]; 
				points.push(new SwarmPoint(i, tPoint.x, tPoint.y, swarmPath[0].sample ));
			}		
			
			pointsNotShifted = points.concat();
			pointsNotShifted = ArrayUtils.shuffle(pointsNotShifted);
			
			if (activeTime == 0)
			{
				notActivedPoints = [];			
				activedPoints = pointsNotShifted.concat();
				completedPoints = [];
			}
			else
			{
				notActivedPoints = pointsNotShifted.concat();			
				activedPoints = [];
				completedPoints = [];
			}
		}
		
		private function setSwarmSampleGeomData(sample:SwarmSample):void
		{			
			var row:uint, line:uint;			
			var rectW:int = Math.ceil(sample.pieceWidth * quality);
			var rectH:int = Math.ceil(sample.pieceHeight * quality);
			
			for (row = 0; row < numRows; row++)
			{
				for (line = 0; line < numLines; line++)
				{
					var gapW:Number = sample.pieceWidth * line;
					var gapH:Number = sample.pieceHeight * row;
					
					var px:Number = (sample.bound.x + gapW);
					var py:Number = (sample.bound.y + gapH);
					
					sample.uvRects.push(new Rectangle(gapW*quality, gapH*quality, rectW, rectH));
					sample.tPoints.push(new Point( px, py));				
				}
			}
		}		
		
		// reset coordinate of points in SPP, make them map with stage size bitmapData
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
				
				
				var nextSppHasSample:SwarmPathPoint = swarmPath.nextPointHasSample(i);
				
				
				if (nextSppHasSample && nextSppHasSample != spp)
				{
					spp.shifting = true;
				}
				
					
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
			dPercent = timePassed / lifeTime - percent;
			percent = timePassed / lifeTime;
			
			checkShift();	
			checkActive();
			
			if (completedPoints.length < numPieces)
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
		
		// check if this point is actived according to time, if so it will be added into activePoints array, and be rendered.
		private function checkActive():void
		{
			if (notActivedPoints.length > 0)
			{
				var numActive:uint = int(timePassed / activeTime * numPieces);
				var numPointsUnActived:int = points.length - numActive;
				var point:SwarmPoint;
				
				if (numPointsUnActived <= 0)
				{
					for each(point in notActivedPoints)
					{
						point.actived = true;
						activedPoints.push(point);
					}
					notActivedPoints = [];
				}
				else
				{
					while (notActivedPoints.length > numPointsUnActived)
					{
						point = notActivedPoints.shift();
						point.actived = true;
						activedPoints.push(point);
					}
				}
			}
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
			
			pathProgress = (percent - fromPoint.percent) / (towardingPoint.percent - fromPoint.percent);
			antiPathProgress = 1 - pathProgress;
		}
		
		private function checkForPath2(p:Number):void
		{
			var i:uint, l:uint = swarmPath.length-1;
			for (i = 0; i < l; i++)
			{				
				fromPoint = swarmPath[i];
				towardingPoint = swarmPath[i + 1];
				if (p >= fromPoint.percent && p < towardingPoint.percent) break;
			}
			
			pathProgress = (p - fromPoint.percent) / (towardingPoint.percent - fromPoint.percent);
			antiPathProgress = 1 - pathProgress;
		}
		
		private function renderBitmap():void
		{
			bitmap.bitmapData.dispose();
			
			var sourceSample:SwarmSample = swarmPath.lastPointHasSample(0).sample;
			var firstSample:SwarmSample = swarmPath[0].sample;
			var finalSample:SwarmSample = swarmPath[swarmPath.length - 1].sample;
			
			var canvas:BitmapData = new BitmapData(canvasBound.width, canvasBound.height, true , 0);
			canvas.lock();
			
			var randomXMin:Number = - randomX * 0.5;
			var randomYMin:Number = - randomY * 0.5;
			var sample:SwarmSample, bitmapData:BitmapData;
			var destPoint:Point = new Point();
			var rx:Number, ry:Number;
			
			var dx:Number, dy:Number, uvRect:Rectangle, point:SwarmPoint, tPointFrom:Point, tPointToward:Point, dPoint:Point, dPoint0:Point, i:uint, l:uint, sourceTPoint:Point;			
			
			
			var alphaBitmap:BitmapData = new BitmapData(canvasBound.width, canvasBound.height, true, 0x33ffffff);
			var alphaPoint:Point = new Point();
			
			// render for not actived points
			l = notActivedPoints.length;
			for (i = 0; i < l;i++ )
			{
				point = notActivedPoints[i];
				
				sample = firstSample;
				uvRect = firstSample.uvRects[point.index];
				
				destPoint.x = point.x;
				destPoint.y = point.y;		
				
				destPoint.x *= quality;
				destPoint.y *= quality;
				
				canvas.copyPixels(sample.bitmapData, uvRect, destPoint, alphaBitmap, destPoint, true);
			}
			
			// render for completed points
			l = completedPoints.length;		
			for (i = 0; i < l;i++ )
			{
				point = completedPoints[i];
				
				sample = finalSample;
				uvRect = finalSample.uvRects[point.index];
				
				destPoint.x = point.x;
				destPoint.y = point.y;
				
				destPoint.x *= quality;
				destPoint.y *= quality;
				
				canvas.copyPixels(sample.bitmapData, uvRect, destPoint);
			}
			
			
			// render for actived points
			l = activedPoints.length;			
			for (i = 0; i < l;i++ )
			{
				point = activedPoints[i];
				point.percent += dPercent;
				
				var index:uint = point.index;
				
				checkForPath2(point.percent);
				
				sample = point.sample;
				uvRect = sample.uvRects[point.index];
				
				sourceTPoint = sourceSample.tPoints[index];
				tPointFrom = fromPoint.tPoints[index];
				tPointToward = towardingPoint.tPoints[index];
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
					point.offset( -point.dx * pathProgress, -point.dy * pathProgress);
					destPoint.x = point.x + dPoint0.x + (dPoint.x * pathProgress);
					destPoint.y = point.y + dPoint0.y + (dPoint.y * pathProgress);
				}
				
				destPoint.x *= quality;
				destPoint.y *= quality;
				
				canvas.copyPixels(sample.bitmapData, uvRect, destPoint);
				
				if (point.percent >= 1)
				{
					point.x = tPointFrom.x;
					point.y = tPointFrom.y;
					
					activedPoints.shift();
					i--;
					l--;
					completedPoints.push(point);
				}
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
			
			dispatchEvent(new SwarmerEvent(SwarmerEvent.COMPLETE));
		}
	}
}