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
  import flash.display.DisplayObjectContainer;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.utils.clearInterval;

  import mx.collections.ICollectionView;
  import mx.controls.Menu;
  import mx.controls.listClasses.IListItemRenderer;
  import mx.controls.menuClasses.IMenuItemRenderer;
  import mx.core.Application;
  import mx.core.EdgeMetrics;
  import mx.core.ScrollPolicy;
  import mx.core.mx_internal;
  import mx.events.ScrollEvent;
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
    public var hideOnActivity:Boolean = true;

    private var bBlockHideEvent:Boolean = false;

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
    override public function get verticalScrollPolicy():String
    {
      return this._verticalScrollPolicy;
    }

    /**
     * @private
     *
     * <p>This setter is basically a copy of what ScrollControlBase and ListBase do.</p>
     */
    override public function set verticalScrollPolicy(value:String):void
    {
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
     * Sub menu instance created by this menu.
     */
    private var subMenu:Menu = null;

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
      if (rowCount == 0)
      {
        return;
      }

      // if there is more than one row and it is a partial row we dont count it
      if (rowCount > 1 && rowInfo[rowCount - 1].y + rowInfo[rowCount - 1].height > listContent.height)
      {
        rowCount--;
      }

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
        {
          break;
        }
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
      var length:int = collection ? collection.length - lockedRowCount : 0;
      var numRows:int = rowCount - lockedRowCount;

      /* This call is slightly modified from mx.controls.List, but not by much */
      setScrollBarProperties(Math.round(listContent.width), roundedWidth, length, numRows);
      maxVerticalScrollPosition = Math.max(length - numRows, 0);

      if (verticalScrollBar)
      {
        verticalScrollBar.removeEventListener(ScrollEvent.SCROLL, onScroll);
        verticalScrollBar.addEventListener(ScrollEvent.SCROLL, onScroll, false, 0, true);
      }
    }

    /**
     * Callback function called when the menu scroll bar is scrolled
     *
     * @param event The scroll event
     *
     */
    protected function onScroll(event:ScrollEvent):void
    {
      if (subMenu)
      {
        subMenu.hide();
      }
    }

    /**
     * @inheritDoc
     *
     */
    override public function hide():void
    {
      if (verticalScrollBar)
      {
        verticalScrollBar.removeEventListener(ScrollEvent.SCROLL, onScroll);
      }
      super.hide();
    }

    /**
     * Clear the menu reference from the menu item renderer
     *
     * @param row The menu item renderer
     *
     */
    protected function clearMenu(row:IMenuItemRenderer):void
    {
      var menu:Menu = row.menu;
      menu.hide();
      clearInterval(menu.closeTimer);
      menu.closeTimer = 0;
      row.menu = null;
    }

    /**
     * @inheritDoc
     *
     */
    override public function set rowCount(value:int):void
    {
      // Forces scroll bar to top when row count is removed
      if (value < 0)
      {
        verticalScrollPosition = 0;
      }
      super.rowCount = value;
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

      // TRICKY: The default implementation uses the item renderer to store a reference to the menu.
      //			When all items are visible, it means that all items have an item renderer and thus the logic
      //			works. However, in a scrollable list, item renderers are recycled so it doesn't make sense to store
      //			the menu reference on the item renderer. If the item renderer data and the menu data are different,
      //			it means that the item renderer has been recycled and we are going to clear the menu in order to
      //			recreate the proper one. BAD IDEA from Adobe to use item renderers to store data!!!!
      if (row.data)
      {
        if (IMenuItemRenderer(row).menu)
        {
          // Lets compare with the menu
          var rendererMenu:Menu = IMenuItemRenderer(row).menu;
          var newData:ICollectionView = _dataDescriptor.getChildren(row.data);
          var currentData:ICollectionView = rendererMenu.dataProvider as ICollectionView;
          if (newData != currentData)
          {
            clearMenu(row as IMenuItemRenderer);
          }
        }
      }
      else
      {
        // No data, clear the menu immediately
        clearMenu(row as IMenuItemRenderer);
      }

      // check to see if the menu exists, if not create it
      if (!IMenuItemRenderer(row).menu)
      {
        menu = createSubMenu();
        subMenu = menu;

        menu.maxHeight = this.maxHeight;
        menu.maxWidth = this.maxWidth;
        menu.verticalScrollPolicy = this.verticalScrollPolicy;
        menu.variableRowHeight = this.variableRowHeight;

        menu.parentMenu = this;
        menu.owner = this;
        menu.showRoot = showRoot;
        //menu.rowCount = rowCount;
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

        ScrollableMenu(menu).hideOnActivity = hideOnActivity;

        // if there's data and it has children then add the items
        if (row.data && _dataDescriptor.isBranch(row.data) && _dataDescriptor.hasChildren(row.data))
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

    protected function createSubMenu():Menu
    {
      return new ScrollableMenu();
    }

    private var xShow:Object = 0;
    private var yShow:Object = 0;

    override public function show(xShow:Object=null, yShow:Object=null):void
    {
      // When a sub menu is opened, the openSubMenu function, from the Menu class, receives
      // a MenuItemRenderer as input. The item renderer does not have provision for a scrollbar
      // so, we need to take that into account here if we want the sub-menu to open past the scroll bar.
      if (parentMenu != null)
      {
        with (parentMenu)
        {
          if ((verticalScrollPolicy == ScrollPolicy.ON || verticalScrollPolicy == ScrollPolicy.AUTO) &&
            verticalScrollBar && verticalScrollBar.visible)
          {
            xShow += verticalScrollBar.width;
          }
        }
      }

      //configureScrollBars();

      /*
         if( (verticalScrollPolicy == ScrollPolicy.ON || verticalScrollPolicy == ScrollPolicy.AUTO) &&
         verticalScrollBar && verticalScrollBar.visible) {

         measuredWidth -= verticalScrollBar.width;
         }
       */
      this.xShow = xShow;
      this.yShow = yShow;

      super.show(xShow, yShow);

      if (x + width >= screen.width - 12)
      {
        x = screen.width - width - 12;
      }
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

      if (explicitRowCount < 1)
      {
        // Number of rows was not explicitly set so limit menu height to max height and 
        if (measuredHeight > this.maxHeight)
        {
          measuredHeight = this.maxHeight;
        }
      }
      else
      {
        // Number of rows was explicitely set. Just make sure that the height of the menu does not go beyond the
        // maximum height
        var o:EdgeMetrics = viewMetrics;

        var rc:int = 0;
        if (!isNaN(explicitRowHeight))
        {
          rc = Math.min(int(maxHeight / explicitRowHeight), explicitRowCount, dataProvider.length);
          measuredHeight = explicitRowHeight * rc + o.top + o.bottom;
          measuredMinHeight = explicitRowHeight * Math.min(rc, 2) +
            o.top + o.bottom;
        }
        else
        {
          rc = Math.min(int(maxHeight / rowHeight), explicitRowCount, dataProvider.length);
          measuredHeight = rowHeight * rc + o.top + o.bottom;
          measuredMinHeight = rowHeight * Math.min(rc, 2) +
            o.top + o.bottom;
        }
      }

      // Factor in scrollbars.
      if (verticalScrollPolicy == ScrollPolicy.ON || verticalScrollPolicy == ScrollPolicy.AUTO)
      {
        if (verticalScrollBar && verticalScrollBar.visible)
        {
          measuredWidth += verticalScrollBar.minWidth;
          measuredMinWidth += verticalScrollBar.minWidth;
        }
      }

      var pt:Point = new Point(0, 0);
      pt = this.localToGlobal(pt);

      var stageHeightAvailable:Number = screen.y + screen.height - pt.y - 10;
      if (stageHeightAvailable < measuredHeight)
      {
        measuredHeight = measuredMinHeight = stageHeightAvailable;
      }

      //      invalidateProperties();
    }

    /**
     *  @inheritDoc
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
      // The standard implementation draws a mask using a rectangle, it doesn't take into
      // account that the border can have rounded corners. So, redraw the mask properly,
      // this time taking into account the rounded corners.
      var cornerRadius:Number = (getStyle("cornerRadius")) ? getStyle("cornerRadius") : 0;
      with (maskShape)
      {
        graphics.clear();
        graphics.beginFill(0xFFFFFF); // Color is not important, it's a mask
        if (verticalScrollBar && verticalScrollBar.visible)
        {
          // The menu has scroll bars so only the upper and bottom left corners are rounded
          graphics.drawRoundRectComplex(0, 0, unscaledWidth, unscaledHeight, cornerRadius, 0, cornerRadius,
                                        0);
        }
        else
        {
          // The menu has NO scroll bars so all corners are rounded
          graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 2 * cornerRadius, 2 * cornerRadius);
        }
        graphics.endFill();
      }

      var hadVertScroll:Boolean = verticalScrollBar != null && verticalScrollBar.visible;

      // Continue with super class
      super.updateDisplayList(unscaledWidth, unscaledHeight);
    }

    override protected function mouseUpHandler(event:MouseEvent):void
    {
      if (hideOnActivity == false)
      {
        bBlockHideEvent = true;
      }

      super.mouseUpHandler(event);

      if (hideOnActivity == false)
      {
        bBlockHideEvent = false;
      }
    }

    override mx_internal function hideAllMenus():void
    {
      if (bBlockHideEvent == false)
      {
        super.hideAllMenus();
      }
    }

    /**
     *  @inheritDoc
     */
    override public function move(x:Number, y:Number):void
    {
      invalidateSize();
      super.move(x, y);
    }

    override public function set dataProvider(value:Object):void
    {
      super.dataProvider = value;

      invalidateSize();
      invalidateDisplayList();
    }
  }
}