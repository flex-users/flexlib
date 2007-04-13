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

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import mx.containers.utilityClasses.BoxLayout;
import mx.containers.utilityClasses.Layout;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Button;
import mx.core.Container;
import mx.core.EdgeMetrics;
import mx.core.IFlexDisplayObject;
import mx.core.IUIComponent;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;

import flexlib.containers.DockableToolBar;

use namespace mx_internal;

/**
 *  Name of the CSS Style declaration to use for the styles for the docking area at 
 *  the top and bottom.
 *  By default, the Dockers's inheritable styles are used.
 */
[Style(name="dockingAreaStyleName", type="String", inherit="no")]

/**
 *  Name of the CSS Style declaration to use for one row in the docking area.
 *  By default, the Dockers's inheritable styles are used.
 */
[Style(name="rowStyleName", type="String", inherit="no")]

/**
 *  The Docker container is used as a parent to all DockableToolBars
 *  and related controls in a Docking ToolBars context. UI controls
 *  which need to be outside the docking context (for eg. StatusBar or Menus)
 *  should be placed outside the Docker container.
 *  
 *
 *
 *  @see flexlib.containers.DockableToolBar
 *
 */

public class Docker extends Container
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function Docker()
	{
		super();

		layoutObject = new BoxLayout();
		layoutObject.target = this;
        	percentHeight = percentWidth = 100;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * A reference to the proxy layer used to draw the indicators of the final position
	 * of the ToolBar
	 */
	mx_internal var dragProxy:UIComponent;
	
	private var dockerViewMetrics:EdgeMetrics;
	private var layoutObject:Layout;

	private var topBar:VBox;
	private var bottomBar:VBox;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override public function get viewMetrics():EdgeMetrics
	{
		if (!dockerViewMetrics)
			dockerViewMetrics = new EdgeMetrics(0, 0, 0, 0);
		var vm:EdgeMetrics = dockerViewMetrics;

		var o:EdgeMetrics = super.viewMetrics;

		vm.left = o.left;
		vm.top = o.top;
		vm.right = o.right;
		vm.bottom = o.bottom;
		
		vm.top += topBar.getExplicitOrMeasuredHeight();
		vm.bottom += bottomBar.getExplicitOrMeasuredHeight();

		return vm;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Measure container as the layout object.
	 */
	override protected function measure():void
	{
		super.measure();

		layoutObject.measure();
		
		measuredMinHeight = 0;
		measuredMinWidth = 0;
		topBar.minWidth = 0;
		bottomBar.minWidth = 0;
	}		
	
	/**
	 *  @private
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		layoutObject.updateDisplayList(unscaledWidth, unscaledHeight);
		
		for (var i:int = 0; i < topBar.numChildren; i++)
		{
			wrapRow(HBox(topBar.getChildAt(i)), i, topBar);
		}
		for (i = 0; i < bottomBar.numChildren; i++)
		{
			wrapRow(HBox(bottomBar.getChildAt(i)), i, bottomBar);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function createChildren():void
	{

		if (!topBar)
		{
			topBar = new VBox();
			bottomBar = new VBox();
			bottomBar.percentWidth = topBar.percentWidth = 100;
			bottomBar.horizontalScrollPolicy = topBar.horizontalScrollPolicy = "off";
			bottomBar.verticalScrollPolicy = topBar.verticalScrollPolicy = "off";
			rawChildren.addChild(topBar);
			rawChildren.addChild(bottomBar);
		}
		
		var toolBarStyleName:String = getStyle("dockingAreaStyleName");
	   	topBar.styleName = bottomBar.styleName = toolBarStyleName ? toolBarStyleName : this;

		super.createChildren();

	}

	/**
	 *  @private
	 */
	override public function createComponentsFromDescriptors(
								recurse:Boolean = true):void
	{
		super.createComponentsFromDescriptors();
		
		// Change DockableToolBar from from being content child 
		// to a chrome child i.e., move it to the rawChildren collection.
		
		for(var i:int=0;i<numChildren;i++)
		{
			var child:IUIComponent = IUIComponent(getChildAt(i));
			if (child is DockableToolBar)
			{
				if (contentPane)
				{
				    contentPane.removeChild(DisplayObject(child));
				}
				else
				{
					removeChild(DisplayObject(child));
				}
				addToolBar(1, DockableToolBar(child));
				i--;
			}
		}
			
	}

	/**
	 *  @private
	 */
	override protected function layoutChrome(unscaledWidth:Number,
											 unscaledHeight:Number):void
	{
		super.layoutChrome(unscaledWidth, unscaledHeight);
		
		var bm:EdgeMetrics = borderMetrics;
		
		var x:Number = bm.left;
		var y:Number = bm.top;
		
		topBar.move(0, 0);
		IFlexDisplayObject(topBar).setActualSize(unscaledWidth, 
			topBar.getExplicitOrMeasuredHeight());

		var h:int = bottomBar.getExplicitOrMeasuredHeight();
		bottomBar.move(0, unscaledHeight - h);
		IFlexDisplayObject(bottomBar).setActualSize(unscaledWidth, h);
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Creates the Docking areas at the top and bottom of the container
	 */
	private function addToolBar(tb:int, child:DockableToolBar):void
	{
		var toolbar:VBox = topBar;
		if (child.initialPosition == "bottom")
		{
			toolbar = bottomBar
		}
		
		if (!toolbar.numChildren)
		{
			row = createRow();
			toolbar.addChild(row);
		}
		
		var row:HBox = HBox(toolbar.getChildAt(toolbar.numChildren - 1));
		row.addChild(child);
		child.docker = this;

	}

	/**
	 *  @private
	 *  Creates a single row to be added to the Docking areas.
	 */
	private function createRow():HBox
	{
		var row:HBox = new HBox();
		row.percentWidth = 100;
		row.horizontalScrollPolicy = "off";

		var rowStyleName:String = getStyle("rowStyleName");
		row.styleName = rowStyleName ? rowStyleName : this;
		return row;
	}
	
	/**
	 *  @private
	 *  Moves ToolBars to a new row if there is insufficient space in this row to display
	 *  all the ToolBars properly.
	 */
	private function wrapRow(row:HBox, rowIndex:int, toolbar:VBox):void
	{
		var totalW:int = 0;
		var newRow:HBox;
		for (var j:int = 0; j < row.numChildren; j++)
		{	
			var ch:DockableToolBar = DockableToolBar(row.getChildAt(j));
			totalW += ch.measuredWidth;
			if (totalW > toolbar.width && j)
			{
				if (!newRow)
				{
					if (toolbar.numChildren - 1 > rowIndex)
						newRow =  HBox(toolbar.getChildAt(rowIndex + 1));
					else
					{
						newRow = createRow();
						toolbar.addChildAt(newRow, rowIndex + 1);
					}
				}
				ch.parent.removeChild(ch);
				newRow.addChild(ch);				
			}
		}
		if (newRow)
			wrapRow(newRow, rowIndex + 1, toolbar);
	}
	
 	/**
	 *  @private
	 *  Called by the DockableToolBar to display the docking placement indicators and
	 *  add the ToolBar to a correct location.
	 */
  	mx_internal function dragOver(item:DockableToolBar, event:MouseEvent, 
  			finalPlacement:Boolean = false):Boolean
	{
		var pt:Point = new Point(event.stageX, event.stageY);
		pt = globalToLocal(pt);
		var toolbar:VBox;
		if (pt.y < topBar.height + 15)
			toolbar = topBar;
		else if (pt.y > bottomBar.y - 15)
		{
			toolbar = bottomBar;
			pt.y -= bottomBar.y;
		}

		if (!dragProxy)
		{
			dragProxy = new UIComponent();
			PopUpManager.addPopUp(dragProxy, this);
		}
		else
			dragProxy.graphics.clear();
			
		if (toolbar)
		{
			var x1:int, y1:int;
			var x2:int, y2:int;
			var rowIndex:int = toolbar.numChildren;
			var colIndex:int;
			var createNewRow:Boolean = true;
			
			y1 = y2 = toolbar.height;
			x2 = toolbar.width;
			var row:HBox;
			
			for (var i:int = 0; i < toolbar.numChildren; i++)
			{
				row = HBox(toolbar.getChildAt(i));
				if (pt.y <= row.y + row.height * 0.25)
				{
					rowIndex = i;
					y1 = y2 = row.y;
					break;
				}
				
				if (pt.y >= row.y && pt.y <= row.y + row.height * 0.75)
				{
					var child:DisplayObject = row.getChildAt(row.numChildren - 1);
					x1 = x2 = child.x + child.width;
					colIndex = row.numChildren;
					rowIndex = i;
					for (var j:int = 0; j < row.numChildren; j++)
					{	
						child = row.getChildAt(j);
						if (pt.x < child.x + child.width / 2)
						{
							colIndex = j;
							x2 = x1 = child.x;
							break;
						}
					}
					
					if (item.parent == row)
					{
						if ((row.getChildIndex(item) == j - 1 || child == item))
							return true;
					}
					else if (colIndex == row.numChildren && 
						item.measuredWidth + row.measuredWidth > toolbar.width && !finalPlacement)
						return true;
					y1 = row.y;
					y2 = row.y + row.height;
					createNewRow = false;
					break;
				}
			}
			
			if (finalPlacement)
			{
				if (createNewRow)
				{
					row = createRow();
					toolbar.addChildAt(row,rowIndex);
				}
				else
					row = HBox(toolbar.getChildAt(rowIndex));

				var p:UIComponent = UIComponent(item.parent);
				
				if (row == p && p.getChildIndex(item) < colIndex)
					colIndex--;
					
				p.removeChild(item);
				row.addChildAt(item, colIndex);		
				wrapRow(row, rowIndex, toolbar);

				if (p is HBox && p.numChildren == 0)
					p.parent.removeChild(p);
	
			}
			else
			{
				pt = new Point(x1, toolbar.y + y1);
				pt = localToGlobal(pt);
				var g:Graphics = dragProxy.graphics;
				g.lineStyle(3, getStyle("themeColor"), 0.5);
				g.drawRect(pt.x, pt.y, x2 - x1, y2 - y1);
				g.lineStyle(1, getStyle("themeColor"), 1.0);
				g.drawRect(pt.x, pt.y, x2 - x1, y2 - y1);
			}
			return true;
		}

		return false;
	}
}

}