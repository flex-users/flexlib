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

package flexlib.events
{
	import flash.events.Event;
	import flexlib.controls.area;

	/**
	 * An <code>ImageMapEvent</code> is like a generic Event, but we add the <code>href</code>, 
	 * <code>alt</code>, and <code>linkTarget</code> properties.
	 */
	public class ImageMapEvent extends Event
	{
		public static const SHAPE_CLICK:String = "shapeClick";
		public static const SHAPE_DOUBLECLICK:String = "shapeDoubleClick";
		
		public static const SHAPE_OVER:String = "shapeOver";
		public static const SHAPE_OUT:String = "shapeOut";
		public static const SHAPE_DOWN:String = "shapeDown";
		public static const SHAPE_UP:String = "shapeUp";
		
		
		public var href:String;
		public var item:area;
		public var linkTarget:String;
		
		public function ImageMapEvent(type:String, bubbles:Boolean = false,
									  cancelable:Boolean = false,
									  href:String=null, item:area=null, target:String=null) 
		{
			super(type, bubbles, cancelable);
			
			this.href = href;
			this.item = item;
			this.linkTarget = target;  
		}
		
	}
}