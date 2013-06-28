package sav.interfaces
{
	import flash.display.*;
	import flash.events.*;
	
	public interface IAssets extends IEventDispatcher
	{	
		function get states():String
		
		function get sounds():Array
		
		function get loader():Object;
		
		function addFiles(xmlAdress:String):void
		
		function loaderStart():void
		
		function getPack(id:String):*
		
		function getClass(className:String , id:String):Class
		
		function loadURL(url:String, loaderParams:Object = null, 
			successFunc:Function = null, successFuncParams:Array = null, 
			failFunc:Function = null, failFuncParams:Array = null, 
			progressFunc:Function = null, progressFuncParams:Array = null):String		
		
		function loadURL_cancel(loadingItemId:String):void
	}
}