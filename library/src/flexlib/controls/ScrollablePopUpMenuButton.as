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
	
	import flexlib.baseClasses.PopUpMenuButtonBase;
	
	import mx.controls.scrollClasses.ScrollBar;
	import mx.controls.scrollClasses.ScrollThumb;
	import mx.core.IUIComponent;
	import mx.core.ScrollPolicy;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.ListEvent;
	import mx.events.MenuEvent;
	import mx.managers.PopUpManager;
	
	use namespace mx_internal;
	
	/**
	 * ScrollablePopUpMenuButton is an extension of PopUpMenuButton that uses <code>flexlib.controls.ScrollableMenu</code>
	 * instead of using the original <controls>mx.controls.Menu</controls>, which adds scrolling functionality
	 * to the menu.
	 * 
	 * <p>This control extends <code>PopUpMenuButtonBase</code>, which was a copy/paste version of the 
	 * original <code>mx.controls.PopUpMenuButton</code>. The only changes made to our copied version
	 * of the base class was to change some private variables and methods to protected, so we can
	 * access them here in our subclass.</p>
	 * 
	 * @mxml
	 *  
	 *  <p>The <code>&lt;flexlib:ScrollablePopUpMenuButton&gt;</code> tag inherits all of the tag
	 *  attributes of its superclass, and adds the following tag attributes:</p>
	 *  
	 *  <pre>
	 *  &lt;flexlib:ScrollablePopUpMenuButton
	 *    <strong>Properties</strong>
	 *    verticalScrollPolicy="auto|on|off"
	 * 	  arrowScrollPolicy="auto|on|off"
	 *    maxHeight="undefined"
	 * 
	 *  /&gt;
	 *  </pre>
	 * 
	 * @see mx.controls.PopUpMenuButton
	 */
	public class ScrollablePopUpMenuButton extends PopUpMenuButtonBase
	{
		/**
		 * Constructor
		 */
		public function ScrollablePopUpMenuButton()
		{
			super();
		}
		
		public var hideOnActivity:Boolean = true;
		private var bBlockClose:Boolean = false;
		
		/**
	    * @private
	    */
	    private var _verticalScrollPolicy:String = ScrollPolicy.AUTO;
	    
	    /**
	    * Controls the vertical scrolling of the ScrollablePopUpMenuButton.
	    */
	    public function get verticalScrollPolicy():String {
			return this._verticalScrollPolicy;
		}
		
		/**
		 * @private
		 */
	    public function set verticalScrollPolicy(value:String):void {
			var newPolicy:String = value.toLowerCase();
	
		    if (_verticalScrollPolicy != newPolicy)
		    {
		    	_verticalScrollPolicy = newPolicy;
		    }
		    
		    if(this.popUpMenu) {
		    	popUpMenu.verticalScrollPolicy = this.verticalScrollPolicy;
		    }
		}
		
		/**
		 * @private
		 */
		private var _arrowScrollPolicy:String = ScrollPolicy.OFF;
	    
	    /**
	    * The scrolling policy that determines when to show the up and down buttons for scrolling.
	    * 
	    * <p>This property is independant of <code>verticalScrollPolicy</code>. The property here
	    * just serves a proxy to set the <code>arrowScrollPolicy</code> of the child menu component.</p>
	    * 
	    * @see flexlib.controls.ScrollableMenu
	    */ 
	    public function get arrowScrollPolicy():String {
			return this._arrowScrollPolicy;
		}

		/**
		 *  @private
		 *  Storage for the rowCount property.
		 */
		private var _rowCount:int = -1;
		
		/**
		 * Indicates if the row count property was explicitely set.
		 */
		protected var explicitRowCountSet:Boolean = false;
		
		/**
		 *  Maximum number of rows visible in the Menu.
		 *  This property works in conjunction with the maxHeight property. If this property is never set,
		 *  the height of the menu is solely controlled using maxHeight. If this property is set,
		 *  the menu will exactly have <code>rowCount</code> rows except if the number of rows times a
		 *  row's height exceed maxHeight. In this case, the menu will have as many rows as possible without
		 *  exceeding maxHeight.
		 * 
		 *  If this property has been set and it needs to revert to having the menu height solely controlled by
		 *  maxHeight, set this property to -1.
		 * 
		 *  @default -1
		 * 
		 *  @see #maxHeight()
		 */
		public function get rowCount():int
		{
			var dataLength:int = (dataProvider && dataProvider.hasOwnProperty("length")) ? dataProvider.length : _rowCount;
		    return Math.min(dataLength, _rowCount);
		}

	    /**
	     *  @private
	     */
	    public function set rowCount(value:int):void
	    {
	        _rowCount = value;
			explicitRowCountSet = (value > 0) ? true : false;
				
	        if (popUpMenu)
	            popUpMenu.rowCount = value;
	    }
		
	    /**
	    * @private
	    */
	    public function set arrowScrollPolicy(value:String):void {
			var newPolicy:String = value.toLowerCase();
	
		    if (_arrowScrollPolicy != newPolicy)
		    {
		    	_arrowScrollPolicy = newPolicy;
		    }
		    
		    if(this.popUpMenu) {
		    	(popUpMenu as ScrollableArrowMenu).arrowScrollPolicy = this.arrowScrollPolicy;
		    }
		}
			
		/**
		 * Overriden to also set the maxHeight of the child menu control.
		 * 
		 * <p>This makes setting the maxHeight also set the maxHeight of the popUpMenu item.</p>
		 */ 
		override public function set maxHeight(value:Number):void {
			if(popUpMenu) {
				popUpMenu.maxHeight = value;
			}
			
			super.maxHeight = value;
		}
		
		/**
	     * @private
	     * 
	     * This override is needed because we need to create a ScrollableArrowMenu instead of
	     * a normal Menu control. This is basically the same function as in the original
	     * PopUpMenuButton class, with a few minor changes.
	     */
	    override mx_internal function getPopUp():IUIComponent
	    {
	       
	        if (!popUpMenu)
	        {
	        	popUpMenu = new ScrollableArrowMenu();
	            ScrollableArrowMenu(popUpMenu).hideOnActivity = hideOnActivity;
	            popUpMenu.addEventListener(
                    ListEvent.ITEM_CLICK, popUpItemClickHandler, false, 999);
                    
	          	popUpMenu.maxHeight = this.maxHeight;
	          	
	            popUpMenu.labelField = labelField;
	            popUpMenu.labelFunction = labelFunction;
	            popUpMenu.showRoot = showRoot;
	            if (explicitRowCountSet) popUpMenu.rowCount = rowCount;
	            popUpMenu.dataDescriptor = dataDescriptor;
	            popUpMenu.dataProvider = dataProvider;

				popUpMenu.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, mouseDownOutsideHandler, false, 999);
	            popUpMenu.addEventListener(MenuEvent.ITEM_CLICK, menuChangeHandler);
	            popUpMenu.addEventListener(FlexEvent.VALUE_COMMIT,
	                                       menuValueCommitHandler);
	            super.popUp = popUpMenu;
	            // Add PopUp to PopUpManager here so that
	            // commitProperties of Menu gets called even
	            // before the PopUp is opened. This is 
	            // necessary to get the initial label and dp.
	            PopUpManager.addPopUp(super.popUp, this, false);
	            super.popUp.owner = this;
	        }
	        else {
	        	popUpMenu.invalidateDisplayList();
	        }
	        
	        if(popUpMenu.verticalScrollPolicy != this.verticalScrollPolicy) {
	        	popUpMenu.verticalScrollPolicy = this.verticalScrollPolicy;
	        }
	        
	        if((popUpMenu as ScrollableArrowMenu).arrowScrollPolicy != this.arrowScrollPolicy) {
	        	(popUpMenu as ScrollableArrowMenu).arrowScrollPolicy = this.arrowScrollPolicy;
	        }
	
	        return popUpMenu;
	    }
	    
	    private function popUpItemClickHandler(event:ListEvent):void {
	    	if(hideOnActivity == false) {
	    		bBlockClose = true;
	    	}
	    }
	    
	    override public function close():void {
	    	if(bBlockClose == false) {
	    		super.close();
	    	}
	    	
	    	bBlockClose = false;
	    }
		
		private function mouseDownOutsideHandler(event:FlexMouseEvent):void {
			if(event.relatedObject is ScrollThumb || event.relatedObject is ScrollBar) {
				event.stopImmediatePropagation();
			}
			else {
				if(hideOnActivity == false) {
					var p:DisplayObject = event.target.parent;
					
					while(p != null) {
						
						if(p == popUpMenu) {
							event.stopImmediatePropagation();
							break;	
						}
						
						p = p.parent;
					}
				}
			}
		}
		
		override public function set dataProvider(value:Object):void {
			if(popUpMenu)
				popUpMenu.verticalScrollPosition = 0;
			super.dataProvider = value;
		}
	}
}