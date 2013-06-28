/******************************************************************************************************************
	This is a cover which usually use for scene transfer .
	
		To use this , simply build it , and then use <coverAt> method to cover starge , the withTween option decide should
	cover play tween anime or cover instantly . same option is use at <remove> function
	
		If you wana the cover with different color , set the <color> param before use coverAt function .
		
		Cell is sub Class used for unit of shape that organized to whole cover , right now it is a square .
	
*******************************************************************************************************************/
package sav.game.effects
{
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;	
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.Event;
	
	import caurina.transitions.Tweener;
	
	public class SceneTransferCover extends Sprite
	{
		public var cellWidth			:uint = 50;
		public var cellHeight			:uint = 50;
		public var color				:int = 0x000000;
		public var delay				:Number = 0.001;
		public var time					:Number = 1;
		
		private var cellArray			:Array;
		
		public function SceneTransferCover()
		{
		}
		
		public function coverAt(stageRef:DisplayObjectContainer , withTween:Boolean = true):void
		{
			stageRef.addChild(this);
			
			cellArray = [];
			
			var rect = new Rectangle(0 , 0 , stageRef.stage.stageWidth , stageRef.stage.stageHeight);
			rect.inflate(cellWidth , cellHeight);
			
			var markX:Number = rect.left;
			var markY:Number = rect.top;
			var idy:Number = 0;
			
			while(markY <= rect.bottom)
			{
				while(markX <= rect.right)
				{
					var cell:Cell = new Cell(cellWidth , cellHeight , color);
					cell.x = markX;
					cell.y = markY + cellHeight * (idy % 2);
					
					var center:Point = new Point(rect.x + rect.width/2 , rect.y + rect.height/2);
					center.x -= cell.x;
					center.y -= cell.y;
					
					
					addChild(cell);
					cellArray.push({cell:cell , length:center.length});
					
					idy ++;
					markX += cellWidth;
				}	
				idy = 0;
				markX = rect.left;			
				markY += cellHeight;
			}
			
			cellArray.sortOn('length' , Array.NUMERIC);
			
			if (withTween)
			{
				for (var i:uint=0;i<cellArray.length;i++)
				{
					cell = cellArray[i].cell;
					cell.scaleX = 0;
					cell.scaleY = 0;
					(i == cellArray.length-1) ? Tweener.addTween(cell , {time:time , delay:i*delay , scaleX:1 , scaleY:1 , onComplete:coverCompleted})
											  : Tweener.addTween(cell , {time:time , delay:i*delay , scaleX:1 , scaleY:1});
				}
			}
		}
		
		public function coverCompleted():void
		{
			dispatchEvent(new Event('coverCompleted'));			
		}
		
		public function remove(withTween:Boolean = true):void
		{
			if(!this.parent) return;
			
			if (withTween)
			{
				for (var i=0;i<cellArray.length;i++)
				{
					var cell:Cell = cellArray[i].cell;
					cell.scaleX = 1;
					cell.scaleY = 1;
					(i == cellArray.length-1) ? Tweener.addTween(cell , {time:time , delay:i*delay , scaleX:0 , scaleY:0 , onComplete:removeCompleted})
											  : Tweener.addTween(cell , {time:time , delay:i*delay , scaleX:0 , scaleY:0});				
				}
			}
			else
			{
				this.parent.removeChild(this);
			}
		}
		
		private function removeCompleted():void
		{
			while(this.numChildren > 0)
			{
				this.removeChild(this.getChildAt(0));
			}
			this.parent.removeChild(this);
			cellArray = null;
			dispatchEvent(new Event('removeCompleted'));
		}
	}
}

import flash.display.Shape;

class Cell extends Shape
{
	function Cell(w:uint , h:uint , color:int):void
	{
		graphics.beginFill(color);
		graphics.drawRect(-w/2 , -h/2 , w , h);
	}
	
}

