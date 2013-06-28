package sav.utils
{
	public class ObjectUtils
	{
		public static function cloneObjects(obj1:Object,cloneChildrenToo:Boolean = true):Object
		{
			var obj2 = {};
			for (var prop in obj1)
			{
				if (cloneChildrenToo && typeof(obj1[prop]) == 'object')
				{
					if (obj1[prop] is Array)
					{
						obj2[prop] = obj1[prop].concat([]);						
					}
					else
					{
						obj2[prop] = cloneObjects(obj1[prop]);
					}
				}
				else
				{
					obj2[prop] = obj1[prop];
				}
			}
			
			return obj2;

		}
	}
}