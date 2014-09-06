package sav.events
{
	import flash.events.Event;
	
	public class SavProgressEvent extends Event
	{				
		public function SavProgressEvent(
			type:String = '', currentAmount:Number = 0, totalAmount:Number = 1, unitString:String = 'bytes',
			bubbles:Boolean = false, cancelable:Boolean = false):void
		{
			this.currentAmount = currentAmount;
			this.totalAmout = totalAmout;
			this.unitString = unitString;			
			
			super(type, bubbles, cancelable);
		}		
		
		public static const PROGRESS:String = 'progress';
		
		public var currentAmount:Number;
		public var totalAmout:Number;
		public var unitString:String;
		
		public function get percent():Number { return currentAmount / totalAmout; }
		
		override public function toString():String 
		{
			return "[" + type + "] total : " + totalAmout + " " + unitString + ", current : " + currentAmount + " " + unitString + ", percent : " + percent;
		}
	}
}