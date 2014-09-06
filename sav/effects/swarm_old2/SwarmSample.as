package sav.effects.swarm
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class SwarmSample
	{
		public var clip:DisplayObject;
		public var bitmapData:BitmapData;
		public var bound:Rectangle;
		public var uvRects:Array;
		public var tPoints:Array;
		public var stagePosition:Point;
		public var pieceWidth:Number;
		public var pieceHeight:Number;
		
		public function SwarmSample(clip:DisplayObject, stagePosition:Point, bitmapData:BitmapData , bound:Rectangle , uvRects:Array , tPoints:Array , pieceWidth:Number , pieceHeight:Number)
		{
			this.clip = clip;
			this.stagePosition = stagePosition;
			this.bitmapData = bitmapData;
			this.bound = bound;
			this.uvRects = uvRects;
			this.tPoints = tPoints;
			this.pieceWidth = pieceWidth;
			this.pieceHeight = pieceHeight;		
		}
		
		public function clone():SwarmSample
		{
			var ss:SwarmSample = new SwarmSample(clip, stagePosition, bitmapData, bound, uvRects, tPoints, pieceWidth, pieceHeight);
			return ss;
		}
		
		public function destroy():void
		{
			bitmapData.dispose();
			clip = null;
			bitmapData = null;
			bound = null;
			uvRects = null;
			tPoints = null;
			stagePosition = null;
		}
	}
}