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

package flexlib.containers
{
import flash.events.MouseEvent;
import flash.display.DisplayObject;
import flash.geom.Point;
import mx.containers.TitleWindow;
import mx.containers.HBox;
import mx.core.*;
use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  Used internally by the Dockable ToolBar.
 */

public class PopUpToolBar extends TitleWindow
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function PopUpToolBar()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Called when the user stops dragging a Panel
	 *  that has been popped up by the PopUpManager.
	 */
	override protected function startDragging(event:MouseEvent):void
	{
	}

	/**
	 *  @private
	 *  Specialized layout for one child.
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
											   unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		if (numChildren)
		{
			var child:IUIComponent = IUIComponent(getChildAt(0));
			child.setActualSize(unscaledWidth, child.getExplicitOrMeasuredHeight());
		}
	}
	
	public function getTitleBar():UIComponent
	{
		return super.titleBar;
	}	
}
}
