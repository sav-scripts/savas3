package sav.utils
{
	public class ArrayUtils	
	{
		// shuffle this array
		public static function shuffle(sourceArray:Array):Array
		{
			sourceArray = sourceArray.concat([]);
			
			var tempArray:Array = [];
			while(sourceArray.length > 0)
			{
				var index:int		= int(Math.random()*sourceArray.length);
				var raw:*			= sourceArray.splice(index,1)[0];
				tempArray.push(raw);
			}
			
			return tempArray;
		}	
		
		// search a param from objects in a array , return first or last index 
		public static function searchIndex(array:Array , paramString:String , paramValue:* , fromBack:Boolean = false):int
		{
			if(array.length==0) return -1;
			
			var i:int;
			var object:Object;
			
			if(fromBack == false)
			{
				for (i=0;i<array.length;i++)
				{
					object = array[i];
					if (object[paramString] == paramValue) return i;
					
				}
			}
			else
			{
				for (i=(array.length-1);i>=0;i--)
				{
					object = array[i];
					if (object[paramString] == paramValue) return i;					
				}
			}
			return -1;
		}
		
		// give a array , search all possible combos (with spec array length) , return all those result as a array[arrays]
		public static function getAllCombosFromArray(array:Array , length:uint):Array
		{
			var returnArray:Array = [];
						
			var tempArray:Array = array.concat([]);
			
			if (length == 1)
			{
				for each(var obj:Object in tempArray)
				{
					returnArray.push([obj]);
				}
				return returnArray;
			}
			else
			{			
				while (tempArray.length > 0)
				{
					var obj1:Object = tempArray.shift();
					
					var tempArray2:Array = getAllCombosFromArray(tempArray , length - 1);
					for each(var tempArray3:Array in tempArray2)
					{
						tempArray3.unshift(obj1);
					}
					returnArray = returnArray.concat(tempArray2);
					
				}			
				return returnArray;				
			}
		}
	}
}