/*
Copyright (c) 2007 FlexLib Contributors.  See:
    http://code.google.com/p/flexlib/wiki/ProjectContributors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package flexlib.controls.iconLoaderClasses
{
	import flash.utils.ByteArray;
	
	/**
	 * Factory class to create a new object that implements the <code>IIconParser</code>
	 * interface.
	 */
	
	public class IconParserFactory
	{
		/**
		 * Reads the first few bytes from <code>data</code> and returns an object that
		 * implements <code>IIconParser</code>. If no parser is available for the data,
		 * <code>null</code> is returned
		 */
		 
		public static function newParser( data : ByteArray ) : IIconParser
		{
			data.position = 0;
			
			var b1	: int = data.readUnsignedByte();
			var b2	: int = data.readUnsignedByte();
			var b3	: int = data.readUnsignedByte();
			var b4	: int = data.readUnsignedByte();
			
			if( b1 == 0 && b2 == 0 && b3 == 1 && b4 == 0 )
			{
				return new IcoParser();
			}
			else if( b1 == 0x69 && b2 == 0x63 && b3 == 0x6e && b4 == 0x73 )
			{
				return new IcnsParser();
			}
			
			return null;
		}
	}
}