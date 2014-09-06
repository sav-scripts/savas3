package sav.utils
{
	public class StringUtils
	{
		/**
		 * Count amount of full size characters in a string
		 * 
		 * @param	string	target string
		 * @return	uint 	amount of full size characters
		 */
		public static function countFullSizeChars(string:String):uint
		{
			var v:int, cc:int, c:int;
			v=0
			for (cc = 0; cc < string.length; cc++)
			{
			   c = string.charCodeAt(cc);
			  if (!(c >= 32 && c <= 126)) v++;
			}
			return v
		}
		
		/**
		 * Count string length by treating full size characters as length 2
		 * 
		 * @param	string	target string
		 * @return	uint	real length of this string
		 */
		public static function countRealLength(string:String):uint
		{
			return StringUtils.countFullSizeChars(string) + string.length;
		}
		
		public static function replaceHtmlLabel(string:String):String
		{
			//return string.replace(/<(.*?)>/gs, '&lt;$1&gt;');
			
			string = string.replace(/</gs, "&lt;");
			string = string.replace(/>/gs, "&gt;");
			
			return string;
		}
		
		public static function replaceSlash(str:String):String
		{
			return str.replace(/\\/gs, '\\\\');
		}
	}
}