package flexlib.controls
{
	import flexlib.baseClasses.PopUpMenuButtonBase;
	
	import mx.core.IUIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
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
		
		/**
	    * @private
	    */
	    private var _verticalScrollPolicy:String;
	    
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
		private var _arrowScrollPolicy:String;
	    
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
	            popUpMenu.maxHeight = this.maxHeight;
	          
	            popUpMenu.labelField = labelField;
	            popUpMenu.labelFunction = labelFunction;
	            popUpMenu.showRoot = showRoot;
	            popUpMenu.dataDescriptor = dataDescriptor;
	            popUpMenu.dataProvider = dataProvider;

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
		
	}
}