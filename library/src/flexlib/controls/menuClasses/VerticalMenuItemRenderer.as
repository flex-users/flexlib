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

package flexlib.controls.menuClasses
{
	import mx.controls.menuClasses.MenuItemRenderer;
	import mx.controls.MenuBar;
	import flexlib.controls.VerticalMenuBar;

	[ExcludeClass]

	public class VerticalMenuItemRenderer extends MenuItemRenderer
	{
		//Space on the left before the branch icon (if there is one)
		private var leftMargin:int = 5;
		
		/**
		 * This class is used as the menuItemRenderer for vertical menus 
		 * that need to go to the left. It's nothing more than a simple
		 * extension of MenuItemRenderer that flips and repositions the 
		 * branch icon.
		 * */
		public function VerticalMenuItemRenderer()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			/* We're going to flip the branchIcon by setting scaleX to -1. 
			 * This means we have to move it a bit to the right of where you
			 * might think it would go, since now the x,y position of 0,0 is the
			 * top-right corner, not the top-left.
			 */
			if (branchIcon)
			{
				branchIcon.scaleX = -1;
				branchIcon.x = leftMargin + branchIcon.width;
			}
		}
	}
}