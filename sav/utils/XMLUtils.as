package sav.utils
{
	
	public class XMLUtils
	{
		public static function xmlListToArray(rawXmlList:XMLList , keyElement:String = ''):Array
		{
			var array:Array = [];
			
			for each(var data:* in rawXmlList)
			{				
				if (data.elements('*').length() == 0)
				{
						
					var v:*;
					if (data.children().length() == 0)
					{
						if (data.attributes().length() > 0) 
						{
							v = attributesToObject(data.attributes());
						}
						else
						{
							v = null;
						}						
					}
					else
					{
						if(data.@type == 'Boolean')
						{
							v = (data.toString() == 'true') ? true : false;
						}
						else
						{
							v = (isNaN(Number(data.toString()))) ? String(data.toString()) : Number(data.toString());					
						}			
					}		
					array.push(v);
				}
				else
				{
					var object:Object			= new Object();
					if (keyElement != '') 
					{
						if (data[keyElement].toString() != '') 
						{
							var objectName:String		= data[keyElement].toString();
						}
						else
						{
							trace('warning : XML 中沒有包含用來當作陣列索引的標籤');
							
							keyElement = '';
						}
					}
					
					object = xmlListToArray2(data);
					
					(keyElement != '') ? array[objectName] = object : array.push(object);					
				}
			}
			
			return array;

		}
		
		private static function xmlListToArray2(data:XML):Object
		{
			var object:Object = {};
			for (var i:uint=0;i<data.elements('*').length();i++)
			{
				var xmlList:XML			= data.elements("*")[i];
				var xmlListName:String		= xmlList.name();
				if(data.elements(xmlListName).length() > 1)
				{
					if (object[xmlListName] == undefined)
					{
						object[xmlListName] = xmlListToArray(data.elements(xmlListName));
					}

				}
				else
				{
					if(data.elements(xmlListName).elements('*').length() > 0)
					{
						object[xmlListName] = xmlListToArray(data.elements(xmlListName));
					}
					else
					{
						if (xmlList.children().length() == 0)
						{
							if (xmlList.attributes().length() > 0) 
							{
								object[xmlListName] = attributesToObject(xmlList.attributes());
							}
							else
							{
								object[xmlListName] = null;
							}						
						}
						else
						{
							if(xmlList.@type == 'Boolean')
							{
								object[xmlListName]	= (xmlList.toString() == 'true') ? true : false;
							}
							else
							{
								object[xmlListName]	= (isNaN(Number(xmlList.toString()))) ? String(xmlList.toString()) : Number(xmlList.toString());
							}
						}
						
					}
				}
			}
			
			return object;
		}
		
		private static function attributesToObject(attributes:XMLList):Object
		{
			var object:Object = {};
			for (var i:uint=0;i<attributes.length();i++) 
			{
				var att:String = attributes[i].toString();
				var value:*;
				if (att == 'true') 
				{
					value = true;
				}
				else if(att == 'false')
				{
					value = false;
				}
				else if(isNaN(Number(att)))
				{
					value = att;
				}
				else
				{
					value = Number(att);
				}

				object[attributes[i].name().toString()] = value;				
			}
			return object;
		}
	}
}