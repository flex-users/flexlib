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
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * The <code>IIconParser</code> interface defines the methods and properties that an
	 * icon parser must implement
	 */
	 
	public interface IIconParser
	{
		/**
		 * Indicates that this parser contains valid icon data.
		 * 
		 * <p>Implementations should return <code>true</code> if an icon file has been parsed
		 * successfully, and it contains at least one valid icon</p>
		 */
		 
		function get validIcon() : Boolean;
		
		/**
		 * The list of icon sizes in decreasing order.
		 */
		 
		function get sizes() : Array;
		
		/**
		 * The raw data from the icon file.
		 */
		
		function get data() : ByteArray;
		function set data( val : ByteArray ) : void;
		
		/**
		 * Attempt to parse an icon file
		 */
		 
		function parse() : void;
		
		/**
		 * Returns an icon whose width does not exceed <code>s</code>.
		 */
		 
		function getIconForSize( s : int ) : BitmapData;
	}
}