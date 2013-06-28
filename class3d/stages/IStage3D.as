package sav.class3d.stages
{	
	public interface IStage3D
	{		
		function reset(excuteDestroy:Boolean = true):void;
		function destroy():void;		
		function renderAll():void;
	}
}