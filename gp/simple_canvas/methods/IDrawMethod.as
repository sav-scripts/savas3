package sav.gp.simple_canvas.methods
{
	import flash.display.Graphics;
	public interface IDrawMethod
	{			
		/**
		 * 
		 * Handle event when mouse down, need provide a Graphics reference for drawing methods
		 * 
		 * @param	targetGraphics	
		 * @param	mouseX			
		 * @param	mouseY			
		 */
		function mouseDownHandler(targetCanvas:*, mouseX:Number, mouseY:Number):void		
		
		/**
		 * 
		 * Handle event when mouse moving
		 * 
		 * @param	mouseX	
		 * @param	mouseY	
		 */
		function mouseMoveHandler(mouseX:Number, mouseY:Number):void
		
		/**
		 * Handle event when mouse up
		 * @param	mouseX	
		 * @param	mouseY	
		 * @return			 return true if got enough data for implemented method to draw, if not, return false and this instance won't be recoard
		 */
		function mouseUpHandler(mouseX:Number, mouseY:Number):Boolean
		
		/**
		 * This is for drawing dot data inside this draw method
		 * @param	targetGraphics
		 */
		function redraw(targetCanvas:*):void
		
		/**
		 * Clone with implemented object with params like color/alpha, but not with mouse interactive data
		 * @return	IDrawMethod		a copy of implement object
		 */
		function semiClone():IDrawMethod
		
		/**
		 * Destroy self for release memony
		 */
		function destroy():void
		
		/**
		 * <p>Return what type of drawing instance this method will use, only two type, Graphics or BitmapData accepable</p>
		 * mouseDownHandler and redraw method should use targetCanvas param as same Class type with this value
		 */
		function get canvasType():Class
	}
}