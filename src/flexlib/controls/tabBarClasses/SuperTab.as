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

package flexlib.controls.tabBarClasses
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFieldType;
	
	import flexlib.events.SuperTabEvent;
	
	import mx.controls.Button;
	import mx.controls.tabBarClasses.Tab;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	/**
	 * Fired when the the label of this tab is updated by the user double clicking and editing the 
	 * tab label. Only possible if dougbleClickToEdit is true.
	 */
	[Event(name="tabUpdated", type="flexlib.events.SuperTabEvent")]
	
	/**
	 *  Name of CSS style declaration that specifies the style to use for the 
	 *  close button
	 */
	[Style(name="tabCloseButtonStyleName", type="String", inherit="no")]
	
	/**
	 *  The class that is used for the indicator
	 */
	[Style(name="indicatorClass", type="String", inherit="no")]
	
	
	public class SuperTab extends Tab {
		
		public static const CLOSE_TAB_EVENT:String = "closeTab";
		
		/**
		 * Static variables indicating the policy to show the close button.
		 * 
		 * CLOSE_ALWAYS means the close button is always shown
		 * CLOSE_SELECTED means the close button is only shown on the currently selected tab
		 * CLOSE_ROLLOVER means the close button is show if the mouse rolls over a tab
		 * CLOSE_NEVER means the close button is never show.
		 */
		public static const CLOSE_ALWAYS:String = "close_always";
		public static const CLOSE_SELECTED:String = "close_selected";
		public static const CLOSE_ROLLOVER:String = "close_rollover";
		public static const CLOSE_NEVER:String = "close_never";
		
		// Our private variable to track the rollover state
		private var _rolledOver:Boolean = false;
		
		
		private var closeButton:Button;
		private var indicator:DisplayObject;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 *  Constructor.
		 */
		public function SuperTab():void {
			super();
			
			// We need to enabled mouseChildren so our closeButton can receive
			// mouse events.
			this.mouseChildren = true;
			
			this.doubleClickEnabled = true;
			this.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
		}
	
		private var _closePolicy:String;
		
		/**
		 * A string representing when to show the close button for the tab.
		 * Possible values include: SuperTab.CLOSE_ALWAYS, SuperTab.CLOSE_SELECTED,
		 * SuperTab.CLOSE_ROLLOVER, SuperTab.CLOSE_NEVER
		 */
		public function get closePolicy():String {
			return _closePolicy;
		}
		
		public function set closePolicy(value:String):void {
			this._closePolicy = value;
			this.invalidateDisplayList();
		}
		
		private var _showIndicator:Boolean = false;
		private var _indicatorOffset:Number = 0;
		
		/**
		 * A Boolean to determine whether we should draw the indicator arrow icon.
		 */
		public function get showIndicator():Boolean {
			return _showIndicator;
		}
		
		public function set showIndicator(val:Boolean):void {
			this._showIndicator = val;
			
			this.invalidateDisplayList();
		}
		
		public function showIndicatorAt(x:Number):void {
			this._indicatorOffset = x;
			this.showIndicator = true;	
		}
		
		override protected function measure():void {
			super.measure();
			
			if(_closePolicy == SuperTab.CLOSE_ALWAYS || _closePolicy == SuperTab.CLOSE_ROLLOVER) {
				//the close icon is 10 px wide and 4px from the right
				measuredMinWidth += 10;
			}
			else if(_closePolicy == SuperTab.CLOSE_SELECTED && selected) {
				measuredMinWidth += 10;
			}
		}
		
		override protected function createChildren():void{
			super.createChildren();
			
			// Here the width and height of the closeButton are hardcoded.
			// To make the component more customizable I suppoose the width and
			// height could be controlled by either a button skin, or by a property 
			closeButton = new Button();
			closeButton.width = 10;
			closeButton.height = 10;
			
			// We have to listen for the click event so we know to close the tab
			closeButton.addEventListener(MouseEvent.MOUSE_UP, closeClickHandler, false, 0, true); 
			closeButton.addEventListener(MouseEvent.MOUSE_DOWN, cancelEvent, false, 0, true); 
			closeButton.addEventListener(MouseEvent.CLICK, cancelEvent, false, 0, true); 
		
			var indicatorClass:Class = getStyle("indicatorClass") as Class;
			if(indicatorClass) {
				indicator = new indicatorClass() as DisplayObject;
			}
			else {
				indicator = new UIComponent();
			}
			
			addChild(indicator);
			addChild(closeButton);
			
			closeButton.enabled = this.enabled;

			// This allows someone to specify a CSS style for the close button
			closeButton.styleName = getStyle("tabCloseButtonStyleName");
			
			this.textField.addEventListener(Event.CHANGE, captureTextChange); 	
		}
		
		/**
		 * Boolean indicating if a double click on the tab will allow the editing of the tab label.
		 * 
		 * @default false.
		 */
		public var doubleClickToEdit:Boolean = false;

		private function doubleClickHandler(event:MouseEvent):void {
			if(doubleClickToEdit && this.enabled) {
				this.editableLabel = true;
			}
		}		
		
		private function textUnfocusListener(event:Event):void {
			this.label = textField.text;
			
			this.editableLabel = false;
			
			dispatchEvent(new SuperTabEvent(SuperTabEvent.TAB_UPDATED, -1));
		}
		
		private var _editableLabel:Boolean=false;
		
		public function get editableLabel():Boolean {
			return _editableLabel;
		}
		
		public function set editableLabel(value:Boolean):void {
			if(value != _editableLabel) {
				_editableLabel = value;
				
				this.textField.type = value ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
				this.textField.selectable = value;
				
				if(value) {
					this.addEventListener(MouseEvent.MOUSE_DOWN, cancelEvent, false, 10);
					
					this.textField.addEventListener(FocusEvent.FOCUS_OUT, textUnfocusListener);
					this.textField.addEventListener(KeyboardEvent.KEY_DOWN, checkEnterKey);
					this.textField.setSelection(0, textField.length-1);
				}
				else {
					this.removeEventListener(MouseEvent.MOUSE_DOWN, cancelEvent);
					
					this.textField.removeEventListener(FocusEvent.FOCUS_OUT, textUnfocusListener);
					this.textField.removeEventListener(KeyboardEvent.KEY_DOWN, checkEnterKey);
					this.textField.setSelection(0, 0);
					
					this.textField.invalidateDisplayList();
				}
			}
		}
		
		private function checkEnterKey(event:KeyboardEvent):void {
			if(event.keyCode == 13) {
				event.stopImmediatePropagation();
				event.stopPropagation();
				
				this.editableLabel = false;
				dispatchEvent(new SuperTabEvent(SuperTabEvent.TAB_UPDATED, -1));
			}
		}
		
		
		private function captureTextChange(event:Event):void {
			if(this.label != textField.text) {
				this.label = textField.text;
			}
			
			event.stopImmediatePropagation();
		}
		
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			
			if(closeButton) {
				closeButton.enabled = value;
			}
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// We need to make sure that the closeButton and the indicator are
			// above all other display items for this button. Otherwise the button
			// skin or icon or text are placed over the closeButton and indicator.
			// That's no good because then we can't get clicks and it looks funky.
			setChildIndex(closeButton, numChildren - 2);
			setChildIndex(indicator, numChildren - 1);
			
			
			closeButton.visible = false;
			indicator.visible = false;
			
			// Depending on the closePolicy we might be showing the closeButton
			// and it may or may not be enabled.
			if(_closePolicy == SuperTab.CLOSE_SELECTED) {
				if(selected) {
					closeButton.visible = true;
					closeButton.enabled = true;
				}
			}
			else {
				if(!_rolledOver) {
					if(_closePolicy == SuperTab.CLOSE_ALWAYS){
						closeButton.visible = true;
						closeButton.enabled = false;
					}
					else if(_closePolicy == SuperTab.CLOSE_ROLLOVER) {
						closeButton.visible = false;
						closeButton.enabled = false;
					}
				}
				else {
					if(_closePolicy != SuperTab.CLOSE_NEVER) {
						closeButton.visible = true;
						closeButton.enabled = this.enabled;
					}
				}
			}
			
			if(_showIndicator) {
				indicator.visible = true;
				indicator.x = _indicatorOffset - indicator.width/2;
				indicator.y = 0;
			}
			
			if(closeButton.visible) {
				// Resize the text if we're showing the closeIcon, so the
				// closeIcon won't overlap the text. This means the text may
				// have to truncate using the "..." differently.
				//this.textField.width = closeButton.x - textField.x;
				//this.textField.truncateToFit();
				
				// We place the closeButton 4 pixels from the top and 4 pixels from the right.
				// Why 4 pixels? Because I said so. 
				closeButton.x = unscaledWidth-closeButton.width - 4;
				closeButton.y = 4;
				
				var closeButtonStyleName:String = getStyle("tabCloseButtonStyleName");
				if(closeButtonStyleName != null && closeButtonStyleName != closeButton.styleName) {
					closeButton.styleName = closeButtonStyleName;
				}
					
				setChildIndex(closeButton, numChildren - 1);
			}
		}
		
		/**
		 * We keep track of the rolled over state internally so we can set the
		 * closeButton to enabled or disabled depending on the state.
		 */
		override protected function rollOverHandler(event:MouseEvent):void{
			if(!enabled) {
				event.stopImmediatePropagation();
				event.stopPropagation();
				return;
			}
			
			_rolledOver = true;
			
			super.rollOverHandler(event);	
		}
		
		override protected function rollOutHandler(event:MouseEvent):void{
			_rolledOver = false;
			
			super.rollOutHandler(event);	
		}
		
		/**
		 * The click handler for the close button.
		 * This makes the SuperTab dispatch a CLOSE_TAB_EVENT. This doesn't actually remove
		 * the tab. We don't want to remove the tab itself because that will happen
		 * when the SuperTabNavigator or SuperTabBar removes the child container. So within the SuperTab
		 * all we need to do is announce that a CLOSE_TAB_EVENT has happened, and we leave
		 * it up to someone else to ensure that the tab is actually removed.
		 */
		private function closeClickHandler(event:MouseEvent):void {
			if(this.enabled) {
				dispatchEvent(new Event(CLOSE_TAB_EVENT));
			}
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
		override public function set selected(value:Boolean):void {
			
			super.selected = value;
			
			callLater(invalidateSize);
		}
		
		
		private function cancelEvent(event:Event):void {
			event.stopPropagation();
			event.stopImmediatePropagation();
		}
		
		
		
		override public function get measuredWidth():Number {
			return this.measuredMinWidth;
		}
	}
}