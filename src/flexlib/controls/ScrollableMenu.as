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

package flexlib.controls
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.controls.Menu;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.menuClasses.IMenuBarItemRenderer;
	import mx.controls.menuClasses.IMenuItemRenderer;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.Application;
	import mx.core.EdgeMetrics;
	import mx.core.ScrollPolicy;
	import mx.core.mx_internal;
	import mx.managers.PopUpManager;
	
	use namespace mx_internal;

	[IconFile("ScrollableMenu.png")]
	
	/**
	 * An extension of mx.controls.Menu that allows the control to scroll vertically.
	 * 
	 * <p>Overrides a few methods and properties so we can re-enable scrolling. The 
	 * Menu control in the Flex framework intentionally disables vertical scrolling.
	 * This class simply undoes alot of that. We reinstitute normal <code>verticalScrollPolicy</code>
	 * functionality.</p>
	 * 
	 * @see mx.controls.Menu
	 */
	public class ScrollableMenu extends Menu
	{
		/**
		 * Constructor
		 */
		public function ScrollableMenu()
		{
			super();
		}
		
		/**
		 * We have to override the static function createMenu so that we create a 
		 * ScrollableMenu instead of a normal Menu.
		 */ 
		public static function createMenu(parent:DisplayObjectContainer, mdp:Object, showRoot:Boolean=true):ScrollableMenu
	    {	
	        var menu:ScrollableMenu = new ScrollableMenu();
	        menu.tabEnabled = false;
	        menu.owner = DisplayObjectContainer(Application.application);
	        menu.showRoot = showRoot;
	        popUpMenu(menu, parent, mdp);
	        return menu;
	    }
	  
		
		/** 
		 * Override the verticalScrollPolicy so we can re-instate scrolling functionality.
		 * 
		 * <p>The mx.controls.Menu class overrides setting and getting the verticalScrollPolicy
		 * Basically setting the verticalScrollPolicy did nothing, and getting it always 
		 * returned ScrollPolicy.OFF. So that's not going to work if we want the menu to scroll.
		 * Here we reinstate the verticalScrollPolicy setter, and keep a local copy of the value
		 * in a private variable _verticalScrollPolicy.</p>
		 * 
		 */ 
		override public function get verticalScrollPolicy():String {
			return this._verticalScrollPolicy;
		}
		
		/**
		 * @private
		 * 
		 * <p>This setter is basically a copy of what ScrollControlBase and ListBase do.</p>
		 */
		override public function set verticalScrollPolicy(value:String):void {
			var newPolicy:String = value.toLowerCase();

	        itemsSizeChanged = true;

	        if (_verticalScrollPolicy != newPolicy)
	        {
	            _verticalScrollPolicy = newPolicy;
	            dispatchEvent(new Event("verticalScrollPolicyChanged"));
	        }
	        
	        
        	invalidateDisplayList();
		}
		
		/** 
		 * Overridden to reinstate proper scrolling functionality.
		 * 
		 * <p>The Menu class overrode configureScrollBars() and made the function 
		 * do nothing. That means the scrollbars don't know how to draw themselves,
		 * so here we reinstate configureScrollBars. This is basically a copy of the 
		 * same method from the mx.controls.List class. It would have been nice if
		 * we could have called this method from down in a subclass of Menu, but AS
		 * doesn't let us do something like super.super, so instead we have to recreate
		 * the class here.</p>
		 * */
		override protected function configureScrollBars():void
	    {
	        var rowCount:int = listItems.length;
	        if (rowCount == 0) return;
	
	        // if there is more than one row and it is a partial row we dont count it
	        if (rowCount > 1 && rowInfo[rowCount - 1].y + rowInfo[rowCount-1].height > listContent.height)
	            rowCount--;
	
	        // offset, when added to rowCount, is the index of the dataProvider
	        // item for that row.  IOW, row 10 in listItems is showing dataProvider
	        // item 10 + verticalScrollPosition - lockedRowCount - 1;
	        var offset:int = verticalScrollPosition - lockedRowCount - 1;
	        // don't count filler rows at the bottom either.
	        var fillerRows:int = 0;
	        // don't count filler rows at the bottom either.
	        while (rowCount && listItems[rowCount - 1].length == 0)
	        {
	            if (collection && rowCount + offset >= collection.length)
	            {
	                rowCount--;
	                ++fillerRows;
	            }
	            else
	                break;
	        }
	
			/* 
			 This part needs further functions from mx.controls.List that we don't have 
			 access to. What to do? Whatever, I'll just comment it out and cross my fingers
			 */			
	        // we have to scroll up.  We can't have filler rows unless the scrollPosition is 0
	        /*
	        if (verticalScrollPosition > 0 && fillerRows > 0)
	        {
	            if (adjustVerticalScrollPositionDownward(Math.max(rowCount, 1)))
	                return;
	        }*/
	
	        var colCount:int = listItems[0].length;
	        var oldHorizontalScrollBar:Object = horizontalScrollBar;
	        var oldVerticalScrollBar:Object = verticalScrollBar;
	        var roundedWidth:int = Math.round(unscaledWidth);
	        var length:int = collection ? collection.length - lockedRowCount: 0;
	        var numRows:int = rowCount - lockedRowCount;
	        
	        /* This call is slightly modified from mx.controls.List, but not by much */
	        setScrollBarProperties(
	                            Math.round(listContent.width) ,
	                            roundedWidth, length, numRows);
	        maxVerticalScrollPosition = Math.max(length - numRows, 0);
	
	    }
	    
	    /**
	    * Overridden to reinstate proper scrolling functionality.
	    * 
	    * <p>We need to override openSubMenu as well, so that any subMenus opened by this Menu controls
	    * will also be ScrollableMenus and will have the same maxHeight set.</p>
	    */
	    override mx_internal function openSubMenu(row:IListItemRenderer):void
	    {
	        supposedToLoseFocus = true;
	
	        var r:Menu = getRootMenu();
	        var menu:Menu;
	
	        // check to see if the menu exists, if not create it
	        if (!IMenuItemRenderer(row).menu)
	        {
	            /* The only differences between this method and the original method in mx.controls.Menu
	             * are these two lines.
	             */
	            menu = new ScrollableMenu();
	            menu.maxHeight = this.maxHeight;
	            menu.verticalScrollPolicy = this.verticalScrollPolicy;
	            
	            
	            menu.parentMenu = this;
	            menu.owner = this;
	            menu.showRoot = showRoot;
	            menu.dataDescriptor = r.dataDescriptor;
	            menu.styleName = r;
	            menu.labelField = r.labelField;
	            menu.labelFunction = r.labelFunction;
	            menu.iconField = r.iconField;
	            menu.iconFunction = r.iconFunction;
	            menu.itemRenderer = r.itemRenderer;
	            menu.rowHeight = r.rowHeight;
	            menu.scaleY = r.scaleY;
	            menu.scaleX = r.scaleX;
	
	            // if there's data and it has children then add the items
	            if (row.data && 
	                _dataDescriptor.isBranch(row.data) &&
	                _dataDescriptor.hasChildren(row.data))
	            {
	                menu.dataProvider = _dataDescriptor.getChildren(row.data);
	            }
	            menu.sourceMenuBar = sourceMenuBar;
	            menu.sourceMenuBarItem = sourceMenuBarItem;
	
	            IMenuItemRenderer(row).menu = menu;
	            PopUpManager.addPopUp(menu, r, false);
	        }
	        
	        super.openSubMenu(row);
	    }
	    
	    /**
	    * We overide the <code>measure()</code> method because we need to check if the menu is going off
	    * the stage. If it's going to be too high, then we make it smaller to keep it from
	    * going off. I also stuck in a buffer of 10 pixels from the bottom of the stage.
	    * 
	    * We also check if we're showing the vertical scrollbar, and if so we adjust the 
	    * width to account for that.
	    */
	    override protected function measure():void
	    {
	        super.measure();

			if(measuredHeight > this.maxHeight) {
				measuredHeight = this.maxHeight;
			}
			
			if(verticalScrollPolicy == ScrollPolicy.ON || verticalScrollPolicy == ScrollPolicy.AUTO) {
				if(verticalScrollBar) {
					measuredMinWidth = measuredWidth = measuredWidth + verticalScrollBar.minWidth;
				}
			}
			
			var pt:Point = new Point(0, 0);
			pt = this.localToGlobal(pt);
			
			var stageHeightAvailable:Number = screen.y + screen.height - pt.y - 10;
			if(stageHeightAvailable < measuredHeight) {
				measuredHeight = stageHeightAvailable;
				invalidateSize();
			}     
			
			commitProperties();
		}
    
  
	}
}