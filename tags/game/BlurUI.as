/******************************************************************************************************************
	This is a basic Class for UI , it define some method provide inherbited UIs Fade in fade out effects .
	
	For use it , write a Class extend it .
	
		When a building a Class extends this , you should asign a stageRef for them , so the <load> method knows where 
	it should be added at .
	
		If the UI's target fade in position not (0 , 0) , you should declare the position (targetX , targetY) you hope it is in 
	contructor of child Class ,	or change it after it is build . 
	
		(startX , startY) is similar , but decide where the fade in start (or where fade out end at)
		
		there is startAlpha and targetAlpha too , consider them work same way as x y things
		
		time is how long the fade in / out effect will take with
	
*******************************************************************************************************************/

package sav.game
{
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import caurina.transitions.Tweener;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.BlurFilter;

	public class BlurUI extends BaseUI
	{
		override public function unload(loadMe:BaseUI = null):void
		{
			var blurFilter:BlurFilter = new BlurFilter(0, 0, 1);
			var filterArray:Array = this.filters.concat([]);
			filterArray.push(blurFilter);
			this.filters = filterArray;
			Tweener.addTween(blurFilter, { time:time, blurX:10 } );
			
			Tweener.addTween(this, { alpha: _startAlpha , x:_startX , y:_startY , time:time , onComplete:remove } );
		}
	}

}